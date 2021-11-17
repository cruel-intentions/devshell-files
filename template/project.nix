{ 
  # create hello.yaml file
  config.files.yaml."/hello.yaml".greeting = "Hello World!!";
  # enable .gitignore creation
  config.files.gitignore.enable = true;
  # add hello.yaml to .gitignore
  config.files.gitignore.pattern."hello.yaml" = true;
  # copy contents from https://github.com/github/gitignore
  # to our .gitignore
  config.files.gitignore.template."Global/Archives" = true;
  config.files.gitignore.template."Global/Backup" = true;
  config.files.gitignore.template."Global/Diff" = true;
  # now we can use 'convco' command https://convco.github.io
  config.files.cmds.convco = true;
  # now we can use 'featw' command as alias to convco
  config.files.alias.feat = ''convco commit --feat $@'';
  config.files.alias.fix = ''convco commit --fix $@'';
  config.files.alias.chore = ''convco commit --chore $@'';

  # config.files.cmds.nodejs-14_x = true; # installs node, npm and npx
  # config.files.cmds.yarn = true;
  # config.files.cmds.python39 = true;
  # config.files.cmds.poetry = true;
  # config.files.cmds.conda = true;
  # config.files.cmds.ruby_3_0 = true; # installs ruby and gem
  # config.files.cmds.go_1_17 = true;
  # config.files.cmds.rustc = true;
  # config.files.cmds.cargo = true;
  # config.files.cmds.awscli2 = true;
  # config.files.cmds.azure-cli = true;
  # config.files.cmds.terraform = true;
  # look at https://search.nixos.org for more tools
}
