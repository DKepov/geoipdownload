#!/usr/bin/env bats

load 'helpers'

@test "take_checked_directory_exists_and_writable: returns path for writable dir" {
  result=$(take_checked_directory_exists_and_writable "${TEST_DIR}")
  [[ "${result}" == "${TEST_DIR}" ]]
}

@test "take_checked_directory_exists_and_writable: exit code 0 for writable dir" {
  take_checked_directory_exists_and_writable "${TEST_DIR}"
}

@test "take_checked_directory_exists_and_writable: code 1 for missing dir" {
  run take_checked_directory_exists_and_writable "${TEST_DIR}/no_dir"
  [[ "${status}" -eq 1 ]]
}

@test "take_checked_directory_exists_and_writable: code 1 for non-writable dir" {
  if [[ "$(id -u)" -eq 0 ]]; then
    skip "Running as root: permission checks are not enforced"
  fi
  ro_dir="${TEST_DIR}/readonly"
  mkdir "${ro_dir}"
  chmod 555 "${ro_dir}"
  run take_checked_directory_exists_and_writable "${ro_dir}"
  [[ "${status}" -eq 1 ]]
  chmod 755 "${ro_dir}"
}

@test "take_checked_directory_exists_and_writable: error message for missing dir" {
  run take_checked_directory_exists_and_writable "${TEST_DIR}/no_dir"
  [[ "${output}" == *'not found'* ]]
}
