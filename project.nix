{
  # import other modules
  imports = [
    ./examples/hello.nix
    ./examples/world.nix
    ./examples/readme.nix
    ./examples/gitignore.nix
    ./examples/license.nix
    ./examples/book.nix
  ];
  # install development or deployment tools
  # now we can use 'convco' command https://convco.github.io
  # look at https://search.nixos.org for more tools
  config.files.cmds.convco = true;
  # now we can use 'feat' command (alias to convco)
  config.files.alias.feat = ''convco commit --feat $@'';
  config.files.alias.fix = ''convco commit --fix $@'';
  config.files.alias.docs = ''convco commit --docs $@'';
}
