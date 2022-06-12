{ 
  # create hello.yaml file
  files.yaml."/hello.yaml".greeting = "Hello World!!";

  # enable .gitignore creation
  files.gitignore.enable = true;
  # add hello.yaml to .gitignore
  files.gitignore.pattern."hello.yaml" = true;
  # copy contents from https://github.com/github/gitignore
  # to our .gitignore
  files.gitignore.template."Global/Archives" = true;
  files.gitignore.template."Global/Backup"   = true;
  files.gitignore.template."Global/Diff"     = true;

  # now we can use 'convco' command https://convco.github.io
  files.cmds.convco = true;

  # now we can use 'feat' command as alias to convco
  files.alias.feat  = ''convco commit --feat  "$@"'';
  files.alias.fix   = ''convco commit --fix   "$@"'';
  files.alias.chore = ''convco commit --chore "$@"'';
  # files.cmds.nodejs      = true; # lts
  # files.cmds.nodejs-18_x = true; # v18
  # files.cmds.awscli      = true;
  # files.cmds.azure-cli   = true;
  # files.cmds.cargo       = true;
  # files.cmds.conda       = true;
  # files.cmds.go          = true;
  # files.cmds.nim         = true;
  # files.cmds.pipenv      = true;
  # files.cmds.python39    = true;
  # files.cmds.ruby        = true;
  # files.cmds.rustc       = true;
  # files.cmds.terraform   = true;
  # files.cmds.yarn        = true;
  # look at https://search.nixos.org for more tools

  # configure direnv
  # files.direnv.enable = true;
}
