moduleDocs:
let
  asString = import ./asString.nix "";
  ifSection = section: opt:
    if builtins.hasAttr section opt then
    ''
      **${section}**
    
      ```nix
      ${asString opt.${section} or ""}
      ```
    ''
    else "";
  optionToMd = opt:
    ''
      #### ${opt.name}
    
      ${opt.description}
    
      ${ifSection "example" opt}
      ${ifSection "default" opt}
    '';
in builtins.concatStringsSep "\n" (builtins.map optionToMd moduleDocs)
