#!/bin/bash

readonly TEST_SUB_DIR='./check'
readonly DATABASE_DIR='./../test-data'

CURRENT_DIR="$(pwd)"
readonly CURRENT_DIR

readonly CHECK_DIR="${CURRENT_DIR}/"${TEST_SUB_DIR}

readonly URL="${CURRENT_DIR}/${DATABASE_DIR}"

err() {
  echo "$1" >&2
  exit 1
}

run_or_next() {
  # Check that the first argument is our command start marker
  if [[ "$1" != ":::" ]]; then
    echo "Syntax error run_or_next: missing token :::" >&2
    exit 1
  fi
  shift # Remove ":::" from the argument list

  local cmd=()
  # We assemble the command until we encounter the message marker "::"
  while [[ "$1" != "::" && $# -gt 0 ]]; do
    cmd+=("$1")
    shift
  done

  # Check if we found the "::" marker
  if [[ "$1" != "::" ]]; then
    echo "Syntax error run_or_next: missing token ::" >&2
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

mkdir -p "${CHECK_DIR}" || err 'Can not create the Test directory'

cp './../GeoIP.conf' "${CHECK_DIR}/GeoIP.conf"
cp './../geoipdownload' "${CHECK_DIR}/geoipdownload"

sed -i "s|DOWNLOAD_URL_TEMPLATE='.*'|DOWNLOAD_URL_TEMPLATE='file://${URL}/EDITION_ID.mmdb.tar.gz'|g" "${CHECK_DIR}/geoipdownload"

cd "${CHECK_DIR}" || err 'Can not open the Test directory'

./geoipdownload -f 'GeoIP.conf' -d '.' -v

cd "${CURRENT_DIR}" || err 'Can not leave the Test directory '

rm -rf "${CHECK_DIR}" || err 'Can not remove the Test directory'
