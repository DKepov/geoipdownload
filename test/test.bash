#!/bin/bash

CURRENT_DIR="$(pwd)"
readonly CURRENT_DIR

readonly CHECK_DIR="${CURRENT_DIR}/check"

readonly URL="${CURRENT_DIR}/../test-data"

mkdir -p "${CHECK_DIR}" || err 'Can not create the Test directory'

cp './../GeoIP.conf' "${CHECK_DIR}/GeoIP.conf"
cp './../geoipdownload' "${CHECK_DIR}/geoipdownload"

sed -i "s|DOWNLOAD_URL_TEMPLATE='.*'|DOWNLOAD_URL_TEMPLATE='file://${URL}/EDITION_ID.mmdb.tar.gz'|g" "${CHECK_DIR}/geoipdownload"

cd "${CHECK_DIR}" || err 'Can not open the Test directory'

./geoipdownload -f 'GeoIP.conf' -d '.' -v

cd "${CURRENT_DIR}" || err 'Can not leave the Test directory '

rm -rf "${CHECK_DIR}" || err 'Can not remove the Test directory'

err() {
    echo "$1" >&2
    exit 1
}
