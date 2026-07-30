{
  perSystem = { lib, pkgs, ... }: {
    packages.repost =
      pkgs.writers.writePython3Bin "repost"
        {
          libraries = with pkgs.python3.pkgs; [
            beautifulsoup4
            requests
            mf2py
          ];
        }
        # python
        ''
          from bs4 import BeautifulSoup
          from datetime import datetime, timezone
          from urllib.parse import urlsplit
          import mf2py
          import os.path
          import requests
          import subprocess
          import sys


          def bail(*a):
              print(*a, file=sys.stderr)
              sys.exit(1)


          if len(sys.argv) < 2:
              bail(f"Usage: {sys.argv[0]} <URL>")


          def get_title(soup: BeautifulSoup):
              try:
                  return soup.find("title").contents[0]
              except Exception:
                  return "Unknown title"


          res = requests.get(sys.argv[1])
          soup = BeautifulSoup(res.text, "html.parser")
          mf = mf2py.Parser(doc=soup).to_dict(filter_by_type="h-entry")
          author_name = None
          author_url = None

          tags = ["repost"]


          if len(mf) > 0:
              entry = mf[0]["properties"]
              title = entry["name"][0]
              if "author" in entry and "h-card" in entry["author"][0]["type"]:
                  author_name = entry["author"][0]["properties"]["name"][0]
                  author_url = entry["author"][0]["properties"]["url"][0]

              if "category" in entry:
                  tags += entry["category"]
          else:
              title = get_title(soup)


          if author_name is None:
              url = urlsplit(sys.argv[1])
              author_url = f"{url.scheme}://{url.netloc}"
              author_soup = BeautifulSoup(requests.get(author_url).text, "html.parser")
              author_name = get_title(author_soup)


          tag_list = "\n".join([f'    - "{tag.lstrip("#")}"' for tag in tags])
          template = f"""---
          repost_title: {title}
          repost_url: {sys.argv[1]}
          author: {author_name}
          author_url: {author_url}
          date: {datetime.now(timezone.utc).isoformat(timespec="seconds")}
          layout: post
          lang: en
          draft: true
          hidden: false
          tags:
          {tag_list}
          commentary: true
          ---"""
          print(template)


          cmd = "${lib.getExe pkgs.nur.repos.dtomvan.jorge}"
          jorge = subprocess.run(
              [cmd, "post", title],
              text=True,
              capture_output=True,
          )
          jorge.check_returncode()
          out_path = jorge.stdout.removeprefix("added ").strip()
          if os.path.exists(out_path):
              with open(out_path, "w") as f:
                  print(template, file=f)
                  print(f"written to {out_path}", file=sys.stderr)
        '';
  };
}
