{ pkgs, lib, config,...}:
let
  nmd-src = builtins.fetchTarball {
    url    = "https://gitlab.com/hugosenari/nmd/-/archive/evalModulesArgs/nmd-evalModulesArgs.tar.bz2";
    sha256 = "1qkzkx1nxpfvpcvxsfy2fzsalh6gcrrpnnijwpmfbpwg2v2s98ww";
  };
  nmd = pkgs.callPackage nmd-src {};
  module-docs = name: cfg:
    let 
      setup-module = args: {
        imports = [{
          _module.check = false;
          _module.args.pkgs = lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
        }];
      };
      buildModulesDocs = pkgs.callPackage "${nmd-src}/lib/modules-doc.nix" {
        evalModulesArgs = cfg.args;
      };
      docs = nmd.buildModulesDocs {
        channelName     = "";
        docBook         = {};
        mkModuleUrl     = path: path;
        moduleRootPaths = [ ./. ];
        modules         = cfg.modules ++ [ setup-module ];
      };
      docsData = (import cfg.mapper) docs.optionsDocs;
    in 
    if cfg.format != "text" then docsData
    else (import cfg.template) docsData;
  docs-info = lib.types.submodule {
    options.format = lib.mkOption {
      default     = "text";
      description = "format of documentation";
      example     = "json";
      type        = lib.types.enum ["json" "toml" "yaml" "hcl" "text"];
    };
    options.modules = lib.mkOption {
      description = "modules (paths, functions, attrset) to be documented";
      example     = [ ./modules/gitignore.nix ];
      type        = lib.types.nonEmptyListOf lib.types.anything;
    };
    options.args = lib.mkOption {
      default     = {};
      description = "evalModules arguments for module load";
      example     = { inputs = { }; pkgs = {}; lib = {}; };
      type        = lib.types.anything;
    };
    options.mapper = lib.mkOption {
      default     = ./docs/indentity.nix;
      example     = ./docs/indentity.nix;
      type        = lib.types.path;
      description = ''
        Path of nix files with function that
        receives `moduleDocs`
        and returns anything
        to be converted as JSON, TOML, YAML or TEXT
      '';
    };
    options.template = lib.mkOption {
      default     = ./docs/markdown.nix;
      example     = ./docs/markdown.nix;
      type        = lib.types.path;
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
  configs  = config.files.docs;
  ofFormat = format: cfgs: lib.filterAttrs (n: cfg: cfg.format == format) cfgs;
in
{
  options.files.docs = lib.mkOption {
    default     = {};
    example."/docs/gitignore.md".modules = [ ./gitignore.nix ];
    description = "attrsOf <docPath, module-info>";
    type        = lib.types.attrsOf docs-info;
  };
  config.files.hcl  = builtins.mapAttrs module-docs (ofFormat "hcl"  configs);
  config.files.json = builtins.mapAttrs module-docs (ofFormat "json" configs);
  config.files.text = builtins.mapAttrs module-docs (ofFormat "text" configs);
  config.files.toml = builtins.mapAttrs module-docs (ofFormat "toml" configs);
  config.files.yaml = builtins.mapAttrs module-docs (ofFormat "yaml" configs);
}
