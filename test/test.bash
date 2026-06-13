#!/bin/bash

CHECK_DIR='./check'

URL="$(pwd)/../test-data"

mkdir -p "${CHECK_DIR}"

cp ./../GeoIP.conf "${CHECK_DIR}"/GeoIP.conf
cp ./../geoipdownload "${CHECK_DIR}"/geoipdownload

sed -i "s|DOWNLOAD_URL_TEMPLATE='.*'|DOWNLOAD_URL_TEMPLATE='file://${URL}/EDITION_ID.mmdb.tar.gz'|g" "${CHECK_DIR}"/geoipdownload

cd "${CHECK_DIR}"/

./geoipdownload -f GeoIP.conf -d . -v
