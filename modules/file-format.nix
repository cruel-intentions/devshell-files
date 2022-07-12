format: {pkgs, config, lib, ...}: 
let
  yj-args.hcl  = "-jc";
  yj-args.json = "-jji";
  yj-args.toml = "-jt";
  yj-args.yaml = "-jy";
  yj-arg = yj-args.${format};
  cfg    = config.files.${format};
  type   = (pkgs.formats.json {}).type;
  gen    = name: value: pkgs.runCommand ".dsf${lib.strings.sanitizeDerivationName name}" {
    nativeBuildInputs = [ pkgs.yj ];
    passAsFile        = [ "value" ];
    value             = builtins.toJSON value;
  } ''yj ${yj-arg} < $valuePath > $out'';
  toFile = name: value: {
    source  = gen name value;
    git-add = lib.mkIf config.files.git.auto-add true;
  };
in {
  options.files.${format} = lib.mkOption {
    default     = {};
    description = ''Create ${format} files with correponding content'';
    type        = lib.types.attrsOf type;
    example."/hellaos.${format}".greeting  = "hello World";
    example."/hellows.${format}".greetings = [ ["Hello World"] ["Ola Mundo" ["Holla Que Tal"]]];
  };
  config.file = lib.mapAttrs toFile cfg;
}
