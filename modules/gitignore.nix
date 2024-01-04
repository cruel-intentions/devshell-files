{pkgs, config, lib, ...}: 
let 
  cfg = config.files.gitignore;
  enabledAttrs = lib.filterAttrs (name: value: value) cfg.pattern;
  patterns = builtins.attrNames enabledAttrs;
  toList = names: lib.ca;
  githubIgnore = builtins.fetchGit {
    url = "https://github.com/github/gitignore";
    ref = "main";
    rev = "4488915eec0b3a45b5c63ead28f286819c0917de";
  };
  enabledTemplates = builtins.attrNames (lib.filterAttrs (name: value: value) cfg.template);
  templatePatterns = map (name: builtins.readFile "${githubIgnore}/${name}.gitignore") enabledTemplates;
in {
  options.files.gitignore.enable = lib.mkEnableOption "Auto generated .gitignore file";
  options.files.gitignore.pattern = lib.mkOption {
    type = lib.types.attrsOf lib.types.bool;
    description = "Gitignore pattern to ignore";
    default = {};
    example = {
      "ignore-this-file.txt" = true;
    };
  };
  options.files.gitignore.template = lib.mkOption {
    type = lib.types.attrsOf lib.types.bool;
    description = "Append gitignore template from https://github.com/github/gitignore";
    default = {};
    example = {
      Android = true;
      "community/AWS/SAM" = true;
    };
  };
  config.commands = lib.mkIf cfg.enable [
    {
      help = "list available ignore templates";
      package = pkgs.writeShellScriptBin "files-ignore-templates" ''
        echo "Available Git Ignore Templates:"
        find ${githubIgnore} -name '*.gitignore' \
        | sed "s#${githubIgnore}/##" \
        | sed "s#\.gitignore##" \
        | sort
      '';
    }
  ];
  config.files.text = lib.mkIf cfg.enable {
    "/.gitignore" = builtins.concatStringsSep "\n" (
      patterns ++ templatePatterns
    );
  };
}
