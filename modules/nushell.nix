{pkgs, config, lib, ...}:
let
  cfg     = config.files.nus;
  stripCo = line: builtins.replaceStrings ["# " "#"] ["" ""] line;
  toArgs  = name:
  if builtins.typeOf cfg.${name} == "string" then
    ""
  else
    builtins.concatStringsSep "\n\n" (lib.lists.init cfg.${name});
  toMain  = name:
  if builtins.typeOf cfg.${name} == "string" then
    cfg.${name}
  else
    lib.lists.last cfg.${name};
  lines   = name: lib.splitString "\n" (toMain name);
  toSrc   = name: builtins.concatStringsSep "\n    "(lines name);
  toAlias = name: {
    inherit name;
    help    = with builtins; stripCo (head (lines name));
    command = ''
      #!${pkgs.nushell}/bin/nu --stdin
      source ${nuLib}
      def main [
        ${toArgs name}
      ] {
        ${toSrc  name}
      }
    '';
  };
  toProc  = name: ''
    def ${name} [
      ${toArgs name}
    ] {
      ${toSrc  name}
    }
  '';
  nuLibSrc = ''
    ${builtins.concatStringsSep "\n\n" (map toProc (builtins.attrNames cfg))}
  '';
  nuLibNam = builtins.hashString "sha256" nuLibSrc;
  nuLib    = builtins.toFile nuLibNam nuLibSrc;
  nus      = map toAlias (builtins.attrNames cfg);
in {
  options.files.nus = lib.mkOption {
    default       = {};
    description   = ''[Nushell](https://www.nushell.sh/book/command_reference.html) script to create an alias.'';
    type          = with lib.types; attrsOf (oneOf [string (listOf string)]);
    example.hello = ["name" "{hello: $name}"];
    example.world = ''
      # it could use previous commands
      hello world
    '';
  };
  config.commands = nus;
}
