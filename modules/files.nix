{ pkgs, config, lib, ... }:
let
  files     = config.file;
  fileType  = (import ./file-type.nix { inherit pkgs config lib; }).fileType;
  chmod     = file:
    if file.executable == null
      then ""
      else if file.executable
        then ''chmod +x "$PRJ_ROOT${file.target}"''
        else ''chmod -x "$PRJ_ROOT${file.target}"'';
  git-add   = file:
    if file.git-add == null
      then ""
      else if file.git-add
        then ''git add "$PRJ_ROOT${file.target}"''
        else "";
  toName    = name: ".dsf${lib.strings.sanitizeDerivationName name}";
  # Execute this script to update the project's files
  copy-files = map (name: "source $DEVSHELL_DIR/bin/${toName name}") (builtins.attrNames files);
  copy-files'= lib.mapAttrsToList (name: file: if file.on-enter then "source $DEVSHELL_DIR/bin/${toName name}" else "")  files;
  copy-file  = name: file: pkgs.writeShellScriptBin "${toName name}" ''
    ${pkgs.coreutils}/bin/install -m 644 -D ${file.source} "$PRJ_ROOT${file.target}"
    ${chmod file}
    ${git-add file}
  '';
  cmd.command     = builtins.concatStringsSep "\n" copy-files;
  cmd.help        = "Recreate files";
  cmd.name        = "devshell-files";
  opt.default     = {};
  opt.description = "Attribute set of files to create into the project root.";
  opt.type        = fileType "<envar>PRJ_ROOT</envar>";
  startup.devshell-files.text = builtins.concatStringsSep "\n" copy-files';
in {
  options.file    = lib.mkOption opt;
  config.commands = lib.mkIf (builtins.length copy-files > 0) [ cmd ];
  config.devshell.packages = lib.mapAttrsToList copy-file files;
  config.devshell.startup  = lib.mkIf (builtins.length copy-files > 0) startup;
}
