# There is a lot things we could use to write static file
# Basic intro to nix language https://github.com/tazjin/nix-1p
# Some nix functions https://teu5us.github.io/nix-lib.html
{lib, ...}:
{
  config.files.text."/README.md" = builtins.concatStringsSep "\n" [
    (builtins.readFile ./readme/title.md)
    (builtins.readFile ./readme/installation.md)
    (builtins.import ./readme/examples.nix)
    (builtins.readFile ./readme/todo.md)
    (builtins.readFile ./readme/issues.md)
    ((builtins.import ./readme/modules.nix) lib)
  ];
}
