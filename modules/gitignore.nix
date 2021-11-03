{pkgs, config, lib, ...}: 
let 
  cfg = config.files.gitignore;
  generator = pkgs.formats.${format} {};
  toFile = name: value: { source = .generate (builtins.baseNameOf name) value; };
in {
  options.files.gitignore.enable = lib.mkEnable "Auto generated .gitignore file";
  config.files.text = lib.mkIf cfg.enable {
    "/.gitignore" = ''
      ignore-something.txt
    '';
  };
}
