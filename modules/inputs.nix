{ lib, ...}:
{
  options.files.deps = lib.mkOption {
    default     = {};
    description = "Attrset with all devshell-files inputs paths";
    example.dsf = ../.;
    type        = lib.types.attrsOf lib.types.path;
  };
}
