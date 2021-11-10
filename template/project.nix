{
  config.files.yaml."/hello.yaml".greeting = "Hello World!!"; # create hello.yaml file

  config.files.gitignore.enable = true;                       # enable .gitignore creation
  config.files.gitignore.pattern."hello.yaml" = true;         # add hello.yaml to .gitignore
  config.files.gitignore.template."Global/Archives" = true;   # copy contents from https://github.com/github/gitignore
  config.files.gitignore.template."Global/Backup" = true;     # to our .gitignore
  config.files.gitignore.template."Global/Diff" = true;

  config.files.cmds.convco = true;                            # now we can use 'convco' command https://convco.github.io
  config.files.alias.feat = ''convco commit --feat $@'';      # now we can use 'feat' command as alias to convco
  # look at https://search.nixos.org for more tool
}
