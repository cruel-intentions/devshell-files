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
  pegs,
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

proc env(name: string; default: string = ""): string =
  getEnv name, default

proc env(name: JsonNode; default: string = ""): string =
  getEnv name.getStr($name), default

proc env(name: JsonNode; default: JsonNode): string =
  getEnv name.getStr($name), default.getStr($default)

proc arg(n: int; default: string = ""): string =
  result = default
  if paramCount() >= n:
    result = n.paramStr

proc arg(n: int; default: JsonNode): string =
  var defaultVal = default.getStr $default
  arg n, defaultVal

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

when fileExists "./envs.nix":
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

proc `+`(args, other: Arguments): Arguments =
  cast[Arguments](concat(args.toSeq, other.toSeq))

proc `+`(arg: string, args): Arguments =
  args(@[arg]) + args

proc `+`(args, arg: string): Arguments =
  args + args(@[arg])

proc exec(cmdName: string; args = NO_ARGS; dir = PWD): bool {.discardable.} =
  cd dir
  let argv = cmdName + args
  discard execvp(cmdName.cstring, argv.toSeq.allocCStringArray)

proc exec(cmdName: string; dir): bool {.discardable.} =
  exec(cmdName, NO_ARGS, dir)

## JSON HELPERS
type 
  PathTraceKind* = enum PTK_ATTR, PTK_INDEX, PTK_RINDEX, PTK_SLICE, PTK_RSLICE
  PathTrace* = ref object
    jkind: JsonNodeKind
    case kind: PathTraceKind
      of PTK_INDEX:  index:  int
      of PTK_RINDEX: rindex: BackwardsIndex
      of PTK_SLICE:  slice:  HSlice[int, int]
      of PTK_RSLICE: rslice: HSlice[int, BackwardsIndex]
      of PTK_ATTR:   attr:   string

type JsonPath = seq[PathTrace]

using sep: char

proc jPath(path: PathTrace): JsonPath =
  @[path]

proc jPath(path: char;): JsonPath =
  @[PathTrace(kind: PTK_ATTR, attr: $path, jkind: JObject)]

proc jPath(index: int): JsonPath =
  @[PathTrace(kind: PTK_INDEX, index: index, jkind: JArray)]

proc jPath(index: BackwardsIndex): JsonPath =
  @[PathTrace(kind: PTK_RINDEX, rindex: index, jkind: JArray)]

proc jPath(slice: HSlice[int, int]): JsonPath =
  @[PathTrace(kind: PTK_SLICE, slice: slice, jkind: JArray)]

proc jPath(slice: HSlice[int, BackwardsIndex]): JsonPath =
  @[PathTrace(kind: PTK_RSLICE, rslice: slice, jkind: JArray)]

proc jPath(path: string, sep = '/'): JsonPath =
  let 
    idx          = """idx     <- \d+"""
    bwIdx        = """bwIdx   <- '^' \d+"""
    arrange      = """range   <- \d+ \s* '..' \s* '^'? \d+"""
    orrange      = """{'^' / \d+}"""
    mquoted      = """mquoted <- '\'' [^\']+ '\''"""
    dquoted      = """dquoted <- '"' [^"]+ '"'"""
    jPathGrammar = fmt"""
      path    <- (^ / '/' ) {{ trace }} ( &'/'/ $)
      trace   <- (\ident / dquoted / mquoted / range / bwIdx / idx)
      {dquoted}   
      {mquoted}
      {arrange}
      {bwIdx}
      {idx}
    """
    validationGrammar = fmt"""
      allPath <- ^ path ( path * ) $
      {jPathGrammar}
    """;
  result = newSeq[PathTrace]()
  if not path.match validationGrammar.peg:
    return

  for i in path.findAll jPathGrammar.peg:
    let part = i.strip(chars={'/'})
    if part.match(ident()):
      result.add PathTrace(
        kind:  PTK_ATTR,
        jkind: JObject,
        attr:  part)
    elif part.match(peg dquoted):
      result.add PathTrace(
        kind:  PTK_ATTR,
        jkind: JObject,
        attr:  part.strip(chars={'"'}))
    elif part.match(peg mquoted):
      result.add PathTrace(
        kind:  PTK_ATTR,
        jkind: JObject,
        attr:  part.strip(chars={'\''}))
    elif part.match(peg arrange):
      let parts = part.findAll(peg orrange).toSeq
      if parts.len == 2:
        result.add PathTrace(
          kind:  PTK_SLICE,
          jkind: JArray,
          slice:  parseInt(parts[0]) .. parseInt(parts[1]))
      else:
        result.add PathTrace(
          kind:  PTK_RSLICE,
          jkind: JArray,
          rslice:  parseInt(parts[0]) .. ^ parseInt(parts[2]))
    elif part.match(peg idx):
      result.add PathTrace(
        kind:  PTK_INDEX,
        jkind: JArray,
        index: parseInt(part))
    elif part.match(peg bwIdx):
      result.add PathTrace(
        kind:   PTK_RINDEX,
        jkind:  JArray,
        rindex: ^ parseInt(part.strip(chars={'^'})))

using path: JsonPath

proc `$`(trace: PathTrace): string =
  if trace.kind == PTK_ATTR:
    return trace.attr
  elif trace.kind == PTK_INDEX:
    return $trace.index
  elif trace.kind == PTK_RINDEX:
    return "^" & $cast[int](trace.rindex)
  elif trace.kind == PTK_RSLICE:
    return $trace.rslice.a & " .. ^" & $cast[int](trace.rslice.b)
  return $trace.slice

proc `$`(path; sep = '/'): string =
  path.mapIt($(it)).join($sep)

proc `/`(path; complement: JsonPath): JsonPath =
  path & complement

proc `/`(path; complement: string; sep = '/'): JsonPath =
  path / complement.jPath(sep)

proc `/`(complement: string; path; sep = '/'): JsonPath =
  path / complement.jPath(sep)

proc `/`(path; complement: char): JsonPath =
  path / complement.jPath

proc `/`(complement: char; path): JsonPath =
  path / complement.jPath

proc `/`(path; complement: int): JsonPath =
  path / complement.jPath

proc `/`(complement: int; path): JsonPath =
  path / complement.jPath

proc `/`(path; complement: BackwardsIndex): JsonPath =
  path / complement.jPath

proc `/`(complement: BackwardsIndex; path): JsonPath =
  path / complement.jPath

proc `/`(path; complement: HSlice[int, int]): JsonPath =
  path / complement.jPath

proc `/`(complement: HSlice[int, int]; path): JsonPath =
  path / complement.jPath

proc `/`(path; complement: HSlice[int, BackwardsIndex]): JsonPath =
  path / complement.jPath

proc `/`(complement: HSlice[int, BackwardsIndex]; path): JsonPath =
  path / complement.jPath

using obj: JsonNode

proc get(trace: PathTrace; obj; default: JsonNode = newJNull()): JsonNode =
  if   obj.kind == JObject and trace.kind == PTK_ATTR   and obj.hasKey(trace.attr):
    result = obj[trace.attr]
  elif obj.kind == JArray  and trace.kind == PTK_INDEX  and obj.len > trace.index:
    result = obj[trace.index]
  elif obj.kind == JArray  and trace.kind == PTK_RINDEX and obj.len > cast[int](trace.rindex):
    result = obj[trace.rindex]
  elif obj.kind == JArray  and trace.kind == PTK_SLICE:
    let b = min(obj.len - 1, trace.slice.b)
    if trace.slice.a >= obj.len:
      result = newJArray()
    else:
      result = obj[trace.slice.a .. b]
  elif obj.kind == JArray  and trace.kind == PTK_RSLICE:
    let b = cast[int](trace.rslice.b)
    if trace.rslice.a >= obj.len or trace.rslice.a > obj.len - b:
      result = newJArray()
    else:
      result = obj[trace.rslice]
  else:
    return default

proc `[]`(obj; trace: PathTrace): JsonNode =
  trace.get obj

proc get(path; obj; default: JsonNode = newJNull()): JsonNode =
  result = obj
  for trace in path:
    result = trace.get(result, default)
    if result == default:
      break

proc `[]`(obj; path): JsonNode =
  path.get obj

proc set(trace: PathTrace; obj; val: JsonNode): JsonNode {.discardable.} =
  result = obj
  if trace.kind == PTK_ATTR:
    if result.kind != JObject:
      result = newJObject()
  elif result.kind != JArray:
    result = newJArray()

  if  trace.kind == PTK_ATTR:
    result[trace.attr] = val
    return result

  let 
    old     = result
    minimal =
      if   trace.kind == PTK_INDEX: trace.index
      elif trace.kind == PTK_SLICE: trace.slice.b
      else: old.len - 1
    total = minimal.max(old.len - 1)

  result = newJArray()
  for i in 0 .. total:
    if   trace.kind == PTK_INDEX  and i == trace.index:
      result.add val
    elif trace.kind == PTK_RINDEX and i - 1 == total - cast[int](trace.rindex):
      result.add val
    elif trace.kind == PTK_SLICE  and i in trace.slice:
      result.add val
    elif trace.kind == PTK_RSLICE and i >= trace.rslice.a and i - 1 < old.len - cast[int](trace.rslice.b):
      result.add val
    elif i < old.len:
      result.add old[i]
    else:
      result.add newJNull()


proc `[]=`(obj; trace: PathTrace; val: JsonNode) =
  trace.set obj,    val

proc `[]=`(obj; trace: PathTrace; val: string) =
  trace.set obj, %* val

proc `[]=`(obj; trace: PathTrace; val: char) =
  trace.set obj, %* $val

proc `[]=`(obj; trace: PathTrace; val: enum) =
  trace.set obj, %* val

proc `[]=`(obj; trace: PathTrace; val: SomeInteger) =
  trace.set obj, %* val

proc `[]=`(obj; trace: PathTrace; val: SomeFloat) =
  trace.set obj, %* val

proc `[]=`(obj; trace: PathTrace; val: bool) =
  trace.set obj, %* val

proc set(path; obj; val: JsonNode): JsonNode {.discardable.} =
  if path.len == 0:
    return obj
  if path.len == 1:
    return path[0].set(obj, val)
  let
    last    = obj[path[0 .. ^2]]
    updated = path[^1].set(last, val)
  return path[0 .. ^2].set(obj, updated)

proc `[]=`(obj; path; val: JsonNode) =
  path.set obj, val

proc `[]=`(obj; path; val: string) =
  path.set obj, %* val

proc `[]=`(obj; path; val: enum) =
  path.set obj, %* val

proc `[]=`(obj; path; val: SomeInteger) =
  path.set obj, %* val

proc `[]=`(obj; path; val: SomeFloat) =
  path.set obj, %* val

proc `[]=`(obj; path; val: bool) =
  path.set obj, %* val

proc filter(path; obj): JsonNode =
  const 
    HEAD = 0
    LAST = 1
    TAIL = 1 .. ^1

  if path.len == 0:
    return obj
  let
    tail = path[TAIL]
    head = path[HEAD]

  var current = obj
  if obj.kind == JObject:
    result = newJObject()
    if head.kind == PTK_ATTR:
      result[head] = tail.filter obj[head]
  elif obj.kind == JArray:
    result = newJArray()
    if head.kind == PTK_INDEX and head.index < obj.len:
      result.add tail.filter(obj[head])
    elif head.kind == PTK_RINDEX and cast[int](head.rindex) <= obj.len:
      result.add tail.filter(obj[head])
    elif head.kind == PTK_SLICE:
      for i in head.slice.a .. (head.slice.b - 1):
        if i > obj.len:
          break
        result.add tail.filter(obj[i])
    elif head.kind == PTK_RSLICE:
      for i in head.rslice.a .. (obj.len - cast[int](head.rslice.b)):
        result.add tail.filter(obj[i])
  else:
    return obj

