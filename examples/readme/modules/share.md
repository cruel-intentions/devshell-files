### Sharing our module

Now to not just copy and past it everywhere, we could create a git repository. Ie. [gh-actions](https://github.com/cruel-intentions/gh-actions)

Then we could let nix manage it for us adding it to flake.nix file like

```nix
{
  description = "Dev Environment";

  inputs.dsf.url = "github:cruel-intentions/devshell-files";
  inputs.gha.url = "github:cruel-intentions/gh-actions";
  # for private repository use git url
  # inputs.gha.url = "git+ssh://git@github.com/cruel-intentions/gh-actions.git";

  outputs = inputs: inputs.dsf.lib.mkShell [
    "${inputs.gha}/gh-actions.nix"
    ./project.nix
  ];
}
```
