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
  ];
  # install development or deployment tools
  # now we can use 'convco' command https://convco.github.io
  # look at https://search.nixos.org for more tools
  files.cmds.convco = true;
  # now we can use 'feat' command (alias to convco)
  files.alias.feat = ''convco commit --feat $@'';
  files.alias.fix  = ''convco commit --fix  $@'';
  files.alias.docs = ''convco commit --docs $@'';
  files.alias.alou = ''
    #!/usr/bin/env python
    print("Alo!") # is hello in portuguese
  '';
}
