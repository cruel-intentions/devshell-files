{ lib, ...}:
let
  optsLib = import ../options-lib.nix { inherit lib; };

  longrun.example.agreement.label       = "Are you sure?";
  longrun.example.agreement.description = "Check to confirm";
  longrun.default     = null;
  longrun.type        = optsLib.nullOrSubmoduleOf (import ./longrun.nix { inherit lib; });
  longrun.description = ''
    `longrun` are commands that run as deamon (in a infinity loop).

    Applications:
    - static site service
    - test watcher
    - some script to warn that your coffe bottle is empty
  '';
  oneshot.example.timeout       = 2000;
  oneshot.example.dependencies  = ["holyMoses"];
  oneshot.example.setup.example = "echo Hello World > $PRJ_DATA_DIR/hello.txt";
  oneshot.default     = null;
  oneshot.type        = optsLib.nullOrSubmoduleOf (import ./oneshot.nix { inherit lib; });
  oneshot.description = ''
    `oneshot` is a change in the system state

    Applications examples:
    - start other service that aren't controlled by this environment
    - mount files
    - sync sources
  '';
  bundle.example.contents  = ["myFancyServiceName"];
  bundle.example.essential = true;
  bundle.default     = null;
  bundle.type        = optsLib.nullOrSubmoduleOf (import ./bundle.nix { inherit lib; });
  bundle.description = ''
    `bundle` is a service aggregator

    For example we can bundle every system (db, http, config) by microservice.

    Like:
    - Commerce Bundle:
      - commerce database service
      - commerce api service
      - commerce cache service
    - BPMN Bundle
      - BPMN database service
      - BPMN api service
      - BPMN cache service

  '';
  enable.default     = false;
  enable.example     = true;
  enable.type        = lib.types.bool;
  enable.description = "Enable this service";
  rc-opts = { inherit bundle enable oneshot longrun; };
  rc.example.world.enable = true;
  rc.example.hola.enable  = true;
  rc.example.hello.enable = true;
  rc.example.hello.longrun.run    = "mySquirelD";
  rc.example.world.oneshot.setup  = "echo Hello World > $PRJ_DATA_DIR/hello.txt"; 
  rc.example.hola.bundle.contents = ["hello" "world"];
  rc.default       = {};
  rc.type          = lib.types.attrsOf (optsLib.submoduleOf rc-opts);
  rc.description   = ''
      Service name/command and its configuration

      - {name}.bundle  for bundles
      - {name}.oneshot for one shot activations scripts
      - {name}.longrun for deamons services

      All services are disabled by default.

      It will fail at activation time if:
      - More then onde type (bundle, oneshot, longrun) were defined for the same {name}
      - One dependency service ins't defined but required
    '';
in { options.files.rc = lib.mkOption rc; }
