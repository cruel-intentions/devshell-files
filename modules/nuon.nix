{ lib, config, ...}:
{
  options.files.nuon.enable = lib.mkOption {
    default     = false;
    description = "Enable nuon command";
    type        = lib.types.bool;
    example     = true;
  };
  config.files = lib.mkIf config.files.nuon.enable (import ../examples/nushell/nush.nuon.nix).files;
}
