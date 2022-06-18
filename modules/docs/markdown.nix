moduleDocs:
let
  asString = import ./asString.nix "  ";
  ifVal = section: opt:
    if (builtins.hasAttr section opt) && opt.${section} != null then
    opt.${section}
    else "";
  ifSection = section: opt:
    if builtins.hasAttr section opt then
    ''
      #### ${section}
    
      ```nix
      {
        ${opt.name} = ${asString opt.${section} or ""};
      }
      ```
    ''
    else "";
  optionToMd = opt:
    ''
      ## ${builtins.replaceStrings ["<" ">"] ["&lt;" "&gt;"] opt.name}
    
      ${ifVal "description" opt}

      #### type

      ${opt.type}
      
      ${ifSection "example" opt}
      ${ifSection "default" opt}
    '';
  filterOpts = { name ? "", ...}: builtins.match "^_.+" name == null;
in builtins.concatStringsSep "\n" (
  builtins.map optionToMd (builtins.filter filterOpts moduleDocs)
)
