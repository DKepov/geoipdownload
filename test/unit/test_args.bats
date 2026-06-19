#!/usr/bin/env bats

load 'helpers'

@test "parse_and_default_args: sets CONFIG_FILE from -f" {
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  parse_and_default_args -f '/tmp/my.conf'
  [[ "${CONFIG_FILE}" == '/tmp/my.conf' ]]
}

@test "parse_and_default_args: sets CONFIG_FILE from --config-file" {
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  parse_and_default_args --config-file '/tmp/long.conf'
  [[ "${CONFIG_FILE}" == '/tmp/long.conf' ]]
}

@test "parse_and_default_args: sets DATABASE_DIRECTORY from -d" {
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  parse_and_default_args -d '/tmp/db'
  [[ "${DATABASE_DIRECTORY}" == '/tmp/db' ]]
}

@test "parse_and_default_args: sets DATABASE_DIRECTORY from --database-directory" {
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  parse_and_default_args --database-directory '/tmp/db2'
  [[ "${DATABASE_DIRECTORY}" == '/tmp/db2' ]]
}

@test "parse_and_default_args: sets VERBOSE=1 from -v" {
  VERBOSE=0
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  parse_and_default_args -v
  [[ "${VERBOSE}" -eq 1 ]]
}

@test "parse_and_default_args: sets VERBOSE=1 from --verbose" {
  VERBOSE=0
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  parse_and_default_args --verbose
  [[ "${VERBOSE}" -eq 1 ]]
}

@test "parse_and_default_args: CONFIG_FILE stays empty when -f not given" {
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  parse_and_default_args
  [[ -z "${CONFIG_FILE}" ]]
}

@test "parse_and_default_args: ignores unknown flags without error" {
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  run parse_and_default_args --unknown-flag
  [[ "${status}" -eq 0 ]]
}

@test "parse_and_default_args: accepts both -f and -d together" {
  CONFIG_FILE=''
  DATABASE_DIRECTORY=''
  parse_and_default_args -f '/etc/GeoIP.conf' -d '/usr/share/GeoIP'
  [[ "${CONFIG_FILE}"        == '/etc/GeoIP.conf'  ]]
  [[ "${DATABASE_DIRECTORY}" == '/usr/share/GeoIP' ]]
}
