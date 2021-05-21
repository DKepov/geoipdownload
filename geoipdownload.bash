#!/usr/bin/env bash

cd .

# Analog for geoipupdate
# https://dev.maxmind.com/geoip/geoipupdate/

GeoIPConfName="GeoIP.conf"

# Getting the License Key

LicenseKeyVar=$(cat $GeoIPConfName | grep -oP '^LicenseKey\s+\K\S+')

LicenseKey=$LicenseKeyVar

# Getting the EditionIDs GeoIP Bases
# Making List of GeoIP Bases

#declare -a EditionIDs=(
#  "GeoLite2-ASN"
#  "GeoLite2-City"
#  "GeoLite2-Country"
#)

EditionIDsVar=$(cat $GeoIPConfName | grep -Po "(?<=EditionIDs\s).*")

read -ra EditionIDs <<< $EditionIDsVar;
declare -a EditionIDs

# Permanent link for downloading files

DownloadLink="https://download.maxmind.com/app/geoip_download?edition_id=EDITION_ID&license_key=LICENSE_KEY&suffix=tar.gz"


# Walking through the array
# And downloading database in current directory

for EditionID in "${EditionIDs[@]}"
do

  echo $EditionID

  EditionIDArchive=$EditionID.mmdb.gz
  EditionIDBase=$EditionID.mmdb

  # Replacing tags to real variables

  EditionDownloadLink=$DownloadLink
  EditionDownloadLink="${EditionDownloadLink/EDITION_ID/$EditionID}"
  EditionDownloadLink="${EditionDownloadLink/LICENSE_KEY/$LicenseKey}"

  echo $EditionDownloadLink

  # Downloading Bases

  curl $EditionDownloadLink --output $EditionIDArchive

  # Getting the path to the Destination file

  EditionIDTargetPath=$(tar -tf $EditionIDArchive | grep $EditionIDBase)

  # Extracting the final file from the archive

  tar -zxf $EditionIDArchive $EditionIDTargetPath

  # Moving the destination file to the current directory

  mv $EditionIDTargetPath $EditionIDBase

  # Delete temporary Extractiong directory

  rm -rf $(dirname $EditionIDTargetPath)

  # Delete temporary downloading Archives

  rm $EditionIDArchive

done
