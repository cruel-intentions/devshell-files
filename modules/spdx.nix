{pkgs, config, lib, ...}: 
let 
  cfg = config.files.license;
  spdxLicenses = builtins.fetchGit {
    url = "https://github.com/spdx/license-list-data";
    rev = "0372e9ca9d2ae9a86eb8581ec75cd58a266200ff";
  };
  templateFile = name: builtins.readFile "${spdxLicenses}/text/${name}.txt";
  placeholders = vars: map (name: "<${name}>") (builtins.attrNames vars);
  values = vars: builtins.attrValues vars;
  replaceVars = license: vars: builtins.replaceStrings (placeholders vars) (values vars) license;
in {
  options.files.license.enable = lib.mkEnableOption "Auto generated license file";
  options.files.license.spdx = lib.mkOption {
    type = lib.types.submodule {
      options.name = lib.mkOption {
        type = lib.types.str;
        description = "SPDF text name without extension";
        example = "MIT";
      };
      options.vars = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Most SPDF templates has some placeholders like <OWNER>, it is case sensitive";
        example = {
          "year" = "2021";
          "OWNER" = "cruel-intentions";
          "yyyy, yyyy" = "2021, 2099";
          "URL for Development Group/Institution" = "https://github.com/cruel-intentions";
        };
      };
    };
    description = "Use SPDF as template https://github.com/spdx/license-list-data/tree/master/text";
    default = {};
    example = {
      name = "MIT";
      vars = {
        year = "2021";
        "copyright holders" = "Cruel Intentions";
      };
    };
  };
  config.commands = lib.mkIf cfg.enable [
    {
      help = "list available SPDX Licenses";
      package = pkgs.writeShellScriptBin "files-spdx-licenses" ''
        echo "Available SPDX Licenses:"
        find ${spdxLicenses}/text/ -name '*.txt' \
        | sed "s#${spdxLicenses}/text/##" \
        | sed "s#\.txt##" \
        | sort
      '';
    }
  ];
  config.files.text = lib.mkIf cfg.enable {
    "/LICENSE" = replaceVars (templateFile cfg.spdx.name) cfg.spdx.vars;
  };
}
