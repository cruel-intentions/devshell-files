{ pkgs, lib, config, flu, ...}:
let
  pkgs-old = (import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/293a28df6d7ff3dec1e61e37cc4ee6e6c0fb0847.tar.gz";
    sha256 = "1m6smzjz3agkyc6dm83ffd8zr744m6jpjmffppvcdngk82mf3s3r";
  }) { system = pkgs.system; }).extend flu.overlays.default;
  nmd-src = builtins.fetchGit {
    url = "https://git.sr.ht/~rycee/nmd";
    rev = "07a6db31ae19d728ef1e4dc02b9687a6c359c216";
  };
  nmd = pkgs.callPackage nmd-src { };
  module-docs = name: cfg:
    let 
      setup-module = args: {
        imports = [{
          _module.check = false;
          _module.args.lib  = lib;
          _module.args.pkgs = lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
        }];
      };
      buildModulesDocs = pkgs-old.callPackage "${nmd-src}/lib/modules-doc.nix" { };
      docs = buildModulesDocs {
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
    options.evalModulesArgs = lib.mkOption {
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
