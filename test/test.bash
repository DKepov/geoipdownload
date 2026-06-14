#!/bin/bash

CURRENT_DIR="$(pwd)"
readonly CURRENT_DIR

readonly CHECK_DIR="${CURRENT_DIR}/check"

readonly URL="${CURRENT_DIR}/../test-data"

mkdir -p "${CHECK_DIR}" || exit 1

cp './../GeoIP.conf' "${CHECK_DIR}/GeoIP.conf"
cp './../geoipdownload' "${CHECK_DIR}/geoipdownload"

sed -i "s|DOWNLOAD_URL_TEMPLATE='.*'|DOWNLOAD_URL_TEMPLATE='file://${URL}/EDITION_ID.mmdb.tar.gz'|g" "${CHECK_DIR}/geoipdownload"

cd "${CHECK_DIR}" || exit 1

./geoipdownload -f 'GeoIP.conf' -d '.' -v

cd "${CURRENT_DIR}" || exit 1

rm -rf "${CHECK_DIR}" || exit 1
