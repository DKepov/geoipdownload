#!/usr/bin/env bats

load 'helpers'

# ---------------------------------------------------------------------------
# build_download_url
# ---------------------------------------------------------------------------

@test "build_download_url: contains edition id in URL" {
  result=$(build_download_url 'GeoLite2-City')
  [[ "${result}" == *'GeoLite2-City'* ]]
}

@test "build_download_url: contains current date in URL" {
  result=$(build_download_url 'GeoLite2-City')
  [[ "${result}" == *"${CURRENT_DATE}"* ]]
}

@test "build_download_url: contains download type (tar.gz) in URL" {
  result=$(build_download_url 'GeoLite2-City')
  [[ "${result}" == *'tar.gz'* ]]
}

@test "build_download_url: starts with https" {
  result=$(build_download_url 'GeoLite2-City')
  [[ "${result}" == https://* ]]
}

@test "build_download_url: no template placeholders remain in URL" {
  result=$(build_download_url 'GeoLite2-Country')
  [[ "${result}" != *'EDITION_ID'* ]]
  [[ "${result}" != *'DATE'* ]]
  [[ "${result}" != *'TYPE'* ]]
}

# ---------------------------------------------------------------------------
# build_archive_name
# ---------------------------------------------------------------------------

@test "build_archive_name: contains edition id" {
  result=$(build_archive_name 'GeoLite2-City')
  [[ "${result}" == *'GeoLite2-City'* ]]
}

@test "build_archive_name: ends with .mmdb.tar.gz" {
  result=$(build_archive_name 'GeoLite2-City')
  [[ "${result}" == *'.mmdb.tar.gz' ]]
}

@test "build_archive_name: correct full name" {
  result=$(build_archive_name 'GeoLite2-ASN')
  [[ "${result}" == 'GeoLite2-ASN.mmdb.tar.gz' ]]
}

# ---------------------------------------------------------------------------
# build_database_name
# ---------------------------------------------------------------------------

@test "build_database_name: contains edition id" {
  result=$(build_database_name 'GeoLite2-City')
  [[ "${result}" == *'GeoLite2-City'* ]]
}

@test "build_database_name: ends with .mmdb" {
  result=$(build_database_name 'GeoLite2-City')
  [[ "${result}" == *'.mmdb' ]]
}

@test "build_database_name: correct full name" {
  result=$(build_database_name 'GeoLite2-Country')
  [[ "${result}" == 'GeoLite2-Country.mmdb' ]]
}
