{pkgs, config, lib, ...}: 
let 
  cfg = config.files.license;
  spdxLicenses = builtins.fetchTarball {
    url = "https://github.com/cruel-intentions/license-list-data/releases/download/v3.14/text.tar.gz";
    sha256 = "0s5jizc28kipgc26vp0n3bn3nrp4146v92aypwm5a19fs2a33zrj";
  };
  templateFile = name: builtins.readFile "${spdxLicenses}/${name}.txt";
  placeholders = vars: map (name: "<${name}>") (builtins.attrNames vars);
  values = vars: builtins.attrValues vars;
  replaceVars = license: vars: builtins.replaceStrings (placeholders vars) (values vars) license;
in {
  options.files.license.enable = lib.mkEnableOption "auto generated license file";
  options.files.license.spdx = lib.mkOption {
    type = lib.types.submodule {
      options.name = lib.mkOption {
        type = lib.types.str;
        description = "SPDX text name without extension";
        example = "MIT";
      };
      options.vars = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Most SPDX templates has some placeholders like &lt;OWNER&gt;, it is case sensitive";
        default = {};
        example = {
          "year" = "2021";
          "OWNER" = "cruel-intentions";
          "yyyy, yyyy" = "2021, 2099";
          "URL for Development Group/Institution" = "https://github.com/cruel-intentions";
        };
      };
    };
    description = "Use SPDX as template https://github.com/spdx/license-list-data/tree/master/text";
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
        find ${spdxLicenses}/ -name '*.txt' \
        | sed "s#${spdxLicenses}/##" \
        | sed "s#\.txt##" \
        | sort
      '';
    }
  ];
  config.files.text = lib.mkIf cfg.enable {
    "/LICENSE" = replaceVars (templateFile cfg.spdx.name) cfg.spdx.vars;
  };
}
