function toggleMonospace() {
  document.body.classList.toggle("mono");
  let newPref = document.body.classList.contains("mono");
  localStorage.setItem("wants-monospace", newPref);
}
addEventListener("DOMContentLoaded", (event) => {
  const monoPref = localStorage.getItem("wants-monospace");
  if (monoPref === "true") {
    document.body.classList.add("mono");
  }
  document.getElementById("reset-btn").addEventListener("click", (event) => {
    localStorage.removeItem("wants-monospace");
    document.body.classList.remove("mono");
  });
});
