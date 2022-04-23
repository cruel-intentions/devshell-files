{.experimental: "notnil".}

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

type Arguments = distinct seq[string]

proc args(args: seq[string]): Arguments =
  cast[Arguments](args)

proc args(args: string): Arguments =
  cast[Arguments](args.split " ")

let 
  ARGS     = args commandLineParams()
  NO_ARGS  = args @[]

type DirPath = distinct string

proc dirPath(dir: string): DirPath =
  DirPath dir

let
  PWD = dirPath $CurDir

include envs

let
  PRJ_ROOT = dirPath env "PRJ_ROOT"

using dir: DirPath

proc `$`(dir): string =
  cast[string](dir).expandFilename

proc `/`(dir; other: string): DirPath {.borrow.}

proc `/`(dir; other: DirPath): DirPath {.borrow.}

proc cd(dir): void =
  setCurrentDir $dir

using args: Arguments

proc toSeq(args): seq[string] =
  cast[seq[string]](args)

proc `$`(args): string =
  args.toSeq.mapIt(it.quoteShell).join(" ")

proc `[]`(args; slice: HSlice): Arguments =
  cast[Arguments](args.toSeq()[slice])

proc exec(cmdName: string; args = NO_ARGS; dir = PWD): bool {.discardable.} =
  cd dir
  discard execvp(cmdName.cstring, allocCStringArray args.toSeq);

proc exec(cmdName: string; dir): bool {.discardable.} =
  exec(cmdName, NO_ARGS, dir)

## JSON HELPERS
type JsonPath = distinct seq[string]

using sep: char

proc jPath(path: string; sep = '/'): JsonPath =
  JsonPath path.split(sep)

using path: JsonPath

proc `$`(path; sep = '/'): string =
  cast[seq[string]](path).join($sep)

proc `&`(path; complement: JsonPath): JsonPath {.borrow.}

proc `/`(path; complement: JsonPath): JsonPath =
  path & complement

proc `/`(path; complement: string; sep = '/'): JsonPath =
  path / complement.jPath(sep)

using obj: JsonNode

proc get(path; obj; default: JsonNode = newJNull()): JsonNode =
  result = obj
  for trace in cast[seq[string]](path):
    result = result.getOrDefault trace
  if result.isNil:
    result = default

proc `[]`(obj; path): JsonNode =
  path.get obj

proc set(path; obj: JsonNode; val: JsonNode): void =
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

proc `[]=`(obj; path; val: JsonNode): void =
  path.set obj, val

proc `[]=`(obj; path; val: string): void =
  path.set obj, %* val

proc `[]=`(obj; path; val: enum): void =
  path.set obj, %* val

proc `[]=`(obj; path; val: SomeInteger): void =
  path.set obj, %* val

proc `[]=`(obj; path; val: SomeFloat): void =
  path.set obj, %* val

proc `[]=`(obj; path; val: bool): void =
  path.set obj, %* val
