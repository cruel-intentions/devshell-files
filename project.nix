{
  # import other modules
  imports = [
    ./examples/hello.nix
    ./examples/world.nix
    ./examples/readme.nix
  ];
  # install development or deployment tools
  config.commands = [
    { package = "devshell.cli"; }
    { package = "convco"; }
  ];
  # configure your files creation
  config.files.gitignore.enable = true;
  config.files.gitignore.template."Global/Archives" = true;
  config.files.gitignore.template."Global/Backup" = true;
  config.files.gitignore.template."Global/Diff" = true;
}
