#!/usr/bin/env bash

TargetDir=$(pwd)

cd ${TargetDir}


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

EditionIDsCount=${#EditionIDs[@]}
EditionIDsLine=$(printf "'%s' " "${EditionIDs[@]}")
EditionIDsLine=${EditionIDsLine% }
echo "Info: Download databases ${EditionIDsCount} found: (${EditionIDsLine})"

# Permanent link for downloading files

DownloadLink="https://download.maxmind.com/app/geoip_download?edition_id=EDITION_ID&license_key=LICENSE_KEY&suffix=tar.gz"


echo "Info: Starting the database download cycle..."

# Walking through the array
# And downloading database in current directory

for EditionID in "${EditionIDs[@]}"
do

  echo "Info: Current base is: '$EditionID'"

  EditionIDArchive=$EditionID.mmdb.gz
  EditionIDBase=$EditionID.mmdb

  # Replacing tags to real variables

  EditionDownloadLink=$DownloadLink
  EditionDownloadLink="${EditionDownloadLink/EDITION_ID/$EditionID}"
  EditionDownloadLink="${EditionDownloadLink/LICENSE_KEY/$LicenseKey}"

  # Downloading Bases

  echo "Info: Download the archive from the MaxMind server..."

  # Сurl settings:
  # -sS : Hide the progress bar, but show a network error if it happens
  # --fail : Return an error code if the server responds with 404, 500, etc.
  # --connect-timeout 5 : Wait no more than 5 seconds to establish a connection
  # --max-time 30 : General limit time to download one file (optional, for security reasons)
  curl -sS --connect-timeout 5 --max-time 60 $EditionDownloadLink --output $EditionIDArchive

  # Immediately save the curl return code to a variable
  # The $ variable? stores the status of the last executed command
  CurlExitCode=$?

  # Checking the variable with the Curl Code
  if [ "$CurlExitCode" -ne 0 ]; then
      echo "Error: Curl ended with the code: $ExitCode"
      if [ "$CurlExitCode" -eq 28 ]; then
          echo "Error: The timeout has expired for Curl"
      elif [ "$CurlExitCode" -eq 22 ]; then
          echo "Error: The server returned an HTTP error (for example, 404 or 403 or 500)"
      elif [ "$CurlExitCode" -eq 23 ]; then
          echo "Error: Error writing the file to disk."
      fi
      exit 1
  fi

  # Checking if the file has been downloaded, or is there an error from the api?
  # The file command checks the file header. A correct archive will return "gzip compressed data"
  if ! file "$EditionIDArchive" | grep -q "gzip compressed data"; then
    echo "Error: MaxMind server error when downloading '$EditionID':" >&2
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
