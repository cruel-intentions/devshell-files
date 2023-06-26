{ lib, config, ...}:
{
  options.files.nuon.enable = lib.mkOption {
    default     = false;
    description = "Enable nuon command";
    type        = lib.types.bool;
    example     = true;
  };
  config.files.alias.nuon = lib.mkIf config.files.nuon.enable (builtins.readFile ../examples/nushell/nuon.nu);
}
