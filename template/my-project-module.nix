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
}
