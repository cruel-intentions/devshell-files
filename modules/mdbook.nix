{lib, pkgs, config, ...}:
let 
  cfg = config.files.mdbook;
  isntEmptyAttrs = v: lib.mkIf (builtins.length (builtins.attrNames v) > 0) v;
in
{
  options.files.mdbook = lib.mkOption {
    description = ''
      Helps with mdbook creation https://rust-lang.github.io/mdBook/

      by default it creates gh-pages/mdbook.toml and gh-pages/src/SUMMARY.md

      It also create publish-as-gh-pages helper

      <details>
      <summary>Full configuration example</summary>
      <br>


      ```nix
      #examples/book.nix

      ${builtins.readFile ../examples/book.nix}
      ```


      </details>
    '';
    type = lib.types.submodule {
      options.enable = lib.mkEnableOption "mdbook module";
      options.root-dir = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "root path of book";
        example = "/gh-pages";
        default = "/gh-pages";
      };
      options.gh-author = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Github Owner";
        example = "cruel-intentions";
        default = null;
      };
      options.gh-project = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Github project";
        example = "devshell-files";
        default = null;
      };
      options.title = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Book title";
        example = "Devshell Files Modules";
        default = null;
      };
      options.description = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Desciption of this book";
        example = "Modules Docummentation";
        default = null;
      };
      options.summary = lib.mkOption {
        type = lib.types.lines;
        description = "Summary of our mkdbook";
        default = ''
          # SUMMARY
        '';
        example = ''
          # SUMMARY
          - [Intro](./intro.md)
        '';
      };
      options.authors = lib.mkOption {
        type = lib.types.nullOr (lib.types.nonEmptyListOf lib.types.str);
        description = "Book author";
        example = ["Cruel Intentions"];
        default = null;
      };
      options.language = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;
        description = "Book language";
        example = "en";
        default = null;
      };
      options.multilingual = lib.mkOption {
        type = lib.types.bool;
        description = "If book has multilingual support";
        example = true;
        default = false;
      };
      options.use-default-preprocessor = lib.mkOption {
        type = lib.types.bool;
        description = "Disable the default preprocessors";
        example = false;
        default = true;
      };
      options.build = lib.mkOption {
        type = lib.types.submodule {
          freeformType = (pkgs.formats.json {}).type;
        };
        default = {};
        description = "mdbook output options";
        example.build-dir = "book";
      };
      options.rust = lib.mkOption {
        type = lib.types.submodule {
          freeformType = (pkgs.formats.json {}).type;
        };
        default = {};
        description = "mdbook rust options";
        example.edition = "2018";
      };
      options.preprocessor = lib.mkOption {
        type = lib.types.submodule {
          freeformType = (pkgs.formats.json {}).type;
        };
        default = {};
        description = "mdbook preprocessor options";
        example.mathjax.renderers = ["html"];
      };
      options.output = lib.mkOption {
        type = lib.types.submodule {
          freeformType = (pkgs.formats.json {}).type;
        };
        default = {};
        description = "mdbook output options";
        example.html.fold.enable = true;
      };
    };
  };
  config.files.cmds.mdbook = lib.mkIf cfg.enable true;
  config.files.gitignore.pattern."${cfg.root-dir}/src/SUMMARY.md" = lib.mkIf cfg.enable true;
  config.files.text = lib.mkIf cfg.enable {
    "${cfg.root-dir}/src/SUMMARY.md" = cfg.summary;
  };
  config.files.toml = lib.mkIf cfg.enable {
    "${cfg.root-dir}/mdbook.toml" = {
      book.title = cfg.title;
      book.authors = cfg.authors;
      book.language = cfg.language;
      book.description = cfg.description;
      build = isntEmptyAttrs cfg.build;
      rust = isntEmptyAttrs cfg.rust;
      preprocessor = isntEmptyAttrs cfg.preprocessor;
      output = isntEmptyAttrs cfg.output;
    };
  };
  config.files.alias.publish-as-gh-pages = lib.mkIf cfg.enable ''
    files
    cd .${cfg.root-dir}
    mdbook build
    cd book
    git init
    git checkout -b gh-pages
    git add .
    git remote add origin git@github.com:${cfg.gh-author}/${cfg.gh-project}.git
    git commit -m "docs(gh-pages): update gh-pages" .
    git push -u origin gh-pages --force
  '';
}
