{pkgs, config, lib, ...}:
let
  inputs = config.files.inputs;
in {
  options.files.inputs = lib.mkOption {
    default     = {};
    description = "Attrset with all devshell-files inputs";
    example     = { nixpkgs = {}; };
    type        = lib.types.attrsOf lib.types.path;
  };
}
