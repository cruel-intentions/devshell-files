{
  # import other modules
  imports = [
    ./examples/hello.nix
    ./examples/world.nix
    ./examples/readme.nix
    ./examples/gitignore.nix
    ./examples/license.nix
    ./examples/docs.nix
    ./examples/book.nix
    ./examples/services.nix
    ./examples/nim.nix
    ./examples/nushell.nix
  ];

  # install development or deployment tools
  packages = [
    "convco"
    # now we can use 'convco' command https://convco.github.io

    # but could be:
    # "awscli"
    # "azure-cli"
    # "cargo"
    # "conda"
    # "go"
    # "nim"
    # "nodejs"
    # "nodejs-18_x"
    # "nushell"
    # "pipenv"
    # "python39"
    # "ruby"
    # "rustc"
    # "terraform"
    # "yarn"
    # look at https://search.nixos.org for more packages
  ];

  # create alias
  files.alias.feat = ''convco commit --feat $@'';
  files.alias.fix  = ''convco commit --fix  $@'';
  files.alias.docs = ''convco commit --docs $@'';
  files.alias.alou = ''
    #!/usr/bin/env python
    print("Alo!") # is hello in portuguese
  '';

  # now we can use feat, fix, docs and alou commands

  # create .envrc for direnv
  files.direnv.enable = true;

  # disabe file creation when entering in the shell
  # call devshell-files instead
  # files.on-call = true;
}
