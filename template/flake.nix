{
  description = "Dev Environment";

  inputs.dsf.url = "github:cruel-intentions/devshell-files";

  outputs = inputs: inputs.dsf.lib.mkShell [ ./project.nix ];
}
