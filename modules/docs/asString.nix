initalIdent: value:
let
  str  = ident: v:
    if builtins.isNull (builtins.match ".*\n.*" v) 
    then ''"${v}"''
    else
    ''
      ${"''"}
      ${ident}  ${builtins.replaceStrings ["\n"] ["\n${ident}  "] v}
      ${ident}${"''"}'';
  lvObj = ident: v: ''${ident}${asString ident v}'';
  arr   = ident: v:
    if builtins.length v  == 0
    then "[]"
    else
    ''
      [
      ${builtins.concatStringsSep "\n" (map (lvObj "${ident}  ") v)}
      ${ident}]'';
  keyQuote = k:
    if builtins.isNull (builtins.match ".*[ .'+=$%¨*()!@#/].*" k)
    then k
    else ''"${k}"'';
  kvObj = ident: k: v: ''${ident}${keyQuote k} = ${asString ident v};'';
  attrsAsList = f: v: builtins.attrValues (builtins.mapAttrs f v);
  obj = ident: v:
    if builtins.length (builtins.attrNames v) == 0 
    then "{}"
    else
    ''
      {
      ${builtins.concatStringsSep "\n" (attrsAsList (kvObj "${ident}  ") v)}
      ${ident}}'';
  asString = ident: v: 
    if builtins.stringLength ident > 100 then "..." # try avoid infinity loop
    else if builtins.isAttrs  v && v ? "_type" && v._type == "literalExpression" then builtins.replaceStrings ["\n"] ["\n${ident}"] v.text
    else if builtins.isString v then str ident v
    else if builtins.isList   v then arr ident v
    else if builtins.isAttrs  v then obj ident v
    else    ''${builtins.toJSON v}'';
in asString initalIdent value
