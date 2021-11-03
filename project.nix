{
  imports = [
    ./examples/hello.nix
    ./examples/world.nix
    ./examples/readme.nix
  ];
  config.commands = [
    { package = "devshell.cli"; }
    { package = "convco"; }
  ];
  config.files.gitignore.enable = true;
  config.files.gitignore.pattern."some-ignore-pattern" = true;
  config.files.gitignore.pattern."other-ignore-pattern" = true;
  config.files.gitignore.template."Global/Archives" = true;
  config.files.gitignore.template."Global/Backup" = true;
  config.files.gitignore.template."Global/Diff" = true;
}
