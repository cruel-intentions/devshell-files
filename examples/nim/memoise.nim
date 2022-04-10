# memoise command execution: memoise {time} {cmd} ...{args}

let
  params  = ARGS[1 .. ^1].join " "
  key     = $params.secureHash
  tmpDir  = getTempDir() / "memoize"
  tmpFile = tmpDir / fmt"{key}.json"


if not dirExists tmpDir:
  createDir tmpDir

if not fileExists tmpFile:
  writeFile tmpFile, """{"ttl": 0}"""

let cache = parseJson readFile tmpFile

if cache["ttl"].getInt < now().toTime.toUnix:
  let 
    (output,
    exitCode) = execCmdEx params
    interval  = parseInt arg 1
    expiresAt = now() + interval.seconds
  cache["code"] = %* exitCode
  cache["out" ] = %* output.strip(chars={'\n'})
  cache["ttl" ] = %* expiresAt.toTime.toUnix

writeFile tmpFile, cache.pretty

echo getStr cache["out" ]
quit getInt cache["code"]
