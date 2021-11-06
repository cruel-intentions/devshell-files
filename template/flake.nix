{
  description = "Dev Environment";

  inputs.devshell-files.url = "github:cruel-intentions/devshell-files";

  outputs = { self, devshell-files, nixpkgs }: devshell-files.lib.mkShell [
    ./my-project-module.nix
  ];
}
