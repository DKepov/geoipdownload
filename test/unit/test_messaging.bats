#!/usr/bin/env bats

load 'helpers'

# ---------------------------------------------------------------------------
# message
# ---------------------------------------------------------------------------

@test "message: output contains the passed text" {
  result=$(message 'hello world')
  [[ "${result}" == *'hello world'* ]]
}

@test "message: output contains an ISO-like timestamp" {
  result=$(message 'ts test')
  [[ "${result}" =~ \[[0-9]{4}-[0-9]{2}-[0-9]{2}T ]]
}

# ---------------------------------------------------------------------------
# err
# ---------------------------------------------------------------------------

@test "err: writes to stderr" {
  result=$(err 'something failed' 2>&1 1>/dev/null)
  [[ "${result}" == *'something failed'* ]]
}

@test "err: output contains [ERROR]" {
  result=$(err 'boom' 2>&1)
  [[ "${result}" == *'[ERROR]'* ]]
}

# ---------------------------------------------------------------------------
# info
# ---------------------------------------------------------------------------

@test "info: silent when VERBOSE=0" {
  VERBOSE=0
  result=$(info 'quiet please' 2>&1)
  [[ -z "${result}" ]]
}

@test "info: prints when VERBOSE=1" {
  VERBOSE=1
  result=$(info 'loud please' 2>&1)
  [[ "${result}" == *'loud please'* ]]
}

@test "info: output contains [INFO] when VERBOSE=1" {
  VERBOSE=1
  result=$(info 'check tag' 2>&1)
  [[ "${result}" == *'[INFO]'* ]]
}

# ---------------------------------------------------------------------------
# version
# ---------------------------------------------------------------------------

@test "version: output contains 'geoipdownload'" {
  result=$(version)
  [[ "${result}" == *'geoipdownload'* ]]
}

@test "version: output contains the VERSION constant" {
  result=$(version)
  [[ "${result}" == *"${VERSION}"* ]]
}

# ---------------------------------------------------------------------------
# usage
# ---------------------------------------------------------------------------

@test "usage: output contains USAGE keyword" {
  result=$(usage)
  [[ "${result}" == *'USAGE'* ]]
}

@test "usage: output contains --config-file flag" {
  result=$(usage)
  [[ "${result}" == *'--config-file'* ]]
}

@test "usage: output contains --database-directory flag" {
  result=$(usage)
  [[ "${result}" == *'--database-directory'* ]]
}
