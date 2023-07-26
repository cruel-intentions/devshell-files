set -l knownCmds \
  all any columns compact drop each filter \
  find first from get group group-by headers insert items last lines merge \
  par-each range reduce rename reverse shuffle sort sort-by split table take to where

set -l fromFmts \
    csv eml ics ini json  \
    nuon ods ssv toml tsv \
    url vcf xlsx xml yaml yml

set -l toFmts \
    csv html json md nuon  \
    text toml tsv xml yaml table

complete -c nuon         -f   -a "$knownCmds" -n "not __fish_seen_subcommand_from $knownCmds"
complete -c nuon -l from -s f -a "$fromFmts"
complete -c nuon -l to   -s t -a "$toFmts"
complete -c nuon -l ARGS -F
complete -c nuon -l IN   -F
