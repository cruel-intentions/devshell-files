{ pkgs, lib, config,...}:
let
  nmd-src = pkgs.fetchFromGitLab {
    name = "nmd";
    owner = "rycee";
    repo = "nmd";
    rev = "2398aa79ab12aa7aba14bc3b08a6efd38ebabdc5";
    sha256 = "0yxb48afvccn8vvpkykzcr4q1rgv8jsijqncia7a5ffzshcrwrnh";
  };
  module-docs = name: cfg:
    let 
      cfgPkgs =
        if cfg.pkgs == null 
        then builtins.trace "pkgs default" pkgs 
        else builtins.trace "pkgs from config" cfg.pkgs;
      cfgLib  =
        if cfg.lib  == null
        then builtins.trace "libs default" cfgPkgs.lib
        else builtins.trace (builtins.attrNames cfg.lib) cfg.lib;
      nmd = import nmd-src { pkgs = cfgPkgs; lib  = cfgLib; };
      setup-module = args: {
        imports = [{
          _module.check = false;
          _module.args = {
            pkgs = cfgLib.mkForce (
              nmd.scrubDerivations "pkgs" cfgPkgs
            );
            pkgs_i686 = cfgLib.mkForce { };
          };
        }];
      };
      docs = nmd.buildModulesDocs {
        modules = cfg.modules; # ++ [ setup-module ];
        moduleRootPaths = [ ./. ];
        mkModuleUrl = path: path;
        channelName = "";
        docBook = {};
      };
      docsData = (import cfg.mapper) docs.optionsDocs;
    in 
    if cfg.format != "text" then docsData
    else (import cfg.template) docsData;
  docs-info = lib.types.submodule {
    options.format = lib.mkOption {
      type = lib.types.enum ["json" "toml" "yaml" "hcl" "text"];
      description = "format of documentation";
      example = "json";
      default = "text";
    };
    options.modules = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.anything;
      description = "modules (paths, functions, attrset) to be documented";
      example = [ ./modules/gitignore.nix ];
    };
    options.lib = lib.mkOption {
      type = lib.types.nullOr lib.types.anything;
      description = "lib to be used in documentation";
      default = null;
      example = {};
    };
    options.pkgs = lib.mkOption {
      type = lib.types.nullOr lib.types.anything;
      description = "pkgs to be used in documentation";
      default = null;
      example = {};
    };
    options.mapper = lib.mkOption {
      type = lib.types.path;
      default = ./docs/indentity.nix;
      example = ./docs/indentity.nix;
      description = ''
        Path of nix files with function that
        receives `moduleDocs`
        and returns anything
        to be converted as JSON, TOML, YAML or TEXT
      '';
    };
    options.template = lib.mkOption {
      type = lib.types.path;
      default = ./docs/markdown.nix;
      example = ./docs/markdown.nix;
      description = ''
        Only used when format is `text`
        Path of nix file with function that
        receives `moduleDocs`
        and returns a string

        if your are not sure of what `moduleDocs` has
        use yaml as format instead
      '';
    };
  };
  configs = config.files.docs;
  ofFormat = format: cfgs: lib.filterAttrs (n: cfg: cfg.format == format) cfgs;
in
{
  options.files.docs = lib.mkOption {
    type = lib.types.attrsOf docs-info;
    description = "attrsOf <docPath, module-info>";
    default = {};
    example."/docs/gitignore.md".modules = [ ./gitignore.nix ];
  };
  config.files.hcl  = builtins.mapAttrs module-docs (ofFormat "hcl"  configs);
  config.files.json = builtins.mapAttrs module-docs (ofFormat "json" configs);
  config.files.text = builtins.mapAttrs module-docs (ofFormat "text" configs);
  config.files.toml = builtins.mapAttrs module-docs (ofFormat "toml" configs);
  config.files.yaml = builtins.mapAttrs module-docs (ofFormat "yaml" configs);
}
