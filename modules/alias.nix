{pkgs, config, lib, ...}:
let
  cfg = config.files.alias;
  isntSH  = line: builtins.match "#!/.+" line == null;
  stripCo = line: builtins.replaceStrings ["# " "#"] ["" ""] line;
  lines   = value: lib.splitString "\n" value;
  toAlias = name: value: {
    name    = name;
    command = value;
    help    = with builtins; stripCo (head (filter isntSH (lines value)));
  };
  aliasses = builtins.attrValues (builtins.mapAttrs toAlias cfg);
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
