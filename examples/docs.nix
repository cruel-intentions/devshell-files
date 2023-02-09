{lib, pkgs, ...}:
{
  files.docs."/gh-pages/src/modules/alias.md".modules     = [ ../modules/alias.nix       ];
  files.docs."/gh-pages/src/modules/cmds.md".modules      = [ ../modules/cmds.nix        ];
  files.docs."/gh-pages/src/modules/files.md".modules     = [ ../modules/files.nix       ];
  files.docs."/gh-pages/src/modules/git.md".modules       = [ ../modules/git.nix         ];
  files.docs."/gh-pages/src/modules/gitignore.md".modules = [ ../modules/gitignore.nix   ];
  files.docs."/gh-pages/src/modules/hcl.md".modules       = [ ../modules/hcl.nix         ];
  files.docs."/gh-pages/src/modules/json.md".modules      = [ ../modules/json.nix        ];
  files.docs."/gh-pages/src/modules/mdbook.md".modules    = [ ../modules/mdbook.nix      ];
  files.docs."/gh-pages/src/modules/nim.md".modules       = [ ../modules/nim.nix         ];
  files.docs."/gh-pages/src/modules/nushell.md".modules   = [ ../modules/nushell.nix     ];
  files.docs."/gh-pages/src/modules/rc.md".modules        = [ ../modules/services/rc-devshell.nix ];
  files.docs."/gh-pages/src/modules/services.md".modules  = [ ../modules/services.nix    ];
  files.docs."/gh-pages/src/modules/spdx.md".modules      = [ ../modules/spdx.nix        ];
  files.docs."/gh-pages/src/modules/text.md".modules      = [ ../modules/text.nix        ];
  files.docs."/gh-pages/src/modules/toml.md".modules      = [ ../modules/toml.nix        ];
  files.docs."/gh-pages/src/modules/yaml.md".modules      = [ ../modules/yaml.nix        ];
}
