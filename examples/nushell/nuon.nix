[
  "--inputFormat  (-i): string = nuon"
  "--outputFormat (-o): string = json"
  ''
    # convert formats --inputFormat|-i format --outputFormat|-o format
    $in |  if $inputFormat in [csv]      {
        from csv
    } else if $inputFormat in [eml]      {
        from eml
    } else if $inputFormat in [ics]      {
        from ics
    } else if $inputFormat in [ini]      {
        from ini
    } else if $inputFormat in [json]     {
        from json
    } else if $inputFormat in [nu nuon]  {
        from nuon
    } else if $inputFormat in [ods]      {
        from ods
    } else if $inputFormat in [ssv]      {
        from ssv
    } else if $inputFormat in [tml toml] {
        from toml
    } else if $inputFormat in [tsv]      {
        from tsv
    } else if $inputFormat in [url]      {
        from url
    } else if $inputFormat in [vcf]      {
        from vcf
    } else if $inputFormat in [xls xlsx] {
        from xlsx
    } else if $inputFormat in [xml xml]  {
        from xml
    } else if $inputFormat in [yml yaml] {
        from yaml
    } else {
        echo "Unknown inputFormat, options:"
        [[index];
          [csv ], [eml], [ics], [ini], [json], [ods], [nuon], [ssv],
          [toml], [tsv], [url], [vcf], [xlsx], [xml], [yaml]]
        exit 1
    } |    if $outputFormat in [csv]      {
        to csv
    } else if $outputFormat in [html htm] {
        to html
    } else if $outputFormat in [json]     {
        to json
    } else if $outputFormat in [md]       {
        to md
    } else if $outputFormat in [nuon nu]  {
        to nuon
    } else if $outputFormat in [toml tml] {
        to toml
    } else if $outputFormat in [tsv]      {
        to tsv
    } else if $outputFormat in [url]      {
        to url
    } else if $outputFormat in [xml]      {
        to xml
    } else if $outputFormat in [yaml yml] {
        to yaml
    } else {
        echo "Unknown outputFormat, options:"
        [[index];
          [csv],  [html], [json], [md],  [nuon], [text], 
          [toml], [tsv],  [url],  [xml], [yaml]]
        exit 1
    }
  ''
]
