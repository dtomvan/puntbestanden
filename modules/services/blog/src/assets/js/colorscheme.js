// very cursed. the 2 link tags below load in either the light or
// dark color scheme depending on the system preference. If it's
// unavailable the below block will fallback to light. Afterwards make
// the toggle that will remove the "default colorscheme" stylesheets
// and insert a new one that points to the user override.
if (window.matchMedia("(prefers-color-scheme: dark)").media === "not all") {
  document.documentElement.style.display = "none";
  document.head.insertAdjacentHTML(
    "beforeend",
    '<link class="system-colorscheme" rel="stylesheet" href="/assets/css/light.css" onload="document.documentElement.style.display = \'\'">',
  );
}

const preferredColorScheme = localStorage.getItem("preferred-color-scheme");
window.colorScheme =
  preferredColorScheme != null
    ? preferredColorScheme
    : window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
document.head.insertAdjacentHTML(
  "beforeend",
  `<link id="color-override" rel="stylesheet" href="/assets/css/${window.colorScheme}.css">`,
);
addEventListener("DOMContentLoaded", (event) => {
  const toggleColorScheme = () => {
    window.colorScheme = window.colorScheme == "dark" ? "light" : "dark";
    localStorage.setItem("preferred-color-scheme", window.colorScheme);

    document.getElementById("color-override").href = `/assets/css/${window.colorScheme}.css`;
    document
      .querySelectorAll('link[rel="stylesheet"].system-colorscheme')
      .forEach((n) => document.head.removeChild(n));
  };
  document.querySelector("button.light-dark-toggle").onclick = toggleColorScheme;
});
