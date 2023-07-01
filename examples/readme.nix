# There is a lot things we could use to write static file
# Basic intro to nix language https://github.com/tazjin/nix-1p
# Some nix functions https://teu5us.github.io/nix-lib.html
{lib, ...}:
{
  files.text."/README.md" = builtins.concatStringsSep "\n" [
    "# Devshell Files Maker"
    (builtins.readFile ./readme/toc.md)
    (builtins.readFile ./readme/about.md)
    (builtins.readFile ./readme/installation.md)
    (builtins.import   ./readme/examples.nix)
    ((builtins.import  ./readme/modules.nix) lib)
    (builtins.readFile ./readme/todo.md)
    (builtins.readFile ./readme/issues.md)
    (builtins.readFile ./readme/seeAlso.md)
  ];
}
