#!/usr/bin/env nu

use std [assert]

# Helper to call nushell nuon/json/yaml commands from bash/fish/zsh
# Example: printf '[1, 2, 3]'|nuon all '"{|e| $e == "foo" }"'
# Example: printf '[1, 2, 3]'|nuon all --ARGS <(printf '{|e| $e == "foo" }')
# Example: printf '[1, 2, 3]'|nuon any '"{|e| $e == "foo" }"'
# Example: printf '[1, 2, 3]'|nuon any --ARGS <(printf '{|e| $e == "foo" }')
# Example: cat records.csv|nuon columns --from csv
# Example: printf '[["foo" "bar"]; [null baz]]'|nuon compact foo
# Example: printf '[1, 2, 3]'|nuon drop yaml 2
# Example: printf '[["foo" "bar"]; [span baz]]'|nuon drop column 2
# Example: printf '[1, 2, 3]'|nuon drop nth 2
# Example: printf '[1, 2, 3]'|nuon each '"{|e| $e|str upcase }"'
# Example: printf '[1, 2, 3]'|nuon each --ARGS <(printf '{|e| $e|str upcase }')
# Example: printf '[1, 2, 3]'|nuon filter '"{|e| $e == "foo"}"'
# Example: printf '[1, 2, 3]'|nuon filter --ARGS <(printf '{|e| $e|str upcase }')
# Example: printf '[1, 2, 3]'|nuon find foo
# Example: printf '[1, 2, 3]'|nuon first 1
# Example: printf '- 1\n- 2'|nuon get --from yaml 1
# Example: printf '[1, 2, 3]'|nuon group -to yaml
# Example: printf '[1, 2, 3]'|nuon group by COLNAME
# Example: printf '[1, 2, 3]'|nuon group by --ARGS <(printf '{ path parse | get extension }')
# Example: cat table.nuon|nuon headers
# Example: printf '[1, 2, 3]'|nuon pretty 
# Example: cat object.yaml|nuon insert --from yaml  bar 'baz'
# Example: cat object.yaml|nuon insert --from yaml --ARGS <(printf 'bar {|e| $e.item.foo + $e.index }')
# Example: cat object.yaml|nuon items --from yaml '"{|k, v| [$k, $v] }"'
# Example: cat object.yaml|nuon items --from yaml --ARGS <(printf '{|k, v| [$k, $v] }')
# Example: printf '[1, 2, 3]'|nuon last 1
# Example: cat data.csv|nuon lines
# Example: cat object.yaml|nuon merge --from yaml { foo: bar }
# Example: printf '[1, 2, 3]'|nuon range --from yaml 2..4
# Example: printf "[1 2 3 4 5]"|nuon reduce '"{|it, acc| $it + $acc }"'
# Example: printf "[1 2 3 4 5]"|nuon reduce --ARGS <(printf '{|it, acc| $it + $acc }')
# Example: printf "[[a b]; [1, 2]]"|nuon rename foo bar
# Example: printf "[1, 2]"|nuon reverse
# Example: printf "[1, 2, 3, 4, 5]"|nuon shuffle
# Example: printf "[4, 3, 5, 1, 2]"|nuon sort
# Example: printf "[[num,alpha];[4,d],[3,c],[5,e], [1,a], [2,b]]"|nuon sort by alpha
# Example: printf "4,3,5,1,2"|nuon split column ,
# Example: printf "4,3,5,1,2"|nuon split rows ,
# Example: printf '[1, 2, 3]'|nuon take 1
# Example: printf '[1, 2, 3]'|nuon where '"{|e| $e != "foo" }"'
# Example: printf '[1, 2, 3]'|nuon where --ARGS <(printf '{|e| $e != "foo" }')
def main [
  subcmd:      string = ''       # subcommand [all,any,columns,compact,drop,each,filter,find,first,from,get,group,group-by,headers,insert,items,last,lines,merge,pretty,range,reduce,rename,reverse,shuffle,sort, sort-by,split,take,to,where]
  --from (-f): string = "nuon",  # stdin format [csv,eml,ics,ini,json,nuon,ods,ssv,toml,tsv,url,vcf,xlsx,xml,yaml,yml] 
  --to   (-t): string = "nuon",  # stdout format [csv,html,json,md,nuon,text,toml,tsv,xml,yaml,table]
  --ARGS:      string = '',      # read args from file
  --IN:        string = '',      # read file instead of stdin
  ...args:     string,           # read args from params
] {
  assert ($subcmd != '') "No subcommand provided." --error-label {
    text: "Please inform a subcommand, use --help for examples",
    start: (metadata $subcmd).span.start, end: (metadata $subcmd).span.end,
  }

  let knownCmds = [
    "all","any","columns","compact","drop","each",
    "filter","find","first","from","get","group", "group-by"
    "headers","insert","items","last","lines","merge",
    "pretty","range","reduce","rename","reverse",
    "shuffle","sort", "sort-by","split","take","to","where"
  ]
  assert ($subcmd in $knownCmds) $"Unknown subcommand ($subcmd)." --error-label {
    text: $"expected subcommand: [($knownCmds | str join '|' )]"
    start: (metadata $subcmd).span.start, end: (metadata $subcmd).span.end
  }
  let knownFromFmts = [
    "csv","eml","ics","ini","json",
    "nuon","ods","ssv","toml","tsv",
    "url","vcf","xlsx","xml","yaml","yml",
  ]
  assert ($from in $knownFromFmts) $"Unknown format ($from)." --error-label {
    text: $"expected formats: [($knownFromFmts | str join '|' )]"
    start: (metadata $from).span.start, end: (metadata $from).span.end
  }
  let knownToFmts = [
    "csv","html","json","md","nuon",
    "text","toml","tsv","xml","yaml",
    "table"
  ]
  assert ($to in $knownToFmts) $"Unknown format ($to)."  --error-label {
    text: $"expected formats: [($knownToFmts | str join '|' )]"
    start: (metadata $to).span.start, end: (metadata $to).span.end
  }

  let hasIN   = (bash -c "[ ! -t 0 ] && printf true || printf false")
  assert ($hasIN == 'true' or $IN != '') "STDIN is empty. Pipe to stdin or use --IN"  --error-label {
    text: "Example: nuon take 1 --IN <(printf '[1, 2, 3]') or Example: printf '[1, 2, 3]'|nuon take 1"
    start: (metadata $IN).span.start, end: (metadata $IN).span.end
  }

  let stdIn   = if $IN   == ''                  { "$in"     } else { $"open ($IN)" }
  let fArgs   = if $ARGS == ''                  { ""        } else { open $ARGS }
  let cmd     = if $subcmd in ["from", "to"]    { ""        } else { $"($subcmd) ($args|str join ' ') ($fArgs)|"}
  let fromCMD = if $subcmd in ["split" "lines"] { ""        } else { $"from ($from)|" } 
  let toCMD   = if $to     in ["table"]         { "table"   } else { $"to ($to)" }

  nu --stdin -c $"($stdIn)|($fromCMD)($cmd)($toCMD)"
}
