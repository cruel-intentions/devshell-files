{
  # import other modules
  imports = [
    ./examples/hello.nix
    ./examples/world.nix
    ./examples/readme.nix
  ];
  # create my .gitignore coping ignore patterns from
  # github.com/github/gitignore
  config.files.gitignore.enable = true;
  config.files.gitignore.template."Global/Archives" = true;
  config.files.gitignore.template."Global/Backup" = true;
  config.files.gitignore.template."Global/Diff" = true;
  # install development or deployment tools
  # now we can use 'convco' command
  config.files.cmds.convco = true;
  # now we can use 'feat' command (alias to convco)
  config.files.alias.feat = ''convco commit --feat $@'';
  config.files.alias.fix = ''convco commit --fix $@'';
  # use the command 'menu' to list commands
}
