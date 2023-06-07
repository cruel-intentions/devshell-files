{pkgs, config, lib, ...}:
let
  cfg     = config.files.nus;
  cfg'    = config.files.nush;
  stripCo = line: builtins.replaceStrings ["# " "#"] ["" ""] line;
  toArgs  = def:
  if builtins.typeOf def == "string" then
    ""
  else
    builtins.concatStringsSep "\n\n" (lib.lists.init def);
  toMain  = def:
  if builtins.typeOf def == "string" then
    def
  else
    lib.lists.last def;
  lines   = def: lib.splitString           "\n"     (toMain def);
  toSrc   = def: builtins.concatStringsSep "\n    " (lines  def);
  toAlias'= name: sub: rec {
    inherit name;
    help    = "${name} (${builtins.concatStringsSep "|" (builtins.attrNames sub)})";
    command = ''
      ${pkgs.nushell}/bin/nu --stdin -c \
      "$(printf "let IN = \$in\nsource ${nuLib}\n\$IN|${name} $*")"
    '';
  };
  toProc  = name: def: ''
    def "${name}" [
      ${toArgs def}
    ] {
      ${toSrc  def}
    }
  '';
  toProc' = name: sub: 
      builtins.concatStringsSep "\n\n" (builtins.attrValues (builtins.mapAttrs (n: d: toProc "${name} ${n}" d) sub));
  nuLibSrc = ''
    ${builtins.concatStringsSep "\n\n" (builtins.attrValues (builtins.mapAttrs toProc  cfg ))}
    ${builtins.concatStringsSep "\n\n" (builtins.attrValues (builtins.mapAttrs toProc' cfg'))}
  '';
  nuLibNam = builtins.hashString "sha256" nuLibSrc;
  nuLib    = builtins.toFile     nuLibNam nuLibSrc;
  nus      = builtins.attrValues (builtins.mapAttrs toAlias' cfg');
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
  config.commands = nus;
}
