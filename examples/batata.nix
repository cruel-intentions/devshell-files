{ inputs, lib, ... }:
{
  files.json."/batata.yaml" = lib.my (builtins.attrNames inputs);
}
