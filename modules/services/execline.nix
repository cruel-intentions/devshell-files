let
  block      = cmd: 
  ''
    {
      ${cmd}
    }'';
  unBlockIf  = type: cmd: if type == "if" then cmd else block cmd;
  case       = value: cmds: with builtins;
  ''
    ${type} ${value} {
      ${concatStringsSep "\n" (
        map (n: "  \"${n}\" { ${cmds.${n}} }") (attrNames cmds) 
      )}
    }'';
  multiSub   = subs : with builtins;
  ''
    multisubstitute {
      ${concatStringsSep "\n" (map (s: "  ${s}") subs)}
    }'';
in rec {
  inherit block case multiSub; 
  backtick'   = flags: var: do "backtick ${flags} ${var}";
  backtick  = var: backtick' "";
  background = bg;
  bg         = do "background";
  bg'        = do "background -d";
  cd         = dir: "execline-cd ${dir}";
  cmdExist   = cmd: 
    ''
      ${outToNul}
        ${errToOut}
        which ${cmd}'';
  define'    = flags: var: val: "elglob ${flags} ${var} ${val}";
  define     = define' "";
  do         = type: cmd: ''${type} ${block cmd}'';
  dollarAt   = flags: "dollarat ${flags}";
  errToOut   = "fdmove -c 2 1";
  execBang   = execline: "#!${execline}/bin/execlineb -P";
  export     = var: value: "export ${var} ${value}";
  fg         = do "foreground";
  foreground = fg;
  forX'      = flags: var: args: ''forx ${flags} ${var} ${block args}'';
  forX       = forX' "";
  forExec'   = flags: var: gen: ''forbacktickx ${flags} ${var} ${block gen}'';
  forExec    = forExec' "";
  forStdIn'  = flags: var: ''forstdin ${flags} ${var}'';
  forStdIn   = forStdIn' "";
  getopt'    = opt: "elgetopt ${opt}";
  getopt     = getopt "";
  glob'      = flags: var: pattern: "elglob ${flags} ${var} ${pattern}";
  glob       = glob' "";
  hasCmd     = type: cmd: do type (cmdExist cmd);
  hasCmdRun  = type: cmd: ''${hasCmd type cmd} ${unBlockIf type cmd}'';
  hereDoc    = txt: "heredoc ${txt}";
  ifThen'    = flags: do "if ${flags}";
  ifThen     = ifThen' "";
  ifTe'      = flags: Then: Else: ''${do "ifte ${flags}" Then} ${block Else}'';
  ifTe       = ifTe' "";
  ifThenElse'= flags: cond: Then: Else: ''${do "ifthenelse ${flags}" cond} ${block Then} ${block Else}'';
  ifThenElse = ifThenElse' "";
  ifElse'    = flags: cond: Then: ''${do "ifelse ${flags}" cond} ${block Then}'';
  ifElse     = ifElse' "";
  getEnv'    = flags: var: importAs' flags var var;
  getEnv     = getEnv' "";
  importAs'  = flags: var: env: "importas ${flags} ${var} ${env}";
  importAs   = importAs' "";
  loopWhile' = flags: ''loopwhilex ${flags}'';
  loopWhile  = loopWhile "";
  multiDef'  = flags: val: vars: "multidefine ${flags} ${val} { ${vars} }";
  multiDef   = multiDef' "";
  outToNul'  = cmd: "${redirfd "/dev/null"} ${cmd}";
  outToNul   = outToNul' "";
  pipeline'  = flags: do "pipeline ${flags}";
  pipeline   = pipeline' "";
  positional = flags: "elgetpositionals ${flags}";
  shift'     = flags: "shift ${flags}";
  shift      = shift' "";
  redirfd'   = flags: fd: file: "redirfd ${flags} ${toString fd} \"${file}\"";
  redirfd    = redirfd' "-w" 1;
  unexport   = var: "unexport ${var}";
}
