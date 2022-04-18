{ lib }:
let
  optionsOf = opts: { options = builtins.mapAttrs (n: lib.mkOption) opts; };
in
{
  inherit optionsOf;
  submoduleOf = opts: lib.types.submodule (optionsOf opts);
  boolOr = t: lib.types.oneOf [t lib.types.bool];
  nullOrNonEmptyString = lib.types.nullOr lib.types.nonEmptyStr;
  nonEmptyListOfNonEmptyStr = lib.types.nonEmptyListOf lib.types.nonEmptyStr;
  listOfNonEmptyStr = lib.types.listOf lib.types.nonEmptyStr;
}
