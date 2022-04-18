{ lib }:
let
  optsLib = import ../options-lib.nix { inherit lib; };
in {
  essential.default     = false;
  essential.example     = true;
  essential.type        = lib.types.bool;
  essential.description = ''
    Mark this bundle and all its dependencies as essential

    It means some commands may work to stop these services
  '';
  deps.example          = ["myDep" "myOtherDep"];
  deps.type             = optsLib.nonEmptyListOfNonEmptyStr;
  deps.description      = ''
    Defines what makes part of this bundle
  '';
}
