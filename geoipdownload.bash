#!/usr/bin/env bash

cd .

# Analog for geoipupdate
# https://dev.maxmind.com/geoip/updating-databases/
# https://github.com/maxmind/geoipupdate

GeoIPConfName="GeoIP.conf"

# Checking the existence of a configuration file
if [ ! -f "$GeoIPConfName" ]; then
  echo "Error: The configuration file '$GeoIPConfName' was not found!" >&2
  exit 1
fi

echo "Info: The configuration file '$GeoIPConfName' was found."

# Getting the License Key

LicenseKeyVar=$(cat $GeoIPConfName | grep -oP '^LicenseKey\s+\K\S+')

LicenseKey=$LicenseKeyVar

# Checking the existence of the 'LicenseKey' in the configuration file
if [ -z "$LicenseKey" ]; then
  echo "Error: The 'LicenseKey' parameter is empty or missing in '$GeoIPConfName'!" >&2
  exit 1
fi

echo "Info: The license key has been successfully read."

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

echo "Info: Download databases ${#EditionIDs[@]} found: (${EditionIDs[*]})"

# Permanent link for downloading files

DownloadLink="https://download.maxmind.com/app/geoip_download?edition_id=EDITION_ID&license_key=LICENSE_KEY&suffix=tar.gz"


echo "Info: Starting the database download cycle..."

# Walking through the array
# And downloading database in current directory

for EditionID in "${EditionIDs[@]}"
do

  echo "Info: Current base is $EditionID"

  EditionIDArchive=$EditionID.mmdb.gz
  EditionIDBase=$EditionID.mmdb

  # Replacing tags to real variables

  EditionDownloadLink=$DownloadLink
  EditionDownloadLink="${EditionDownloadLink/EDITION_ID/$EditionID}"
  EditionDownloadLink="${EditionDownloadLink/LICENSE_KEY/$LicenseKey}"

  echo $EditionDownloadLink

  # Downloading Bases

  echo "Info: Download the archive from the MaxMind server..."

  curl $EditionDownloadLink --output $EditionIDArchive

  # Checking if the file has been downloaded, or is there an error from the api?
  # The file command checks the file header. A correct archive will return "gzip compressed data"
  if ! file "$EditionIDArchive" | grep -q "gzip compressed data"; then
    echo "Error: MaxMind server error when downloading $EditionID:" >&2
    # Output the error text (for example: "Invalid license key")
    EditionIDArchiveError=$(cat "$EditionIDArchive")
    echo "Error: $EditionIDArchiveError" >&2
    # Delete temporary downloading File
    echo "Info: Temporary files deleted ..."
    rm -f "$EditionIDArchive"
    exit 1
  fi

  echo "Info: The archive has been downloaded successfully."

  # Getting the path to the Destination file

  echo "Info: Search for the path of the database file inside the archive..."

  EditionIDTargetPath=$(tar -tf $EditionIDArchive | grep $EditionIDBase)

  # Extracting the final file from the archive

  echo "Info: Unpacking the database file..."

  tar -zxf $EditionIDArchive $EditionIDTargetPath

  # Moving the destination file to the current directory

  echo "Info: Moving the file to the current directory..."

  mv $EditionIDTargetPath $EditionIDBase

  # Delete temporary Extractiong directory

  echo "Info: Clearing temporary files and folders..."

  rm -rf $(dirname $EditionIDTargetPath)

  # Delete temporary downloading Archives

  rm $EditionIDArchive

  echo "Info: The $EditionID database has been updated."

done

echo "Info: All GeoIP databases have been successfully updated!"
