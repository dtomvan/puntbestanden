// load in light as a fallback when the system colorscheme isn't provided by
// the browser
if (window.matchMedia("(prefers-color-scheme: dark)").media === "not all") {
  document.documentElement.style.display = "none";
  document.head.insertAdjacentHTML(
    "beforeend",
    '<link class="system-colorscheme" rel="stylesheet" href="/assets/css/light.css" onload="document.documentElement.style.display = \'\'">',
  );
}

// point #color-override to the new colorscheme, creating it if it doesn't exist.
function activateColorScheme(colorScheme) {
  let override = document.getElementById("color-override");
  if (override == null) {
    document.head.insertAdjacentHTML(
      "beforeend",
      `<link id="color-override" rel="stylesheet" href="/assets/css/${colorScheme}.css">`,
    );
  } else {
    override.href = `/assets/css/${colorScheme}.css`;
  }

  document
    .querySelectorAll('link[rel="stylesheet"].system-colorscheme')
    .forEach((n) => document.head.removeChild(n));
}

addEventListener("DOMContentLoaded", (event) => {
  const preferredColorScheme = localStorage.getItem("preferred-color-scheme");
  if (preferredColorScheme != null) {
    window.colorScheme = preferredColorScheme;
    activateColorScheme(preferredColorScheme);
  } else {
    window.colorScheme = window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  const toggleColorScheme = () => {
    window.colorScheme = window.colorScheme == "dark" ? "light" : "dark";
    localStorage.setItem("preferred-color-scheme", window.colorScheme);

    activateColorScheme(window.colorScheme);
  };
  document.querySelector("button.light-dark-toggle").onclick = toggleColorScheme;
});
