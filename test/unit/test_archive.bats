#!/usr/bin/env bats

load 'helpers'

# ---------------------------------------------------------------------------
# delete_database_archive
# ---------------------------------------------------------------------------

@test "delete_database_archive: removes the archive file" {
  archive="${TEST_DIR}/GeoLite2-City.mmdb.tar.gz"
  touch "${archive}"
  delete_database_archive "${TEST_DIR}" 'GeoLite2-City.mmdb.tar.gz'
  [[ ! -f "${archive}" ]]
}

@test "delete_database_archive: returns expected path" {
  archive="${TEST_DIR}/GeoLite2-City.mmdb.tar.gz"
  touch "${archive}"
  result=$(delete_database_archive "${TEST_DIR}" 'GeoLite2-City.mmdb.tar.gz')
  [[ "${result}" == "${TEST_DIR}/GeoLite2-City.mmdb.tar.gz" ]]
}

@test "delete_database_archive: succeeds even if file does not exist" {
  run delete_database_archive "${TEST_DIR}" 'ghost.mmdb.tar.gz'
  [[ "${status}" -eq 0 ]]
}

# ---------------------------------------------------------------------------
# extract_database_from_archive
# ---------------------------------------------------------------------------

@test "extract_database_from_archive: extracts .mmdb file" {
  make_test_archive "${TEST_DIR}" 'GeoLite2-City'
  pushd "${TEST_DIR}" > /dev/null
  extract_database_from_archive \
    "${TEST_DIR}" \
    'GeoLite2-City.mmdb.tar.gz' \
    'GeoLite2-City.mmdb'
  popd > /dev/null
  [[ -f "${TEST_DIR}/GeoLite2-City.mmdb" ]]
}

@test "extract_database_from_archive: returns path to extracted file" {
  make_test_archive "${TEST_DIR}" 'GeoLite2-Country'
  pushd "${TEST_DIR}" > /dev/null
  result=$(extract_database_from_archive \
    "${TEST_DIR}" \
    'GeoLite2-Country.mmdb.tar.gz' \
    'GeoLite2-Country.mmdb')
  popd > /dev/null
  [[ "${result}" == "${TEST_DIR}/GeoLite2-Country.mmdb" ]]
}

@test "extract_database_from_archive: code 1 for corrupted archive" {
  echo 'not a tar.gz' > "${TEST_DIR}/bad.mmdb.tar.gz"
  run extract_database_from_archive "${TEST_DIR}" 'bad.mmdb.tar.gz' 'bad.mmdb'
  [[ "${status}" -eq 1 ]]
}

@test "extract_database_from_archive: code 1 when mmdb missing from archive" {
  echo 'data' > "${TEST_DIR}/other.mmdb"
  tar -czf "${TEST_DIR}/GeoLite2-ASN.mmdb.tar.gz" -C "${TEST_DIR}" 'other.mmdb'
  run extract_database_from_archive \
    "${TEST_DIR}" \
    'GeoLite2-ASN.mmdb.tar.gz' \
    'GeoLite2-ASN.mmdb'
  [[ "${status}" -eq 1 ]]
}
