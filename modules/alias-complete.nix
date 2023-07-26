{pkgs, config, lib, ...}:
let
  cfg         = config.files.complete;
  toBash      = name: complete:
    pkgs.writeTextDir "share/bash-completion/completions/${name}.bash" complete;
  toFish      = name: complete:
    pkgs.writeTextDir "share/fish/vendor_completions.d/${name}.fish"   complete;
  toCompletes = name: shells:
    builtins.attrValues (
      builtins.mapAttrs (shellName: complete:
        if complete != null then (
          if shellName == "bash" 
          then toBash name complete
          else toFish name complete 
        ) else null
      ) shells
    );
  completes   = 
    builtins.foldl'
    (a: b:  a ++ b)
    []
    (builtins.attrValues (builtins.mapAttrs toCompletes cfg));
in 
lib.types.fluent{
  options.files.options.complete.default = {};
  options.files.options.complete.mdDoc   = "Auto complete for your alias or commands";
  options.files.options.complete.attrsOf.options.bash.nullOr  = lib.types.str;
  options.files.options.complete.attrsOf.options.bash.default = null;
  options.files.options.complete.attrsOf.options.fish.nullOr  = lib.types.str;
  options.files.options.complete.attrsOf.options.fish.default = null;
  options.files.options.complete.example.svcCtl.bash  = "complete -W \"$PRJ_SVCS\" svcCtl";
  options.files.options.complete.example.svcCtl.fish  = "complete -c svcCtl -a \"$PRJ_SVCS\"";
  config.devshell.packages = builtins.filter (v: v != null) completes;
}
