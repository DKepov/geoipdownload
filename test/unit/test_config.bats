#!/usr/bin/env bats

load 'helpers'

@test "take_checked_config_exists: returns path for existing readable file" {
  conf="${TEST_DIR}/GeoIP.conf"
  make_conf "${conf}"
  result=$(take_checked_config_exists "${conf}")
  [[ "${result}" == "${conf}" ]]
}

@test "take_checked_config_exists: exit code 0 for existing file" {
  conf="${TEST_DIR}/GeoIP.conf"
  make_conf "${conf}"
  take_checked_config_exists "${conf}"
}

@test "take_checked_config_exists: returns code 1 for missing file" {
  run take_checked_config_exists "${TEST_DIR}/no_such_file.conf"
  [[ "${status}" -eq 1 ]]
}

@test "take_checked_config_exists: error message for missing file" {
  run take_checked_config_exists "${TEST_DIR}/no_such_file.conf"
  [[ "${output}" == *'not found'* ]]
}

@test "take_checked_config_exists: returns code 1 for non-readable file" {
  if [[ "$(id -u)" -eq 0 ]]; then
    skip "Running as root: permission checks are not enforced"
  fi
  conf="${TEST_DIR}/noperm.conf"
  make_conf "${conf}"
  chmod 000 "${conf}"
  run take_checked_config_exists "${conf}"
  [[ "${status}" -eq 1 ]]
  chmod 644 "${conf}"
}
