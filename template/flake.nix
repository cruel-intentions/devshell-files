{
  description = "My Dev Environment";

  inputs.dsf.url = "github:cruel-intentions/devshell-files";

  outputs = inputs: inputs.dsf.lib.mkShell [
    { files = { inherit inputs; }; }
    ./project.nix
  ];
}
