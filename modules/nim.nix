{pkgs, config, lib, ...}:
let
  # Create a Nim binary
  nimFlags    = "-w:off -d:ssl --threads:on --mm:orc --hints:off --parallelBuild:4 --cc:tcc --tlsEmulation:on";
  devShellEnv = pkgs.writeTextFile {
    name = "devShellEnvs.nim";
    text = builtins.concatStringsSep "\n" (
      map ({ name, ...}: ''let ${name} = env "${name}"'') config.env
    );
  };
  writeNimWrapper = name: code:
    pkgs.runCommandCC name
    {
      inherit name code;
      laziness         = builtins.readFile ./nim/laziness.nim;
      passAsFile       = ["code" "laziness"];
      propagatedBuildInputs = [pkgs.openssl pkgs.pcre pkgs.nim pkgs.tinycc];
    }
    ''
      mkdir -p $out/nim/src/devshell
      mkdir -p $out/bin
      NAMIM=$(printf "$name"|tr -c '[:alnum:]_\n' '_')
      cp "$codePath"     "$out/nim/src/$NAMIM.nim"
      cp "$lazinessPath" "$out/nim/src/devshell/laziness.nim"
      cp ${devShellEnv}  "$out/nim/src/devshell/envs.nim"

      # compile at activation time
      if grep -qP "^#compile-at-mkshell" $codePath; then
        nim c \
          ${nimFlags} \
          --nimcache:./cache \
          --out:"$out/bin/$name" \
          "$out/nim/src/$NAMIM.nim"
        exit 0
      fi
    
      # compile at first run
      BIN_NAME=nim-$(basename $out)
      TMP_BIN=/tmp/$BIN_NAME
      echo '#!${pkgs.bash}/bin/bash -e
      if [ ! -f /nix/store/*'$BIN_NAME' ];
      then
        nim c \
          ${nimFlags} \
          --out:"'$TMP_BIN'" \
          '$out/nim/src/$NAMIM.nim'
        nix store add-file '$TMP_BIN' >/dev/null
      fi
      NIX_STORED_BIN=/nix/store/*'$BIN_NAME'
      exec \
        $NIX_STORED_BIN \
        "$@"
      ' > $out/bin/$name
      chmod +x $out/bin/$name
    '';
  nimCfg    = config.files.nim;
  nimCmds   = map nimToCmd (builtins.attrNames nimCfg);
  nimToCmd  = name: {
    inherit name;
    help    = let
      isntSH  = line: builtins.match "#!/.+" line == null;
      stripCo = line: builtins.replaceStrings ["# " "#"] ["" ""] line;
      lines   = name: lib.splitString "\n" nimCfg.${name};
    in with builtins; stripCo (head (filter isntSH (lines name)));
    package = writeNimWrapper name ''
      include devshell/laziness
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
    then map lib.getLib [ pkgs.pcre pkgs.openssl pkgs.nim pkgs.tinycc]
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
    example.hello = ''
      #compile-at-mkshell
      
      # by default nim commands were compiled at first run to reduce
      # shell activation time, add comment #compile-at-mkshell to 
      # compile at shell activation
      echo "hello"
    '';
    example.start = ''exec "docker compose up", ARGS'';
    type          = lib.types.attrsOf lib.types.string;
    description   = ''
      Nim code to create an command

      It includes some helpers and libraries for laziness

      Vars:
      - PRJ_ROOT : devshell PRJ_ROOT env information
      - ARGS     : Arguments command arguments
      - NO_ARGS  : empty arguments
      - PWD      : DirPath(".")

      Procs:
      - arg  : get arg n, defaul="", ie. `1.arg`
      - env  : get env name, default="", ie. `"PRJ_ROOT".env`
      - cd   : set current dir
      - exec : execute {cmd}, arguments=NO_ARGS, dir=".".dirPath
      - jpath: creates a JsonPath (*isn't JsonPath compliant)
        - /  : concat two paths
        - get: get JsonNode in path of object, `myPath.get(myObj)`
        - [] : get JsonNode in pat  of object, `myObj[myPath]`
        - set: set JsonNode in path of object, `myPath.set(myObj, myVal)`
        - []=: set JsonNode in path of object, `myObj[myPath] = myVal`

      [Using](https://blog.johnnovak.net/2020/12/21/nim-apocrypha-vol.-i/#6-nbsp-using-keyword:
      - sep : string
      - dir : string
      - path: JsonPath
      - obj : JsonNode

      Imports:
      - Import almost all std libraries

      Flags:
      - `${nimFlags}`

      Todo:
      - Add an option to configure flags
      - Add an option to add nimble deps
      - Add an option for static compilation
    '';
  };
  config.devshell.packages = packages;
  config.commands = nimCmds;
  config.env      = libEnv;
}
