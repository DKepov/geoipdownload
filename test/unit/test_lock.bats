#!/usr/bin/env bats

load 'helpers'

@test "acquire_lock: creates the lock file" {
  lock="${TEST_DIR}/.geoipdownload.lock"
  acquire_lock "${lock}"
  [[ -f "${lock}" ]]
  release_lock "${lock}"
}

@test "acquire_lock: writes a PID into the lock file" {
  lock="${TEST_DIR}/.geoipdownload.lock"
  acquire_lock "${lock}"
  content=$(cat "${lock}")
  [[ "${content}" =~ ^[0-9]+$ ]]
  release_lock "${lock}"
}

@test "release_lock: removes the lock file" {
  lock="${TEST_DIR}/.geoipdownload.lock"
  acquire_lock "${lock}"
  release_lock "${lock}"
  [[ ! -f "${lock}" ]]
}

@test "release_lock: does nothing when lock file is absent" {
  lock="${TEST_DIR}/.no_such_lock"
  run release_lock "${lock}"
  [[ "${status}" -eq 0 ]]
}
