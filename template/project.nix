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
  files.gitignore.template."Global/Backup" = true;
  files.gitignore.template."Global/Diff" = true;
  # now we can use 'convco' command https://convco.github.io
  files.cmds.convco = true;
  # now we can use 'featw' command as alias to convco
  files.alias.feat = ''convco commit --feat $@'';
  files.alias.fix = ''convco commit --fix $@'';
  files.alias.chore = ''convco commit --chore $@'';

  # files.cmds.nodejs-14_x = true; # installs node, npm and npx
  # files.cmds.yarn = true;
  # files.cmds.python39 = true;
  # files.cmds.pipenv = true;
  # files.cmds.conda = true;
  # files.cmds.ruby_3_0 = true; # installs ruby and gem
  # files.cmds.go_1_17 = true;
  # files.cmds.rustc = true;
  # files.cmds.cargo = true;
  # files.cmds.awscli = true;
  # files.cmds.azure-cli = true;
  # files.cmds.terraform = true;
  # look at https://search.nixos.org for more tools
}
