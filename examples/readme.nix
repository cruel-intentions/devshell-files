# There is a lot things we could use to write dynamic static file
# Basic intro to nix language https://github.com/tazjin/nix-1p
# Some nix functions https://teu5us.github.io/nix-lib.html

{pkgs, lib, ...}:
{
  config.files.text."/README.md" = builtins.concatStringsSep "\n" [
    (builtins.readFile ./readme/title.md)
    (builtins.readFile ./readme/installation.md)
    (import ./readme/examples.nix)
    (builtins.readFile ./readme/todo.md)
  ];
}
