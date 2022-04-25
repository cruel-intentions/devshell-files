# jsonildo {operation} {path} {filePath} [{newData}]
# operation = get | set | filter
# filePath  = ./some-json-file.json
# newData   = json as string to parse as new value
# path      = 
#   for json {foo: {bar: {baz: ["hello"]}}}:
#   foo

let 
  operation = 1.arg
  myJPath   = 2.arg.jPath
  fName     = 3.arg
  jDataNew  = 4.arg
  jData     = fname.parseFile

if operation == "get":
  echo jData[myJPath].pretty

if operation == "set":
  jData[myJPath] = jDataNew.parseJson
  echo jData.pretty

if operation == "filter":
  echo myJPath.filter jData

# our path could be incremented like below

discard myJPath / "some" / 5 / 'c' / 0 .. 2 / 1 .. ^1
