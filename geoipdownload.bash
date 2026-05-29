#!/usr/bin/env bash

cd .

# Analog for geoipupdate
# https://dev.maxmind.com/geoip/geoipupdate/

GeoIPConfName="GeoIP.conf"

# Checking the existence of a configuration file
if [ ! -f "$GeoIPConfName" ]; then
  echo "Error: The configuration file '$GeoIPConfName' was not found!" >&2
  exit 1
fi

# Getting the License Key

LicenseKeyVar=$(cat $GeoIPConfName | grep -oP '^LicenseKey\s+\K\S+')

LicenseKey=$LicenseKeyVar

# Checking the existence of the 'LicenseKey' in the configuration file
if [ -z "$LicenseKey" ]; then
  echo "Error: The 'LicenseKey' parameter is empty or missing in '$GeoIPConfName'!" >&2
  exit 1
fi

# Getting the EditionIDs GeoIP Bases
# Making List of GeoIP Bases

#declare -a EditionIDs=(
#  "GeoLite2-ASN"
#  "GeoLite2-City"
#  "GeoLite2-Country"
#)

EditionIDsVar=$(cat $GeoIPConfName | grep -Po "(?<=EditionIDs\s).*")

# Checking the existence of the 'EditionIDs' in the configuration file
if [ -z "$EditionIDsVar" ]; then
  echo "Error: The 'EditionIDs' parameter is empty or missing in '$GeoIPConfName'!" >&2
  exit 1
fi

declare -a EditionIDs
read -ra EditionIDs <<< $EditionIDsVar;

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
  
  # Checking if the file has been downloaded, or is there an error from the api?
  # The file command checks the file header. A correct archive will return "gzip compressed data"
  if ! file "$EditionIDArchive" | grep -q "gzip compressed data"; then
    echo "MaxMind server error when downloading $EditionID:" >&2
    # Output the error text (for example: "Invalid license key")
    cat "$EditionIDArchive" >&2
    echo "" >&2
    # Delete temporary downloading File
    rm -f "$EditionIDArchive"
    exit 1
  fi

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
