[
  "--inputFormat  (-i): string = nuon"
  "--outputFormat (-o): string = json"
  ''
    # convert formats --inputFormat|-i format to --outputFormat|-o format
    if $inputFormat in [csv]             {
        $in | from csv
    } else if $inputFormat in [json]     {
        $in | from json
    } else if $inputFormat in [nu nuon]  {
        $in | from nuon
    } else if $inputFormat in [ods]      {
        $in | from ods
    } else if $inputFormat in [ssv]      {
        $in | from ssv
    } else if $inputFormat in [tml toml] {
        $in | from toml
    } else if $inputFormat in [tsv]      {
        $in | from tsv
    } else if $inputFormat in [url]      {
        $in | from url
    } else if $inputFormat in [xls xlsx] {
        $in | from xlsx
    } else if $inputFormat in [xml xml]  {
        $in | from xml
    } else if $inputFormat in [yml yaml] {
        $in | from yaml
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
    } else if $outputFormat in [text] {
        to text
    } else if $outputFormat in [toml tml] {
        to toml
    } else if $outputFormat in [tsv]      {
        to tsv
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
