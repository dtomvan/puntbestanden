{ config, ... }:
{
  text.gitignore = ''
    /result*
    /repl-result*
  '';

  perSystem.files.files = [
    {
      path_ = ".gitignore";
      drv = builtins.toFile ".gitignore" config.text.gitignore;
    }
  ];
}
