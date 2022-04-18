{pkgs, config, lib, ...}:
let
  cfg = config.files.alias;
  isntSH  = line: builtins.match "#!/.+" line == null;
  stripCo = line: builtins.replaceStrings ["# " "#"] ["" ""] line;
  lines   = name: lib.splitString "\n" cfg.${name};
  toAlias = name: {
    inherit name;
    help    = with builtins; stripCo (head (filter isntSH (lines name)));
    command = ''
      ${cfg.${name}}
    '';

  };
  aliasses = map toAlias (builtins.attrNames cfg);
in {
  options.files.alias = lib.mkOption {
    default       = {};
    description   = "bash script to create an alias";
    type          = lib.types.attrsOf lib.types.string;
    example.hello = "echo hello";
    example.world = ''
      #!/usr/bin/env python
      print("world")
    '';
  };
  config.commands = aliasses;
}
