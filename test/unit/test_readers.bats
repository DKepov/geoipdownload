#!/usr/bin/env bats

load 'helpers'

# ---------------------------------------------------------------------------
# read_account_id
# ---------------------------------------------------------------------------

@test "read_account_id: reads AccountID from config" {
  conf="${TEST_DIR}/GeoIP.conf"
  make_conf "${conf}"
  result=$(read_account_id "${conf}")
  [[ "${result}" == '123456' ]]
}

@test "read_account_id: returns code 1 when AccountID missing" {
  conf="${TEST_DIR}/GeoIP.conf"
  echo 'LicenseKey ABC' > "${conf}"
  run read_account_id "${conf}"
  [[ "${status}" -eq 1 ]]
}

@test "read_account_id: error message when AccountID missing" {
  conf="${TEST_DIR}/GeoIP.conf"
  echo 'LicenseKey ABC' > "${conf}"
  run read_account_id "${conf}"
  [[ "${output}" == *'AccountID'* ]]
}

# ---------------------------------------------------------------------------
# read_license_key
# ---------------------------------------------------------------------------

@test "read_license_key: reads LicenseKey from config" {
  conf="${TEST_DIR}/GeoIP.conf"
  make_conf "${conf}"
  result=$(read_license_key "${conf}")
  [[ "${result}" == 'ABCDEF123456' ]]
}

@test "read_license_key: returns code 1 when LicenseKey missing" {
  conf="${TEST_DIR}/GeoIP.conf"
  echo 'AccountID 999' > "${conf}"
  run read_license_key "${conf}"
  [[ "${status}" -eq 1 ]]
}

@test "read_license_key: error message when LicenseKey missing" {
  conf="${TEST_DIR}/GeoIP.conf"
  echo 'AccountID 999' > "${conf}"
  run read_license_key "${conf}"
  [[ "${output}" == *'LicenseKey'* ]]
}

# ---------------------------------------------------------------------------
# read_edition_ids
# ---------------------------------------------------------------------------

@test "read_edition_ids: reads all EditionIDs from config" {
  conf="${TEST_DIR}/GeoIP.conf"
  make_conf "${conf}"
  result=$(read_edition_ids "${conf}")
  [[ "${result}" == *'GeoLite2-City'* ]]
  [[ "${result}" == *'GeoLite2-Country'* ]]
}

@test "read_edition_ids: each edition on its own line" {
  conf="${TEST_DIR}/GeoIP.conf"
  make_conf "${conf}"
  count=$(read_edition_ids "${conf}" | wc -l)
  [[ "${count}" -eq 2 ]]
}

@test "read_edition_ids: returns code 1 when EditionIDs missing" {
  conf="${TEST_DIR}/GeoIP.conf"
  printf 'AccountID 1\nLicenseKey X\n' > "${conf}"
  run read_edition_ids "${conf}"
  [[ "${status}" -eq 1 ]]
}

@test "read_edition_ids: error message when EditionIDs missing" {
  conf="${TEST_DIR}/GeoIP.conf"
  printf 'AccountID 1\nLicenseKey X\n' > "${conf}"
  run read_edition_ids "${conf}"
  [[ "${output}" == *'EditionIDs'* ]]
}

@test "read_edition_ids: works with single edition" {
  conf="${TEST_DIR}/GeoIP.conf"
  printf 'AccountID 1\nLicenseKey X\nEditionIDs GeoLite2-ASN\n' > "${conf}"
  result=$(read_edition_ids "${conf}")
  [[ "${result}" == 'GeoLite2-ASN' ]]
}

# ---------------------------------------------------------------------------
# read_database_directory
# ---------------------------------------------------------------------------

@test "read_database_directory: reads DatabaseDirectory from config" {
  conf="${TEST_DIR}/GeoIP.conf"
  make_conf "${conf}"
  result=$(read_database_directory "${conf}")
  [[ "${result}" == '/tmp/geoip' ]]
}

@test "read_database_directory: returns code 1 when DatabaseDirectory missing" {
  conf="${TEST_DIR}/GeoIP.conf"
  printf 'AccountID 1\nLicenseKey X\n' > "${conf}"
  run read_database_directory "${conf}"
  [[ "${status}" -eq 1 ]]
}
