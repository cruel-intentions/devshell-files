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
  # now we can use 'convco' command (docs) convco.github.io
  # look at search.nixos.org for more tools
  config.files.cmds.convco = true;
  # use the command 'menu' to list commands
  # now we can use 'feat' command (alias to convco)
  config.files.alias.feat = ''convco commit --feat $@'';
  config.files.alias.fix = ''convco commit --fix $@'';
  # LICENSE file creation
  # using templates from github.com/spdx/license-list-data
  config.files.license.enable = true;
  config.files.license.spdx.name = "MIT";
  config.files.license.spdx.vars.year = "2021";
  config.files.license.spdx.vars."copyright holders" = "Cruel Intentions";
}
