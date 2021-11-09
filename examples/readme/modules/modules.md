### Modules

Modules could be defined in two formats: Functions that return an Object or just Object without any function resulting it.

These functions has at least these nameds params: 

- `config` with all evaluated configs values, 
- `pkgs` with all [nixpkgs](https://search.nixos.org/) available.
- `lib` [library](https://teu5us.github.io/nix-lib.html#nixpkgs-library-functions) of useful functions.

And may receive other named params (use `...` to ignore them)

Nix function with named params:

```nix
{ config, pkgs, lib, ...}:  # named params fuction
{ imports = []; config = {}; options = {}; }
```

All those attributes are optional

- imports: array with paths that points to other modules
- config: object with information expected at the output (think as inputs)
- options: object with expected input definition 

We adivise you to divide your modules in at two files:
- One mostly with options, where your definition goes
- Other with config, where your information goes

It has two advantages, you could share options definitions across projects more easily.

And it hides complexity, [hiding complexity is what abstraction is all about](http://mourlot.free.fr/english/fmtaureau.html),
we didn't share options definitions across projects to type less, but because we could reuse an abstraction that helps hiding complexity.

