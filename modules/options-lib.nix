{ lib }:
let
  optionsOf         = opts: { options = builtins.mapAttrs (n: lib.mkOption) opts; };
  nullOrSubmoduleOf = opts: lib.types.nullOr    (submoduleOf opts);
  submoduleOf       = opts: lib.types.submodule (optionsOf opts);
  boolOr            = typE: lib.types.oneOf     [typE lib.types.bool];
in
{
  inherit boolOr optionsOf nullOrSubmoduleOf submoduleOf;
  listOfNonEmptyStr         = lib.types.listOf         lib.types.nonEmptyStr;
  nonEmptyListOfNonEmptyStr = lib.types.nonEmptyListOf lib.types.nonEmptyStr;
  nullOrNonEmptyString      = lib.types.nullOr         lib.types.nonEmptyStr;
  nullOrUInt                = lib.types.nullOr         lib.types.ints.unsigned;
  nullOrPath                = lib.types.nullOr         lib.types.path;
}
