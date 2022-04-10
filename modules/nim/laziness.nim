import std/[
  algorithm,
  asyncdispatch,
  asyncfile,
  asyncnet,
  asyncstreams,
  base64,
  browsers,
  distros,
  enumerate,
  enumutils,
  hashes,
  htmlparser,
  httpclient,
  json,
  jsonutils,
  math,
  md5,
  mimetypes,
  oids,
  options,
  os,
  osproc,
  parsecfg,
  parsecsv,
  parsesql,
  parsexml,
  posix,
  posix_utils,
  random,
  re,
  sequtils,
  sets,
  setutils,
  sha1,
  streams,
  strformat,
  strutils,
  sugar,
  tables,
  terminal,
  threadpool,
  times,
  uri,
  with,
]

## SHELL HELPERS
proc arg(n: int; default: string = ""): string =
  result = default
  if paramCount() >= n:
    result = n.paramStr

proc arg(n: int; default: JsonNode): string =
  var defaultVal = default.getStr $default
  arg n, defaultVal

proc env(name: string; default: string = ""): string =
  getEnv name, default

proc env(name: JsonNode; default: string = ""): string =
  getEnv name.getStr($name), default

proc env(name: JsonNode; default: JsonNode): string =
  getEnv name.getStr($name), default.getStr($default)

let 
  ARGS     = commandLineParams().mapIt it.quoteShell
  PRJ_ROOT = env "PRJ_ROOT"

proc cd(dir: string): void =
  setCurrentDir dir

proc cmd(cmdName: string; arguments: seq[string] = @[]; dir: string = "."): int =
  execShellCmd fmt"""cd {dir}; {cmdName} {arguments.join " "} """

proc cmd(cmdName: string; dir: string = "."): int =
  execShellCmd fmt"""cd {dir}; {cmdName}"""


## JSON HELPERS
type JsonPath = distinct seq[string]

proc jPath(path: string; sep: char = '/'): JsonPath =
  JsonPath path.split(sep)

proc `$`(path: JsonPath; sep: char = '/'): string =
  cast[seq[string]](path).join($sep)

proc `&`(path: JsonPath; complement: JsonPath): JsonPath {.borrow.}

proc `/`(path: JsonPath; complement: JsonPath): JsonPath =
  path & complement

proc `/`(path: JsonPath; complement: string; sep: char = '/'): JsonPath =
  path / complement.jPath(sep)

proc get(path: JsonPath; obj: JsonNode; default: JsonNode = newJNull()): JsonNode =
  result = obj
  for trace in cast[seq[string]](path):
    result = result.getOrDefault trace
  if result.isNil:
    result = default

proc `[]`(obj: JsonNode; path: JsonPath): JsonNode =
  path.get obj

proc set(path: JsonPath; obj: JsonNode; val: JsonNode): void =
  var 
    lastObj   = obj
    traces    = cast[seq[string]](path)
    tracesLen = traces.len
  for (n, trace) in enumerate(1, traces):
    var nextObj = lastObj.getOrDefault(trace)
    if n == tracesLen:
      lastObj[trace] = val
      break

    if nextObj.isNil or nextObj.kind != JObject:
      nextObj = newJObject()
    lastObj[trace] = nextObj
    lastObj = nextObj

proc `[]=`(obj: JsonNode; path: JsonPath; val: JsonNode): void =
  path.set obj, val

proc `[]=`(obj: JsonNode; path: JsonPath; val: string): void =
  path.set obj, %* val

proc `[]=`(obj: JsonNode; path: JsonPath; val: enum): void =
  path.set obj, %* val

proc `[]=`(obj: JsonNode; path: JsonPath; val: SomeInteger): void =
  path.set obj, %* val

proc `[]=`(obj: JsonNode; path: JsonPath; val: SomeFloat): void =
  path.set obj, %* val

proc `[]=`(obj: JsonNode; path: JsonPath; val: bool): void =
  path.set obj, %* val
