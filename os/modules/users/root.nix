{pkgs, ...}: {
  users.users.root = {
    shell = pkgs.bash;
    initialHashedPassword = "$y$j9T$4o/kL03dWu1EEDKz3HTtz/$cQmBEFMqdMluOqvnBCiRboqM6y5BaMnRGlhV82ikwTD";
  };
}
