{
  files.nush.nuon = {
    from = ["--to: string = nuon" "from: string = json" ''
      # convert stdin from $from to $o
      if (to == 'table') { 
        nu --stdin -c $"$in|from ($from)
      else {
        nu --stdin -c $"$in|from ($from)|to ($to)"
      }
    ''];
    to   = ["--from: string = nuon" "to: string = json" ''
      # convert stdin to $to from $from
      if (to == 'table') { 
        nu --stdin -c $"$in|from ($from)
      else {
        nu --stdin -c $"$in|from ($from)|to ($to)"
      }
    ''];
    where = ["...args" ''
      nu --stdin -c $"$in|from nuon|where ($args)|to nuon"
    ''];
  };
}
