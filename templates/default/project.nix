{
  # Name your shell environment
  devshell.name = "my-projectson";

  # create hello.yaml file
  files.yaml."/hello.yaml".greeting = "Hello World!!";

  # create .gitignore
  files.gitignore.enable = true;
  # add hello.yaml to .gitignore
  files.gitignore.pattern."hello.yaml" = true;
  # copy contents from https://github.com/github/gitignore
  # to our .gitignore
  files.gitignore.template."Global/Archives" = true;
  files.gitignore.template."Global/Backup"   = true;
  files.gitignore.template."Global/Diff"     = true;


  # install a packages
  packages = [
    "convco"
    # now we can use 'convco' command https://convco.github.io
    # other packages
    # "awscli"
    # "azure-cli"
    # "cargo"
    # "conda"
    # "go"
    # "nim"
    # "nodejs"
    # "nodejs-18_x"
    # "pipenv"
    # "python39"
    # "ruby"
    # "rustc"
    # "terraform"
    # "yarn"
    # look at https://search.nixos.org for more packages
  ];


  # create some alias
  files.alias.feat  = ''convco commit --feat  "$@"'';
  files.alias.fix   = ''convco commit --fix   "$@"'';
  files.alias.chore = ''convco commit --chore "$@"'';
  # now we can use 'feat' command as alias to convco

  # files.alias.helloPy = ''
  #   #!/usr/bin/env python
  #   print("Im python code")
  # '';
  # or 
  # files.alias.helloPy = builtins.readFile helloPy.py

  # configure direnv .envrc file
  # files.direnv.enable = true;

  # look at https://cruel-intentions.github.io/devshell-files/builtins.html
  # for more builtins options

  # look at https://cruel-intentions.github.io/devshell-files/modules.html
  # for how to create modules
}
