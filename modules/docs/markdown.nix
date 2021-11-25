moduleDocs:
let
  asString = import ./asString.nix "  ";
  ifSection = section: opt:
    if builtins.hasAttr section opt then
    ''
      **${section}**
    
      ```nix
      {
        config.${opt.name} = ${asString opt.${section} or ""};
      }
      ```
    ''
    else "";
  optionToMd = opt:
    ''
      #### config.${builtins.replaceStrings ["<" ">"] ["&gt;" "&lt;"] opt.name}
    
      ${opt.description}

      **type**

      ${opt.type}
      
      ${ifSection "example" opt}
      ${ifSection "default" opt}
    '';
in builtins.concatStringsSep "\n" (builtins.map optionToMd moduleDocs)
