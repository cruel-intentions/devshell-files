{ lib }:
let
  optsLib = import ../options-lib.nix { inherit lib; };
in {
  essential.default        = false;
  essential.example        = true;
  essential.type           = lib.types.bool;
  essential.description    = ''
    Mark this service and all its dependencies as essential

    It means some commands may work to stop these services
  '';
  timeout.default          = 0;
  timeout.example          = 10000;
  timeout.type             = lib.types.ints.unsigned;
  timeout.description      = ''
    This service should be `ready` in X `milliseconds` or it will 
    considered be in `failure` status.

    If null or 0 system will wait indefinitely
  '';
  timeout-down.default     = 0;
  timeout-down.example     = 10000;
  timeout-down.type        = lib.types.ints.unsigned;
  timeout-down.description = ''
    This service should be stop in X `milliseconds` or it will
    considered be in `failure` status.

    If null or 0 system will wait indefinitely
  '';
  start.default            = null;
  start.example            = "echo Hello World > $PRJ_DATA_DIR/hello.txt";
  start.type               = optsLib.nullOrNonEmptyString;
  start.description        = ''
    execline setup script.

    If not defined {name}-start is assumed to be command to run

    Example for non execline scripts:

    ```nix
    files.rc.alo.oneshot.start =
    # creates a python script to run when srv start
    # and save it at nix store
    let start = pkgs.writeScript "mySrvStartScript" 
    ${"''"}
      #!/usr/bin/env -S python
      print("Alô!")  # is hello in portuguese
    ${"''"};
    # use the nix store address
    in "''${start}";
    ```
  '';
  stop.default             = null;
  stop.example             = "rm $PRJ_DATA_DIR/hello.txt";
  stop.type                = optsLib.nullOrNonEmptyString;
  stop.description         = ''
    execline teardown script.

    If not defined {name}-stop is assumed to be command to run

    Example for non execline scripts:

    ```nix
    files.rc.alo.oneshot.stop = 
    # creates a python script to run when srv stop
    # and save it at nix store
    let stop = pkgs.writeScript "mySrvStopScript"
    ${"''"}
      #!/usr/bin/env -S bash
      echo "Tchau!"  # is bye in portuguese
    ${"''"};
    # use the nix store address
    in "''${stop}";
    ```
  '';
  deps.default              = [];
  deps.example              = ["myDependency"];
  deps.type                 = optsLib.listOfNonEmptyStr;
  deps.description          = ''
    Defines names of other services required to be `ready` to this
    service work.

    Dependency hierarchy are calculated at activation time.
  '';
}
