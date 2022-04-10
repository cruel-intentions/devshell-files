{lib, ...}:
let
  project   = "devshell-files";
  author    = "cruel-intentions";
  org-url   = "https://github.com/${author}";
  edit-path = "${org-url}/${project}/edit/master/guide/{path}";
in
{
  files.mdbook.authors      = ["Cruel Intentions <${org-url}>"];
  files.mdbook.enable       = true;
  files.mdbook.gh-author    = author;
  files.mdbook.gh-project   = project;
  files.mdbook.language     = "en";
  files.mdbook.multilingual = false;
  files.mdbook.summary      = builtins.readFile ./summary.md;
  files.mdbook.title        = "Nix DevShell Files Maker";
  files.mdbook.output.html.edit-url-template   = edit-path;
  files.mdbook.output.html.fold.enable         = true;
  files.mdbook.output.html.git-repository-icon = "fa-github";
  files.mdbook.output.html.git-repository-url  = "${org-url}/${project}";
  files.mdbook.output.html.no-section-label    = true;
  files.mdbook.output.html.site-url            = "/${project}/";
  files.text."/gh-pages/src/introduction.md" = builtins.readFile ./readme/about.md;
  files.text."/gh-pages/src/installation.md" = builtins.readFile ./readme/installation.md;
  files.text."/gh-pages/src/examples.md"     = builtins.import   ./readme/examples.nix;
  files.text."/gh-pages/src/modules.md"      = "## Writing new modules";
  files.text."/gh-pages/src/nix-lang.md"     = builtins.readFile ./readme/modules/nix-lang.md;
  files.text."/gh-pages/src/json-nix.md"     = builtins.import   ./readme/modules/json-vs-nix.nix lib;
  files.text."/gh-pages/src/module-spec.md"  = builtins.readFile ./readme/modules/modules.md;
  files.text."/gh-pages/src/share.md"        = builtins.readFile ./readme/modules/share.md;
  files.text."/gh-pages/src/document.md"     = builtins.import   ./readme/modules/document.nix;
  files.text."/gh-pages/src/builtins.md"     = builtins.readFile ./readme/modules/builtins.md;
  files.text."/gh-pages/src/todo.md"         = builtins.readFile ./readme/todo.md;
  files.text."/gh-pages/src/issues.md"       = builtins.readFile ./readme/issues.md;
  files.text."/gh-pages/src/seeAlso.md"      = builtins.readFile ./readme/seeAlso.md;
  files.gitignore.pattern.gh-pages      = true;
  files.alias.publish-as-gh-pages-local = ''
    # same as publish-as-gh-pages but works local
    ORIGIN=`git remote get-url origin`
    cd gh-pages
    mdbook build
    cd book
    git init .
    git add .
    git checkout -b gh-pages
    git commit -m "docs(gh-pages): update gh-pages" .
    git remote add origin $ORIGIN
    git push -u origin gh-pages --force
  '';  
}
