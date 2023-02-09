{ pkgs, config, lib, ... }:
let
  files     = config.file;
  fileType  = (import ./file-type.nix { inherit pkgs config lib; }).fileType;
  chmod     = file:
    if file.executable == null
      then ""
      else if file.executable
        then "chmod +x $target"
        else "chmod -x $target";
  git-add   = file:
    if file.git-add == null
      then ""
      else if file.git-add
        then "git add $target"
        else "";
  toName    = name: ".dsf${lib.strings.sanitizeDerivationName name}";
  # Execute this script to update the project's files
  copy-file = name: file: pkgs.writeShellScriptBin "${toName name}" ''
    target="$PRJ_ROOT${file.target}"
    ${pkgs.coreutils}/bin/install -m 644 -D ${file.source} $target
    ${chmod file}
    ${git-add file}
  '';
  cmd.command     = builtins.concatStringsSep "\n" startups;
  cmd.help        = "Recreate files";
  cmd.name        = "devshell-files";
  opt.default     = {};
  opt.description = "Attribute set of files to create into the project root.";
  opt.type        = fileType "<envar>PRJ_ROOT</envar>";
  startup.devshell-files.text = "$DEVSHELL_DIR/bin/devshell-files";
  startups  = map (name: "source $DEVSHELL_DIR/bin/${toName name}") (builtins.attrNames files);
in {
  options.file    = lib.mkOption opt;
  config.commands = lib.mkIf (builtins.length startups > 0) [ cmd ];
  config.devshell.packages = lib.mapAttrsToList copy-file files;
  config.devshell.startup  = lib.mkIf (builtins.length startups > 0) startup;
}
