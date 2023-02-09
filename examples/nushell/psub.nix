[
  "shed: string"
  ''
    # creates a psudo file using sh
    # https://mywiki.wooledge.org/Bashism#Expansions
    # https://github.com/nushell/nushell/issues/4320
    bash -c $"printf <( ($shed) )"
  ''
]
