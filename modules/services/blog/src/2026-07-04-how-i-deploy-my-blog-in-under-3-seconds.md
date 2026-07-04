---
title: How I deploy my blog in under 3 seconds
subtitle: or the deadly poison known as overengineering
layout: post
summary: Using jorge, git-pages, and nix to make a blog is a little overkill, but fun!
date: 2026-07-04T18:52:14+02:00
lang: en
tags:
    - jorge
    - smallweb
    - forgejo
    - nixos
    - git-pages
    - system-building
draft: false
---

Pardon the clickbait-y title. I swear this is interesting!

**Assumed audience:** One of: selfhosting curious, Nix(OS) curious, web/SSG developer, people interested in the intricacies of running a smallweb server. Also, some basic Linux and hosting knowledge required, though I tried my best to keep it beginner-friendly :)

I've had an email exchange with the one and only [James from James' Coffee Blog](https://jamesg.blog) about the introduction of this new blog. He was interested in my stack (i.e. how I go from `git push` to a deployed static page), and how I use Jorge and Nix to accomplish all of it. I wouldn't call it so much of a "strong" stack per sé, but it's mine, I like it, and it's all declarative, rollbackable, and nicely integrated.

Oh boy, this will be a long one, isn't it? I feel like [fasterthanlime](https://fasterthanli.me), except way less smart and interesting 😅

This is my first actual long blog post, so Bear with me (pun intended)

## Taking inventory

A quick intro of most tools involved:
- [Jorge](https://jorge.oleano.dev), an opinionated Static Site Generator or SSG, with just enough features to run a blog or blog-like for your personal site. I've opted for it because it's just so simple. It's like self-hosted [bearblog](https://bearblog.dev) :)
- [Tyck](https://codeberg.org/natkr/tyck), a simple self-hosted embeddable comments engine. You don't `<iframe>` it, you actually copy-paste the entire HTML snippet it returns right into your document, [HTMX](https://htmx.org/)/[AJAX](https://en.wikipedia.org/wiki/Ajax_(programming)#JavaScript_example)-style! Read the [author's blogpost](https://natkr.com/2025-07-29-comments/) about it, though!
- [Forgejo](https://forgejo.org), a self-hosted [Git](https://git-scm.org) forge, for keeping track of your code, how it evolved over time, and integrating some side-effects with changes happening to your code, like linting (well, these are the features *I* use on my own instance, it can also do collaboration etc.)
- [Nix](https://nixos.org), a meta-buildtool, system of declarative deployments, and a way to install and manage Linux, all in one. Yes, that's [very confusing](https://www.reddit.com/r/linuxmemes/s/7oI4AV4cVi)
- [git-pages](https://codeberg.org/git-pages/git-pages/), a [GitHub pages](https://docs.github.com/en/pages) alternative for other code forges (mainly forgejo), which works in the same way (that is, deploy in CI on push). Also a big advantage is that you don't have to set a DNS record to one of GitHub's own servers, you just have to point your reverse proxy to `git-pages`!

The flow is as follows:
1. I make some change to my blog folder in my dotfiles repo (more on why it's in there later, spoiler: it's a monorepo!),
2. I commit and push said change to my Forgejo instance at git.toostveen.nl,
3. [Forgejo Actions](https://forgejo.org/2023-02-27-forgejo-actions/) spins up a container with Jorge in it, builds the blog with it, and sends the result to `git-pages` over on toostveen.nl,
4. `git-pages` authenticates the CI runner by checking that the [access token](https://forgejo.org/docs/latest/user/actions/reference/#forgejo) (that it automatically provides) *would actually work* on the repo defined in DNS (more on that later,)
5. `git-pages` receives the newly generated tarball, extracts it, and serves it on the requested (virtual) host,
6. [Nginx](https://nginx.org) exposes the `git-pages` server to the outside world on port 443.

I'd make a flowchart but I am too lazy to do that, and you get the point :) (HMU if not)

## Jorge!

For starters: Jorge is a CLI that turns a folder of markdown files and assets into a folder of HTML files and assets. That's all. You'd use it like this:

```bash
jorge init
jorge post 'My first blog post!'
vim src/my-first-blog-post.md # also supports orgmode, but I don't use it anymore
# [ go ham ]
jorge serve # start up a local test server
# [ go more ham ]
jorge build # build the "final" product
```

You can then serve the contents of the `target` folder using any reasonable HTTP server (even `python -m http.server`!), ét voilà, you've made a Jorge static site!

I can't recommend it enough for people who've seen [Hugo](https://gohugo.io) and the like but desire to Keep It Simple. No themes, no plugins, no hooks or modules, just you and your markup you've written manually with your own cold hands (you get a nice starting template though, which is close to what a vanilla Bear blog looks like incidentally). Do check it out. That is https://jorge.oleano.dev !

(spoiler for Nix nerds: of course I've packaged it with Nix, it's `nur.repos.dtomvan.jorge`, but I should put it in Nixpkgs one day)

## git-pages

`git-pages` is more elaborate, and has over half a dozen of authentication paths, but that's actually the neat part, as it really allows for flexibly controlling who can deploy to your site and how (and at which location!). The authentication method I'm using for my purposes is number 7 in [the docs](https://codeberg.org/git-pages/git-pages/src/commit/d870d0f9c52b97855e5db234c04093c5194caa79#authorization): `Forge Authorization (DNS allowlist)`. Hm. Let's break that down.

`git-pages` will accept an upload if both of these requirements are met:
1. The uploader has supplied a token that grants access to a Forgejo (read: git) repository
2. That repository is listed in the DNS-based allowlist for the domain that it's being uploaded to

The latter might require some explanation. You set a `TXT` record called `_git-pages-forge-allowlist` with your DNS provider (Cloudflare, in my case), and you set it to the exact URL that points to the git repo that you control and contains the source code for your blog (in my case it's `https://git.toostveen.nl/tom/puntbestanden`). Here's what that looks like for me in the Cloudflare control panel for DNS records:

![What I described above, just visually. Not a lot of extra context to provide in the alt text, sorry](/assets/img/2026-07-04-how-i-deploy-my-blog-in-under-3-seconds/cf-dns.png)

All of this just so I can automate deploying my static site on `git push`... GitHub actually does all of this behind the scenes for you, but that doesn't mean you should use it, as it locks you into Microslop's enshittified code forge with as big as an uptime percentage figure as the fraction of clankers on it... There, I've said it. So on with Forgejo!

## The Forgejo Actions workflow

If you already know GitHub actions, this will be very familiar to you (they've actually designed forgejo actions to be near-identical for migration purposes):

```yaml
on:
  push:
    branches:
      - hoofdlijn
jobs:
  publish:
    runs-on: jorge
    steps:
      - uses: actions/checkout@v6
      - run: bash modules/services/blog/build.sh
      - uses: actions/git-pages@v2
        with:
          site: https://toostveen.nl
          token: {% raw %}${{ forge.token }}{% endraw %}
          source: modules/services/blog/target
```

That's it. If you don't eat CI/CD for breakfast yet, here's what this file does in Plain English:
- When Forgejo receives a push to the `hoofdlijn` branch (my main branch, it's a bad literal Dutch translation of 'main')...
- Run the `publish` job in a `jorge` container. This job does the following things:
    1. Check out the `hoofdlijn` branch at it's latest commit
    2. Run the `bash modules/services/blog/build.sh` script
    3. Kindly ask the `git-pages` server at `toostveen.nl` to replace the current blog with the new one at `modules/services/blog/target`, providing our token

Since I've preloaded my CI runner with a `jorge` image, with otherwise the bare nessecities, this is all done in a flash. It doesn't have to download and install (or worse yet, `go build`) the program every time this workflow runs. There's not a lot of real work done here, just a bit of copying files around perhaps...

> So where's Nix involved in all this?

Wow, you really paid attention! I mentioned that ages ago... Well, I'm glad you asked!

## What does Nix have to do with anything???

If you don't know what Nix is, well, you're missing out in one way or another. Either way I won't really go into it, it's a bit of a rabbithole on it's own. All you have to know it's a way to *declare* what you want to install and run on your system. For example, where you'd usually do something like this on a traditional Linux server:

```bash
sudo apt install nginx
sudoedit /etc/nginx/nginx.conf
sudo systemctl start nginx
```

Notice that this is a *procedure*, not a *recipe*.

In NixOS -- put simply the Linux distribution built entirely on Nix -- you'd write a config file that looks like this:

```nix
{
  services.nginx = {
    enable = true;
    extraConfig = ''
      server {
        xyz
      }
    '';
  };
}
```

When *deploying* said config file, you're telling the system "let this be true!", and so it happens. Yes, I wrote that a bit like "let there be light", and by no means any offense meant to the religious, but I worded it like that on purpose, because it quite literally can feel like playing God on your Linux system. Not necessarily because you're installing software *declaratively*, but because you get to inspect an entire system at a glance, see what's installed, and you even get the superpower of trivial rollbacks, something which *legacy systems* don't usually offer without some filesystem-level snapshotting...

BTW, you NixOS nerdsnipers: In practice, you'd never actually write the above snippet like that, you can do it structurally through [services.nginx.virtualHosts](https://search.nixos.org/options?channel=unstable&query=services.nginx.virtualHosts), but it isn't really obvious at first how that would map to an `nginx.conf`, so I didn't include that in my example.

So, naturally, I've written special `git-pages` and Tyck support for NixOS through something called a *module*, which is just short for "a coherent unit of Nix code that allows for configuring *something* through *some* interface". These allow me to just set something like `services.git-pages.enable = true;` and expect it to work. All you'd have to do is put it behind nginx, which is [trivial](https://git.toostveen.nl/tom/puntbestanden/src/commit/3f6521681e1b6f0dbd7c7872562c9568915a8b5c/modules/services/blog/default.nix#L121).

### From pure Nix build to docker container

Also, I used to have the blog build itself be done inside of Nix (`nix build .#blog`), but that's really slow for CI, as it would have to fetch a lot of dependencies, evaluate everything etc. in order to even start running `jorge build`. It could take up to five minutes!

To mitigate that, I've actually made a [Docker](https://www.docker.com/) image (if you don't know what that is, it's pretty much yet another way of packaging and distributing software to make it Run Anywhere©) **using Nix**. Yes, Nix can do that, since it's just a goofy way of building stuff, it can also "just" build everything you tell it to put into a Docker image, and do just that. It's actually kind-of straightforward to do since Docker images are "just" tarballs, but you don't have to build those yourself, as there's a funky thing called `dockerTools` that can do just that.

So now, as explained above, all it has to do is fetch the image *once*, and use that every time after that. Is it as pure and declarative? No: it relies on me manually pushing new versions of the image to my registry for new versions of `jorge` and everything it depends on. It will also just use "whatever's the latest version", which goes against the entire Nix philosophy, but it works for me...

Also, I can recreate the CI environment effortlessly with a command like: `docker run -it --rm -v /src:$(PWD):rw git.toostveen.nl/tom/puntbestanden:jorge bash`, so it's fiiiiiine...

`</pedantry>`

### Shameless plug: muh dotfiles

If you're interested in what and how I deploy in Nix land (oh my god there's so much more), it's all public in my [puntbestanden](https://git.toostveen.nl/tom/puntbestanden), though beware, it's written in an unusual way, so you might not recognize what everything does, even to an intermediate Nixer. Not that it's documented very well either... (sigh)

The neat part is: it's one big monorepo. That means *everything* (except some package definitions) lives here: from my Neovim config (current one linked on the neovim button on my homepage), to what bootloader I use, to what fonts I like, to the [docker image I just mentioned, actually](https://git.toostveen.nl/tom/puntbestanden/src/commit/3f6521681e1b6f0dbd7c7872562c9568915a8b5c/modules/services/forgejo/lix-with-node/default.nix)...

(yes: "puntbestanden" is also bad, literal Dutch for "dotfiles")

## Serve, queen!

As I don't have a homelab (yet), I run all this on a virtual [Hetzner](https://hetzner.com) server (as of writing a type CX23, which is very inexpensive, though they did raise the price to about €7 as of July 2026), which seems to handle the little traffic (along with other services I run for myself currently) I get just fine. I run [iocaine](https://iocaine.madhouse-project.org/), a simple anti-scraper proxy, for my Forgejo instance, the rest is completely exposed to the wider interwebz. Let's hope no-one ruins it, as adding Cloudflare as a last resort would result in longer loading times for everything, especially Forgejo for some reason.

## Quick figures

Just some fun facts about the stylistic/design choices I made. Some people care about these some don't :)

- Theme: [Catppuccin](https://catppuccin.com)
- Font: there's none! I just set `sans-serif` and `monospace`, and I'll either let your OS default or your own taste decide!
- Print (to PDF) support: YES! 🎉 thanks to [this very helpful post by Peter Molnar](https://petermolnar.net/article/how-to-make-a-print-css/)
- First drafts happen usually in [Hedgedoc](https://hedgedoc.org/), a semi-old markdown editor designed with sync and collaboration in mind (I also have Obsidian but this is easier and self-hosted)

## You don't have to do any of this

Yes, you can make it as fancy as I've done, but after all it's just static HTML on a webserver. We've done that for ages. You could literally write a script along the lines of:

```bash
jorge build
ssh root@toostveen.nl rm -r /var/lib/nginx/www/\*
scp -r target/* root@toostveen.nl:/var/lib/nginx/www
```

... and you've also written a 3-second deployment! But then again you won't get niceties like a `Source` link that links to the exact commit the blog was built against:

![a `Source` link that links to `https://git.toostveen.nl/tom/puntbestanden/src/commit/3f6521681e1b6f0dbd7c7872562c9568915a8b5c/modules/services/blog`](/assets/img/2026-07-04-how-i-deploy-my-blog-in-under-3-seconds/source-link.png)

... and, well, you probably won't have much fun 😁 (believe it or not, for a computer toucher like me this is actually considered fun, despite the 3am Nginx fighting I did)

## Thanks!

Thanks to James for "making" me write this post. I actually contemplated about it for a bit just before he asked nicely, so I figured there must be some people who *are* interested after all :) I'm sorry if this didn't turn out as beginner-friendly as you've liked. This post introduces probably like 10 new tools/concepts to the uninitiated. Please let me know if you have any feedback on how to "fix" that. If this post could be a helpful resource to people starting out, I'd like it to be.

This isn't "the way" neither is it a prescription of all the things you ought to do when selfhosting a personal blog, but rather see this as a smorgas board of tips/tricks, that's somehow connected into a single amalgamated solution. I hope I've done so in an understandable way. Thanks!

If you'd like to know more or if you have any questions, please shoot me an email or toot!

Thank you so much for taking the time to read this, it means a lot!
