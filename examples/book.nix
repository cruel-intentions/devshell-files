{lib, ...}:
let
  project = "devshell-files";
  author = "cruel-intentions";
  org-url = "https://github.com/${author}";
  edit-path = "${org-url}/${project}/edit/master/guide/{path}";
in
{
  config.files.mdbook.enable = true;
  config.files.mdbook.authors = ["Cruel Intentions <${org-url}>"];
  config.files.mdbook.language = "en";
  config.files.mdbook.gh-author = author;
  config.files.mdbook.gh-project = project;
  config.files.mdbook.multilingual = false;
  config.files.mdbook.title = "Nix DevShell Files Maker";
  config.files.mdbook.output.html.fold.enable = true;
  config.files.mdbook.output.html.no-section-label = true;
  config.files.mdbook.output.html.site-url = "/${project}/";
  config.files.mdbook.output.html.git-repository-icon = "fa-github";
  config.files.mdbook.output.html.git-repository-url = "${org-url}/${project}";
  config.files.mdbook.output.html.edit-url-template = edit-path;
  config.files.mdbook.summary = builtins.readFile ./summary.md;
  config.files.text."/gh-pages/src/introduction.md" = builtins.readFile ./readme/about.md;
  config.files.text."/gh-pages/src/installation.md" = builtins.readFile ./readme/installation.md;
  config.files.text."/gh-pages/src/examples.md" = builtins.import ./readme/examples.nix;
  config.files.text."/gh-pages/src/modules.md" = "## Writing new modules";
  config.files.text."/gh-pages/src/nix-lang.md" = builtins.readFile ./readme/modules/nix-lang.md;
  config.files.text."/gh-pages/src/json-nix.md" = builtins.import ./readme/modules/json-vs-nix.nix lib;
  config.files.text."/gh-pages/src/module-spec.md" = builtins.readFile ./readme/modules/modules.md;
  config.files.text."/gh-pages/src/share.md" = builtins.readFile ./readme/modules/share.md;
  config.files.text."/gh-pages/src/document.md" = builtins.import ./readme/modules/document.nix;
  config.files.text."/gh-pages/src/todo.md" = builtins.readFile ./readme/todo.md;
  config.files.text."/gh-pages/src/issues.md" = builtins.readFile ./readme/issues.md;
  config.files.text."/gh-pages/src/seeAlso.md" = builtins.readFile ./readme/seeAlso.md;
  config.files.text."/gh-pages/src/modules-docs.md" = ''## Builtin Modules'';
  config.files.gitignore.pattern."gh-pages" = true;
}
