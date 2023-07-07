{ config, lib, ...}:
let
  cfg     = config.files.watch;
  toAlias = n: v: ''
    # Run `${builtins.replaceStrings ["\n"] [";"]  v.cmd}` 
    # When ${builtins.replaceStrings ["\n"] [", "] v.files} changes

    trap 'kill -15 $(ps --ppid '$$' -o pid=|tr "\\n" " ")' exit

    cat - << EOWFI |
    ${v.files}
    EOWFI
    inotifywait                  ${
        lib.optionalString (v.exclude  != "")      " \\\n  --exclude   '${v.exclude }'"}${
        lib.optionalString (v.excludei != "")      " \\\n  --excludei  '${v.excludei}'"}${
        lib.optionalString (v.include  != "")      " \\\n  --include   '${v.include }'"}${
        lib.optionalString (v.includei != "")      " \\\n  --includei  '${v.includei}'"}${
        lib.optionalString  v.recursive            " \\\n  --recursive                "}${
        lib.optionalString  v.event.access         " \\\n  --event      access        "}${
        lib.optionalString  v.event.attrib         " \\\n  --event      attrib        "}${
        lib.optionalString  v.event.close          " \\\n  --event      close         "}${
        lib.optionalString  v.event.create         " \\\n  --event      create        "}${
        lib.optionalString  v.event.delete         " \\\n  --event      delete        "}${
        lib.optionalString  v.event.modify         " \\\n  --event      modify        "}${
        lib.optionalString  v.event.move           " \\\n  --event      move          "}${
        lib.optionalString  v.event.open           " \\\n  --event      open          "}${
        lib.optionalString  v.event.unmount        " \\\n  --event      unmount       "}${
        lib.optionalString  v.event.move_from      " \\\n  --event      move_from     "}${
        lib.optionalString  v.event.move_to        " \\\n  --event      move_to       "}${
        lib.optionalString  v.event.close_nonwrite " \\\n  --event      close_nonwrite"}${
        lib.optionalString  v.event.close_write    " \\\n  --event      close_nwrite  "} \
      --monitor                   \
      --timefmt   '${v.timefmt}'  \
      --format    '%f %w %T %e'   \
      --fromfile  -              |\
    while read -r file dir time events; do
      ${v.cmd}
    done
  '';
  toSvc   = n: v: v.enable;
in
{
  imports = [
    ./interface.nix
  ];
  files.cmds     = lib.mkIf (builtins.length (builtins.attrNames cfg) > 0) { inotify-tools = true; };
  files.alias    = builtins.mapAttrs toAlias cfg;
  files.services = builtins.mapAttrs toSvc   cfg;
}
