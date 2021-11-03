{pkgs, config, lib, ...}: 
let 
  cfg = config.files.gitignore;
  enabledAttrs = lib.filterAttrs (name: value: value) cfg.pattern;
  patterns = builtins.attrNames enabledAttrs;
  toList = names: lib.ca;
  githubIgnore = builtins.fetchGit {
    url = "https://github.com/github/gitignore";
    rev = "cdd9e946da421758c6f42c427c7bc65c8326155d";
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
    description = "Gitignore template from github/gitignore";
    default = {};
    example = {
      Android = true;
      "community/AWS/SAM" = true;
    };
  };
  config.files.text = lib.mkIf cfg.enable {
    "/.gitignore" = builtins.concatStringsSep "\n" (
      patterns ++ templatePatterns
    );
  };
}
