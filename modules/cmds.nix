{pkgs, config, lib, ...}:
let
  cfg = config.files.cmds;
  toCmds = name: { package = name; };
  cmds = map toCmds (builtins.attrNames cfg);
in {
  options.files.cmds = lib.mkOption {
    example = "convco";
    type = lib.types.attrsOf lib.types.bool;
    description = "Add commands to the environment.";
    default = {};
  };
  config.commands = cmds;
}
