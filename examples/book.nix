{lib, ...}:
let
  project = "devshell-files";
  author = "cruel-intentions";
  org-url = "https://github.com/${author}";
in
{
  config.files.text."/gh-pages/src/SUMMARY.md" = ''
    # SUMMARY
    - [Introduction](./introduction.md)
    - [Installation](./installation.md)
    - [Examples](./examples.md)
    - [Modules](./modules.md)
    - [TODO](./todo.md)
    - [Issues](./issues.md)
    - [See Also](./seeAlso.md)
  '';
  config.files.text."/gh-pages/src/introduction.md" = builtins.readFile ./readme/title.md;
  config.files.text."/gh-pages/src/installation.md" = builtins.readFile ./readme/installation.md;
  config.files.text."/gh-pages/src/examples.md" = builtins.import ./readme/examples.nix;
  config.files.text."/gh-pages/src/modules.md" = builtins.import ./readme/modules.nix lib;
  config.files.text."/gh-pages/src/todo.md" = builtins.readFile ./readme/todo.md;
  config.files.text."/gh-pages/src/issues.md" = builtins.readFile ./readme/issues.md;
  config.files.text."/gh-pages/src/seeAlso.md" = builtins.readFile ./readme/seeAlso.md;
  config.files.cmds.mdbook = true;
  config.files.toml."/gh-pages/mdbook.toml" = {
    book.authors = ["Cruel Intentions <${org-url}>"];
    book.language = "en";
    book.multilingual = false;
    book.title = "Nix DevShell Files Maker";
    output.html.git-repository-url = "${org-url}/${project}";
    output.html.git-repository-icon = "fa-github";
    output.html.edit-url-template = "${org-url}/${project}/edit/master/guide/{path}";
    output.html.site-url = "/${project}/";
    output.html.no-section-label = true;
    output.html.fold.enable = true;
  };
  config.files.gitignore.pattern."gh-pages" = true;
  config.files.alias.gh-pages-it = ''
    files
    cd gh-pages
    mdbook build
    cd book
    git init
    git checkout -b gh-pages
    git add .
    git remote add origin git@github.com:${author}/${project}.git
    git commit -m "docs(gh-pages): update gh-pages" .
    git push -u origin gh-pages --force
  '';
}
