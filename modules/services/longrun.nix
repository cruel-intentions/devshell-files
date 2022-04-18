{ lib }:
let
  optsLib = import ../options-lib.nix { inherit lib; };
  fork-fork.default         = false;
  fork-fork.example         = true;
  fork-fork.type            = lib.types.bool;
  fork-fork.description     = ''If the check script should double fork'';
  initial-delay.default     = 50;
  initial-delay.example     = 10;
  initial-delay.type        =  lib.types.ints.unsigned;
  initial-delay.description = ''Time in ms to await and check if its ready'';
  interval.default          = 100;
  interval.example          = 1000;
  interval.type             = lib.types.ints.unsigned;
  interval.description      = ''Time in ms between check attempts'';
  timeout.default           = 2000;
  timeout.example           = 3000;
  timeout.type              =  lib.types.ints.unsigned;
  timeout.description       = ''Time in ms to give up from this service'';
  attempts.default          = 7;
  attempts.example          = 30;
  attempts.type             =  lib.types.ints.unsigned;
  attempts.description      = ''Times it should run before give up from this service'';
  command.default           = null;
  command.example           = "curl -sSf http://localhost:8080";
  command.type              = optsLib.nullOrNonEmptyString;
  command.description       = ''
    Command to be executed as checking method

    If not defined {name}-ready is assumed to be command to run
  '';
  readiness = { inherit fork-fork initial-delay interval timeout attempts command; };
in {
  consumer-for.default          = [];
  consumer-for.example          = ["myService"];
  consumer-for.type             = optsLib.listOfNonEmptyStr;
  consumer-for.description      = ''
    Defines names of other services this services expects
    receive data at stdin from theirs stdout

    Dependency hierarchy are calculated at activation time.

    See [S6 documentation](http://skarnet.org/software/s6-rc/s6-rc-compile.html)
    for more info
  '';
  data.default                  = null;
  data.example                  = "./.data";
  data.type                     = optsLib.nullOrPath;
  data.description              = ''
    Path that contains data for your service
  '';
  deps.default                  = [];
  deps.example                  = ["myDependency"];
  deps.type                     = optsLib.listOfNonEmptyStr;
  deps.description              = ''
    Defines names of other services required to be `ready` to this
    service work.

    Dependency hierarchy are calculated at activation time.

    See [S6 documentation](http://skarnet.org/software/s6-rc/s6-rc-compile.html)
    for more info
  '';
  essential.default             = false;
  essential.example             = true;
  essential.type                = lib.types.bool;
  essential.description         = ''
    Mark this service and all its dependencies as essential

    It means some commands may work to stop this service
  '';
  env.default                   = null;
  env.example                   = "./.direnv";
  env.type                      = optsLib.nullOrPath;
  env.description               = ''
    Path that contains env data for your service
  '';
  kill-after.default            = 0;
  kill-after.example            = 2005;
  kill-after.type               = lib.types.ints.unsigned;
  kill-after.description        = ''
    Time in ms to give up from this service shutdown process
    and kill it anyway.

    - 0 means never
  '';
  kill-finish-after.default     = 0;
  kill-finish-after.example     = 2005;
  kill-finish-after.type        = lib.types.ints.unsigned;
  kill-finish-after.description = ''
    Time in ms to give up from this service finish script
    and kill it.

    - 0 means never
  '';
  lock-descriptor.default       = 0;
  lock-descriptor.example       = 5;
  lock-descriptor.type          = optsLib.nullOrUInt;
  lock-descriptor.description   = ''
    Configure a file descriptor to show that service is `running` 

    If value any value other then 0, 1 or 2, this 
    service uses file-descriptor lock
  '';
  max-restarts.default          = 100;
  max-restarts.example          = 2005;
  max-restarts.type             = lib.types.ints.unsigned;
  max-restarts.description      = ''
    Times it should restart before we giveup

    - Could not be more than 4096
  '';
  pipeline-name.default         = null;
  pipeline-name.example         = "logMyService";
  pipeline-name.type            = optsLib.nullOrNonEmptyString;
  pipeline-name.description     = ''
    Define name of this pipeline.

    Dependency hierarchy are calculated at activation time.

    See [S6 documentation](http://skarnet.org/software/s6-rc/s6-rc-compile.html)
    for more info
  '';
  producer-for.default          = null;
  producer-for.example          = "willReadMyLog";
  producer-for.type             = optsLib.nullOrNonEmptyString;
  producer-for.description      = ''
    Defines a service to read this progam stdout (ie a logger)

    Dependency hierarchy are calculated at activation time.

    See [S6 documentation](http://skarnet.org/software/s6-rc/s6-rc-compile.html)
    for more info
  '';
  readiness.default             = null;
  readiness.example             = { command = "curl https://localhost"; };
  readiness.type                = optsLib.nullOrSubmoduleOf readiness;
  readiness.description         = ''
    Configure it to use pooling script as ready
    [notification method](http://skarnet.org/software/s6/notifywhenup.html)

    It make your service start script be called with s6-notifyoncheck.
      
    See also ready-descriptor.
  '';
  ready-descriptor.default      = null;
  ready-descriptor.example      = 3;
  ready-descriptor.type         = optsLib.nullOrUInt;
  ready-descriptor.description  = ''
    Configure how to check if this service `ready` 
    [notification method](http://skarnet.org/software/s6/notifywhenup.html)

    If value any value other then 0, 1 or 2, this 
    service uses file-descriptor notification method

    If attr `readiness` is defined, use pooling as notification method
  '';
  signal.default                = 15;
  signal.example                = 3;
  signal.type                   = lib.types.ints.unsigned;
  signal.description            = ''
    Signal service expects to init down process
  '';
  start.default                 = null;
  start.example                 = "mysqld";
  start.type                    = optsLib.nullOrNonEmptyString;
  start.description             = '''
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
  stop.default                  = null;
  stop.example                  = "abSUrDO kill -9 1 1";
  stop.type                     = optsLib.nullOrNonEmptyString;
  stop.description              = ''
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

  timeout.default               = 0;
  timeout.example               = 10000;
  timeout.type                  = lib.types.ints.unsigned;
  timeout.description           = ''
    This service should be `ready` in X `milliseconds` or it will 
    considered a `failure` transition.

    If null or 0 system will wait indefinitely
  '';
  timeout-down.default          = 0;
  timeout-down.example          = 10000;
  timeout-down.type             = lib.types.ints.unsigned;
  timeout-down.description      = ''
    This service should be `stoped` in X `milliseconds` or it will 
    considered a `failure` transition.

    If null or 0 system will wait indefinitely
  '';
}
