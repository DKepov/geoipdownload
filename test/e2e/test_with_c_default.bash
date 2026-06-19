#!/bin/bash

PROJECT_DIR="$(pwd)/../../"
PROJECT_DIR="$(realpath "${PROJECT_DIR}")"
readonly PROJECT_DIR

readonly TEST_DIR="${PROJECT_DIR}/test"
readonly CONFIG_DIR="${PROJECT_DIR}/test-conf"
readonly DATABASE_DIR="${PROJECT_DIR}/test-data"
readonly CHECK_DIR="${TEST_DIR}/check"

err() {
  echo "$@" >&2
  exit 1
}

run_or_next() {
  # Check that the first argument is our command start marker
  if [[ $1 != ':::' ]]; then
    echo 'Syntax error run_or_next: missing token :::' >&2
    exit 1
  fi
  shift # Remove ":::" from the argument list

  local cmd=()
  # We assemble the command until we encounter the message marker "::"
  while [[ $1 != '::' && $# -gt 0 ]]; do
    cmd+=("$1")
    shift
  done

  # Check if we found the "::" marker
  if [[ $1 != '::' ]]; then
    echo 'Syntax error run_or_next: missing token ::' >&2
    exit 1
  fi
  shift # Remove "::" from the argument list

  # Write the command to the second (target) array variable
  local -a TARGET_COMMAND=("${cmd[@]}")

  # All remaining arguments are another command
  local next_cmd=("$@")

  # We execute the compiled command, hide the system stderr and, if it crashes.
  # We execute the main command. If it fails, we execute the error command.
  "${TARGET_COMMAND[@]}" 2>/dev/null || "${next_cmd[@]}"
}

run_or_next ::: mkdir "${CHECK_DIR}" :: err 'Can not create the Test directory (or already exists):' "${CHECK_DIR}"

run_or_next ::: cp "${CONFIG_DIR}/GeoIP.conf" "${CHECK_DIR}/GeoIP.conf" :: err 'Can not copy the Config file:' "${CONFIG_DIR}/GeoIP.conf" 'to' "${CHECK_DIR}/GeoIP.conf"
run_or_next ::: cp "${PROJECT_DIR}/geoipdownload" "${CHECK_DIR}/geoipdownload" :: err 'Can not copy the Application file:' "${PROJECT_DIR}/geoipdownload" 'to' "${CHECK_DIR}/geoipdownload"

run_or_next ::: sed -i "s|DOWNLOAD_URL_TEMPLATE='.*'|DOWNLOAD_URL_TEMPLATE='file://${DATABASE_DIR}/EDITION_ID.mmdb.tar.gz'|g" "${CHECK_DIR}/geoipdownload" :: err 'Can not rewrite the Download URL'

run_or_next ::: sed -i "s|DEFAULT_CONFIG_FILE_ORIG='.*'|DEFAULT_CONFIG_FILE_ORIG='${CHECK_DIR}/GeoIP.conf'|g" "${CHECK_DIR}/geoipdownload" :: err 'Can not rewrite the Config File'
run_or_next ::: sed -i "s|DEFAULT_DATABASE_DIRECTORY_ORIG='.*'|DEFAULT_DATABASE_DIRECTORY_ORIG='${CHECK_DIR}/'|g" "${CHECK_DIR}/geoipdownload" :: err 'Can not rewrite the Database Directory'
run_or_next ::: sed -i "s|DEFAULT_CONFIG_FILE_NEW='.*'|DEFAULT_CONFIG_FILE_NEW='${CHECK_DIR}/GeoIP.conf'|g" "${CHECK_DIR}/geoipdownload" :: err 'Can not rewrite the Config File'
run_or_next ::: sed -i "s|DEFAULT_DATABASE_DIRECTORY_NEW='.*'|DEFAULT_DATABASE_DIRECTORY_NEW='${CHECK_DIR}/'|g" "${CHECK_DIR}/geoipdownload" :: err 'Can not rewrite the Database Directory'

run_or_next ::: cd "${CHECK_DIR}" :: err 'Can not open the Test directory:' "${CHECK_DIR}"

./geoipdownload -f 'GeoIP.conf' -v # Running without Error Suppression

run_or_next ::: cd "${TEST_DIR}" :: err 'Can not leave to the Test directory:' "${TEST_DIR}"

run_or_next ::: rm -rf "${CHECK_DIR}" :: err 'Can not remove the Test directory:' "${CHECK_DIR}"
