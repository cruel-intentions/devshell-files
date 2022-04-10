{pkgs, config, lib, ...}:
let
  # Create a Nim binary
  nimFlags    = "--threads:on --gc:orc -d:release --opt:speed --hints:off -w:off -d:ssl";
  writeNimBin = name: code:
    pkgs.runCommandCC name
    {
      inherit name code;
      executable = true;
      buildInputs = [pkgs.nim pkgs.openssl.dev];
      propagatedBuildInputs = [pkgs.openssl pkgs.pcre pkgs.nim];
      passAsFile = ["code"];
      # Pointless to do this on a remote machine.
      preferLocalBuild = true;
      allowSubstitutes = false;
    }
    ''
    n=$out/bin/$name
      mkdir -p "$(dirname "$n")"
    mv "$codePath" code.nim
    nim c \
      ${nimFlags} \
      --nimcache:./cache -o:"$n" code.nim
    '';
  nimCfg    = config.files.nim;
  nimCmds   = map nimToCmd (builtins.attrNames nimCfg);
  nimToCmd  = name: {
    inherit name;
    help    = builtins.head (lib.splitString "\n" nimCfg.${name});
    package = writeNimBin name ''
      ${builtins.readFile ./nim/laziness.nim}
      ${nimCfg.${name}}
    '';
  };
  getLib    = pkg: {
    name    = pkg.name;
    help    = pkg.description or pkg.name;
    package = lib.getLib pkg;
  };
  hasAnyNim = builtins.length nimCmds > 0;
  packages  = 
    if hasAnyNim
    then map lib.getLib [ pkgs.pcre pkgs.openssl ]
    else [];
  libEnv    = 
    if hasAnyNim 
    then 
    [
      {
        name   = "LD_LIBRARY_PATH";
        prefix = "$DEVSHELL_DIR/lib";
      }
    ]
    else [];
in {
  options.files.nim = lib.mkOption {
    default       = {};
    example.hello = ''echo "hello"'';
    example.start = ''quit cmd("docker compose up", ARGS)'';
    type          = lib.types.attrsOf lib.types.string;
    description   = ''
      Nim code to create an command

      It includes some helpers and libraries for laziness

      It compiles with:

      `${nimFlags}`

      Vars:
      - PRJ_ROOT : devshell PRJ_ROOT env information
      - ARGS     : seq[string] command arguments

      Procs:
      - arg  : get arg n, defaul="", ie. `1.arg`
      - env  : get env name, default="", ie. `"PRJ_ROOT".env`
      - cd   : set current dir
      - cmd  : execute {cmd}, arguments=@[], dir="."
      - jpath: creates a JsonPath (*isn't JsonPath compliant)
        - /  : concat two paths
        - get: get JsonNode in path of object, `myPath.get(myObj)`
        - [] : get JsonNode in pat  of object, `myObj[myPath]`
        - set: set JsonNode in path of object, `myPath.set(myObj, myVal)`
        - []=: set JsonNode in path of object, `myObj[myPath] = myVal`

      Imports:
      - Import almost all std libraries

      Todo:
      - Add an option to configure flags
      - Add an option to add nimble deps
      - Add an option for static compilation

      Note:

      Since nim cmds were compiled the shell activation time may increase
    '';
  };
  config.devshell.packages = packages;
  config.commands = nimCmds;
  config.env      = libEnv;
}