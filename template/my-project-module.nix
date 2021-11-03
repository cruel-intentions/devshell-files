{
  config.commands = [
    { package = "devshell.cli"; }

    # for more tools search (ie. linters)
    # https://search.nixos.org/packages?query=lint
  
    # convential commit helper
    # https://github.com/convco/convco
    { package = "convco"; }
  ];
  config.files.text."/hello.txt" = "Hello World!!";
  config.files.gitignore.enable = true;
  config.files.gitignore.pattern."other-ignore-pattern" = true;
  config.files.gitignore.template."Global/Archives" = true;
  config.files.gitignore.template."Global/Backup" = true;
  config.files.gitignore.template."Global/Diff" = true;
  # we don't need it but works as example and test
  # https://github.com/github/gitignore
  config.files.gitignore.template."VisualStudio" = false;
}
