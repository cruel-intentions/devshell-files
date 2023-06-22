# Shell alias to use nushell utilities from bash command
{
  files.nush.nuon = {
    fetch = ["--from: string = json" "--to: string = nuon" "url: string" ''
      # convert stdin to $to from $from
      nu --stdin -c $"http get -r '($url)'|from ($from)|to ($to)"
    ''];
    from  = ["--to: string = nuon" "from: string = json" ''
      # convert stdin from $from to $o
      nu --stdin -c $"$in|from ($from)|to ($to)"
    ''];
    to    = ["--from: string = nuon" "to: string = json" ''
      # convert stdin to $to from $from
      nu --stdin -c $"$in|from ($from)|to ($to)"
    ''];
    all   = ["--from: string = nuon" "...args" ''
      # Test if every element of the input fulfills a predicate expression.
      # Example: cat list.yaml|nuon all --from yaml '"{|e| $e == "foo" }"'
      nu --stdin -c $"$in|from ($from)|all ($args|str join ' ')|to nuon"
    ''];
    any   = ["--from: string = nuon" "...args" ''
      # Test if any element of the input fulfills a predicate expression.
      # Example: cat list.yaml|nuon any --from yaml '"{|e| $e == "foo" }"'
      nu --stdin -c $"$in|from ($from)|any ($args|str join ' ')|to nuon"
    ''];
    columns = ["--from: string = nuon" ''
      # Given a record or table, produce a list of its columns' names.
      # Example: cat records.csv|nuon columns --from csv
      nu --stdin -c $"$in|from ($from)|columns|to nuon"
    ''];
    compact = ["--from: string = nuon" "...args" ''
      # Filter row with where COLNAME is empty
      # Example: echo [["foo" "bar"]; [null baz]]|nuon compact foo
      nu --stdin -c $"$in|from ($from)|compact ($args|str join ' ')|to nuon"
    ''];
    drop  = ["--from: string = nuon" "n: int = 1" ''
      # Remove items/rows from the end of the stdin list/table.
      # Example: cat list.yaml|nuon drop --fron yaml 2
      nu --stdin -c $"$in|from ($from)|drop ($n)|to nuon"
    ''];
    "drop column"  = ["--from: string = nuon" "n: int = 1" ''
      # Remove columns from the end of the stdin table.
      # Example: cat table.nuon|nuon drop column 2
      nu --stdin -c $"$in|from ($from)|drop column ($n)|to nuon"
    ''];
    "drop nth"  = ["--from: string = nuon" "...args" ''
      # Remove line N from the stdin table/list.
      # Example: cat list.yaml|nuon drop nth --fron yaml 2
      nu --stdin -c $"$in|from ($from)|drop nth ($args|str join ' ')|to nuon"
    ''];
    each  = ["--from: string = nuon" "...args" ''
      # run a command on each item.
      # Example: cat list.yaml|nuon each --fron yaml '"{|e| $e|str upcase }"'
      nu --stdin -c $"$in|from ($from)|each ($args|str join ' ')|to nuon"
    ''];
    filter= ["--from: string = nuon" "...args" ''
      # Filter item based on a predicate.
      # Example: cat list.yaml|nuon each --fron yaml '"{|e| $e == "foo"}"'
      nu --stdin -c $"$in|from ($from)|filter ($args|str join ' ')|to nuon"
    ''];
    find  = ["--from: string = nuon" "...args" ''
      # Find items.
      # Example: cat list.yaml|nuon find --fron yaml foo
      nu --stdin -c $"$in|from ($from)|find ($args|str join ' ')|to nuon"
    ''];
    first = ["--from: string = nuon" "n: int = 1" ''
      # Return only the first n elements of a list.
      # Example: cat list.yaml|nuon first --fron yaml 1
      nu --stdin -c $"$in|from ($from)|first ($n)|to nuon"
    ''];
    get   = ["--from: string = nuon" "...args" ''
      # Extract data using a path.
      # Example: cat hello.yaml|nuon get --fron yaml baz
      nu --stdin -c $"$in|from ($from)|get ($args|str join ' ')|to nuon"
    ''];
    group = ["--from: string = nuon" "n: int = 2" ''
      # Split a list in N elements.
      # Example: cat list.yaml|nuon group --fron yaml
      nu --stdin -c $"$in|from ($from)|group ($n)|to nuon"
    ''];
    "group by" = ["--from: string = nuon" "...args" ''
      # Group elements by expression.
      # Example: cat list.yaml|nuon group by --fron yaml COLNAME
      nu --stdin -c $"$in|from ($from)|group-by ($args|str join ' ')|to nuon"
    ''];
    headers = ["--from: string = nuon" ''
      # Use the first row of the table as column names.
      # Example: cat table.nuon|nuon headers
      nu --stdin -c $"$in|from ($from)|headers"
    ''];
    pretty = ["--from: string = nuon" ''
      # convert stdin to table from $from
      # Example: cat list.yaml|nuon pretty --from yaml
      nu --stdin -c $"$in|from ($from)|table --expand"
    ''];
    insert = ["--from: string = nuon" "...args" ''
      # Insert a new column, using an expression.
      # Example: cat object.yaml|nuon insert --fron yaml  bar 'baz'
      nu --stdin -c $"$in|from ($from)|insert ($args|str join ' ')|to nuon"
    ''];
    items = ["--from: string = nuon" "...args" ''
      # Iterate on each pair of column name and associated value.
      # Example: cat object.yaml|nuon items --fron yaml '"{|k, v| [$k, $v] }"'
      nu --stdin -c $"$in|from ($from)|items ($args|str join ' ')|to nuon"
    ''];
    last = ["--from: string = nuon" "n: int = 1" ''
      # Return only the last n elements of a list.
      # Example: cat list.yaml|nuon last --fron yaml 1
      nu --stdin -c $"$in|from ($from)|last ($n)|to nuon"
    ''];
    lines = ["...args" ''
      # Convert string to list.
      # Example: cat data.csv|nuon lines
      nu --stdin -c $"$in|lines ($args|str join ' ')|to nuon"
    ''];
    merge = ["--from: string = nuon" "...args" ''
      # Merge two objects.
      # Example: cat object.yaml|nuon merge --fron yaml { foo: bar }
      nu --stdin -c $"$in|from ($from)|merge ($args|str join ' ')|to nuon"
    ''];
    range = ["--from: string = nuon" "...args" ''
      # Take the range from list.
      # Example: cat list.yaml|nuon range --fron yaml 2..4
      nu --stdin -c $"$in|from ($from)|range ($args|str join ' ')|to nuon"
    ''];
    reduce = ["--from: string = nuon" "...args" ''
      # Apply expression to result of previous line.
      # Example: echo "[1 2 3 4 5]"|nuon reduce '"{|it, acc| $it + $acc }"'
      nu --stdin -c $"$in|from ($from)|reduce ($args|str join ' ')|to nuon"
    ''];
    rename = ["--from: string = nuon" "...args" ''
      # Rename table columns.
      # Example: echo "[[a b]; [1, 2]]"|nuon rename foo bar
      nu --stdin -c $"$in|from ($from)|rename ($args|str join ' ')|to nuon"
    ''];
    reverse = ["--from: string = nuon" "...args" ''
      # Reverse table lines.
      # Example: echo "[1, 2]"|nuon reverse
      nu --stdin -c $"$in|from ($from)|reverse ($args|str join ' ')|to nuon"
    ''];
    shuffle = ["--from: string = nuon" "...args" ''
      # Shuffle table lines.
      # Example: echo "[1, 2, 3, 4, 5]"|nuon shuffle
      nu --stdin -c $"$in|from ($from)|shuffle ($args|str join ' ')|to nuon"
    ''];
    sort = ["--from: string = nuon" "...args" ''
      # Sort table lines.
      # Example: echo "[4, 3, 5, 1, 2]"|nuon sort
      nu --stdin -c $"$in|from ($from)|sort ($args|str join ' ')|to nuon"
    ''];
    "sort by"= ["--from: string = nuon" "...args" ''
      # Sort table lines by column.
      # Example: echo "[[num,alpha];[4,d],[3,c],[5,e], [1,a], [2,b]]"|nuon sort by alpha
      nu --stdin -c $"$in|from ($from)|sort-by ($args|str join ' ')|to nuon"
    ''];
    "split column" = ["separator: string = ''" "...args" ''
      # Split string int columns.
      # Example: echo "4,3,5,1,2"|nuon split column ,
      nu --stdin -c $"$in|split column ($separator) ($args|str join ' ')|to nuon"
    ''];
    "split rows" = ["separator: string = ''" "...args" ''
      # Split string int columns.
      # Example: echo "4,3,5,1,2"|nuon split rows ,
      nu --stdin -c $"$in|split rows ($separator) ($args|str join ' ')|to nuon"
    ''];
    take  = ["--from: string = nuon" "...args" ''
      # Take only the first n elements of a list, or the first n bytes of a binary value.
      # Example: cat list.yaml|nuon take --fron yaml 1
      nu --stdin -c $"$in|from ($from)|take ($args|str join ' ')|to nuon"
    ''];
    where = ["--from: string = nuon" "...args" ''
      # Filter values based on a row condition.
      # Example: cat list.yaml|nuon where --from yaml '"{|e| $e != "foo" }"'
      nu --stdin -c $"$in|from ($from)|where ($args|str join ' ')|to nuon"
    ''];
  };
}
