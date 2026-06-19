#!/usr/bin/env bash

#
# helpers.bash
#
# Shared setup, teardown, and helper functions for all geoipdownload test files.
# Loaded via `load 'helpers'` at the top of each .bats file.
#

# Path to the script under test
SCRIPT="${BATS_TEST_DIRNAME}/../../geoipdownload"

# Source the script without running main()
setup() {
  TEST_DIR="$(mktemp -d)"
  # shellcheck disable=SC1090
  source <(grep -v '^main "\$@"' "${SCRIPT}")
}

teardown() {
  rm -rf "${TEST_DIR}"
}

# Create a minimal valid GeoIP.conf
make_conf() {
  local path="$1"
  cat > "${path}" << 'EOF'
AccountID 123456
LicenseKey ABCDEF123456
EditionIDs GeoLite2-City GeoLite2-Country
DatabaseDirectory /tmp/geoip
EOF
}

# Build a real tar.gz containing a fake .mmdb file
make_test_archive() {
  local dir="$1"
  local edition="$2"
  local db_name="${edition}.mmdb"
  local archive_name="${edition}.mmdb.tar.gz"

  echo 'fake mmdb content' > "${dir}/${db_name}"
  tar -czf "${dir}/${archive_name}" -C "${dir}" "${db_name}"
  rm -f "${dir}/${db_name}"
}
