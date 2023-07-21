{pkgs, config, lib, ...}:
let
  cfg      = config.files.nus;
  cfg'     = config.files.nush;
  onlyCo   = line: let r = builtins.match "^\s*([#].+)" line; in if r == null then "" else builtins.head r;
  nonEmpty = line: line != "";
  toDoc    = def: builtins.concatStringsSep "\n" (builtins.filter nonEmpty (map onlyCo (lines def)));
  toArgs   = def:
  if builtins.typeOf def == "string" then
    ""
  else
    builtins.concatStringsSep "\n\n" (lib.lists.init def);
  toMain   = def:
  if builtins.typeOf def == "string" then
    def
  else
    lib.lists.last def;
  lines    = def: lib.splitString           "\n" (toMain def);
  toSrc    = def: builtins.concatStringsSep "\n" (lines  def);
  toAlias' = name: sub: rec {
    inherit name;
    help    = "${name} (${builtins.concatStringsSep "|" (builtins.attrNames sub)})";
    command = ''
      READIN=$([ ! -t 0 ] && printf "cat /proc/self/fd/0 | " || printf "")
      export NUSH_LIB=${nuLib}
      NL=$'\n'
      exec ${pkgs.nushell}/bin/nu  -c "\
      source ${nuLib}\
      ''${NL}let-env NUSH_LIB = "${nuLib}"\
      ''${NL}$READIN ${name} $*"
    '';
  };
  toProc   = name: def: ''
    ${toDoc def}
    def "${name}" [
      ${toArgs def}
    ] {
      ${toSrc  def}
    }
  '';
  toProc'  = name: sub: 
    builtins.concatStringsSep "\n\n" (builtins.attrValues (builtins.mapAttrs (n: d: toProc "${name} ${n}" d) sub));
  toProc'' = name: sub: ''
    # ${name} [${builtins.concatStringsSep "|" (builtins.attrNames sub)}]
    def "${name}" [
      ...subcommand
    ] {
      let span = (metadata $"${name} ($subcommand)").span
      error make { 
        msg:   "Unknown subcommand"
        label: {
          text: "expected: ${name} [${builtins.concatStringsSep "|" (builtins.attrNames sub)}]",
          start: $span.start, end: $span.end
        }
      }
    }
  '';
  nuLibSrc = ''
    ${builtins.concatStringsSep "\n\n" (builtins.attrValues (builtins.mapAttrs toProc   cfg ))}
    ${builtins.concatStringsSep "\n\n" (builtins.attrValues (builtins.mapAttrs toProc'  cfg'))}
    ${builtins.concatStringsSep "\n\n" (builtins.attrValues (builtins.mapAttrs toProc'' cfg'))}
  '';
  nuLibNam = builtins.hashString "sha256" nuLibSrc;
  nuLib    = builtins.toFile     nuLibNam nuLibSrc;
  nus      = builtins.attrValues (builtins.mapAttrs toAlias' cfg') ;
in {
  options.files.nush = lib.mkOption {
    default       = {};
    description   = ''[Nushell](https://www.nushell.sh/book/command_reference.html) script to create an alias.'';
    type          = with lib.types; attrsOf (attrsOf (oneOf [string (listOf string)]));
    example.hello.en = ["arg" "{hello: $arg}"];
    example.hello.pt = ["arg" "{ola: $arg}"];
    example.world.hello = ''
      # it could use previous commands
      hello en "World"
      hello pt "Mundo"
    '';
  };
  config.commands = nus ++ (lib.optional (builtins.length nus > 0) {
    name    = "nush";
    help    = "Run nushell with your functions loaded";
    command = ''
      #!${pkgs.nushell}/bin/nu
      exec nu -e "source ${nuLib};let-env NUSH_LIB = '${nuLib}'"
    '';
  });
}
