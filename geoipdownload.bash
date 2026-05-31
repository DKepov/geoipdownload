#!/bin/bash

#
# Download MaxMind GeoIP databases listed in GeoIP.conf into the current
# directory.
#
# The script expects GeoIP.conf in the working directory and writes the
# downloaded .mmdb files there.
#
# Analog for geoipupdate
# https://dev.maxmind.com/geoip/updating-databases/
# https://github.com/maxmind/geoipupdate
#
# Expected GeoIP.conf format:
#  LicenseKey YOUR_LICENSE_KEY
#  EditionIDs GeoLite2-City GeoLite2-Country
#
# How to use:
#  geoipdownload --help
#

# Strict mode
set -o errexit
set -o nounset
set -o pipefail


# Constants
readonly GEOIP_CONF_NAME='GeoIP.conf'
readonly DOWNLOAD_URL_TEMPLATE='https://download.maxmind.com/app/geoip_download?edition_id=EDITION_ID&license_key=LICENSE_KEY&suffix=tar.gz'
readonly CURL_CONNECT_TIMEOUT=5
readonly CURL_MAX_TIME=60

#
# Any message function template
#
mess() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*"
} # mess()

#
# Error message
#
err() {
  local mess=$(mess "[ERROR]" "$*")
  echo "${mess}"  >&2
} # err()

#
# Info message
#
info() {
  local mess=$(mess "[INFO] " "$*")
  echo "${mess}" >&2
} # info()

#
# Usage "--help" function
#
usage() {
  cat <<'EOF'
Download MaxMind GeoIP databases listed in GeoIP.conf 
into the current directory.

The script expects GeoIP.conf in the working directory and writes the
downloaded .mmdb files there.

Expected GeoIP.conf format:
  LicenseKey YOUR_LICENSE_KEY
  EditionIDs GeoLite2-City GeoLite2-Country


Usage: geoipdownload [FLAGS]

FLAGS:

  -h, --help      Show this help message.

EOF
}

#
# Parsing of arguments
#
parse_args() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      *)
        err "Unknown argument: $1"
        exit 1
        ;;
    esac
    shift
  done
} # parse_args()

# 
# Main function
#
main() {

  # Parsing of arguments
  parse_args "$@"

  # Will be working in current directory
  target_dir=$(pwd)

  cd "${target_dir}"

  # The -w flag verifies the existence of the object and the availability of write permissions
  if [ ! -w "$target_dir" ]; then
    err "No rights to write to the directory '$target_dir'!"
    exit 1
  fi

  # We are trying to create a hidden test file.
  if touch .write_test 2>/dev/null; then
    # Deleting it if it was created successfully
    rm -f .write_test
  else
    err "No rights to write to the directory '$target_dir'!"
    exit 1
  fi

  # Checking the existence of a configuration file
  if [ ! -f "$GEOIP_CONF_NAME" ]; then
    err "The configuration file '$GEOIP_CONF_NAME' was not found!"
    exit 1
  fi

  info "The configuration file '$GEOIP_CONF_NAME' was found."

  # Pre-reading full config
  geo_ip_config=$(cat "$GEOIP_CONF_NAME")

  # Getting the License Key

  license_key_var=$(echo "$geo_ip_config" | grep -oP '^LicenseKey\s+\K\S+')

  license_key=$license_key_var

  # Checking the existence of the 'LicenseKey' in the configuration file
  if [ -z "$license_key" ]; then
    err "The 'LicenseKey' parameter is empty or missing in '$GEOIP_CONF_NAME'!"
    exit 1
  fi

  info "The license key has been successfully read."

  # Getting the EditionIDs GeoIP Bases
  # Making List of GeoIP Bases

  #declare -a edition_ids=(
  #  "GeoLite2-ASN"
  #  "GeoLite2-City"
  #  "GeoLite2-Country"
  #)

  edition_ids_var=$(echo "$geo_ip_config" | grep -Po "(?<=EditionIDs\s).*")

  # Checking the existence of the 'EditionIDs' in the configuration file
  if [ -z "$edition_ids_var" ]; then
    err "The 'EditionIDs' parameter is empty or missing in '$GEOIP_CONF_NAME'!"
    exit 1
  fi

  declare -a edition_ids
  read -ra edition_ids <<< "$edition_ids_var";

  edition_ids_count=${#edition_ids[@]}
  edition_ids_line=$(printf "'%s' " "${edition_ids[@]}")
  edition_ids_line=${edition_ids_line% }
  info "Download databases ${edition_ids_count} found: (${edition_ids_line})"

  # Permanent link for downloading files

  info "Starting the database download cycle..."

  # Walking through the array
  # And downloading database in current directory

  for edition_id in "${edition_ids[@]}"
  do

    info "Current base is: '$edition_id'"

    edition_id_archive="${edition_id}.mmdb.gz"
    edition_id_base="${edition_id}.mmdb"

    # Replacing tags to real variables

    edition_download_link=$DOWNLOAD_URL_TEMPLATE
    edition_download_link="${edition_download_link/EDITION_ID/$edition_id}"
    edition_download_link="${edition_download_link/LICENSE_KEY/$license_key}"

    # Downloading Bases

    info "Download the archive from the MaxMind server..."

    # Сurl settings:
    # -sS : Hide the progress bar, but show a network error if it happens
    # --fail : Return an error code if the server responds with 404, 500, etc.
    # --connect-timeout 5 : Wait no more than 5 seconds to establish a connection
    # --max-time 30 : General limit time to download one file (optional, for security reasons)
    curl -sS --connect-timeout "$CURL_CONNECT_TIMEOUT" --max-time "$CURL_MAX_TIME" "$edition_download_link" --output "$edition_id_archive"

    # Immediately save the curl return code to a variable
    # The $ variable? stores the status of the last executed command
    curl_exit_code=$?

    # Checking the variable with the Curl Code
    if [ "$curl_exit_code" -ne 0 ]; then
        err "Curl ended with the code: $curl_exit_code"
        if [ "$curl_exit_code" -eq 28 ]; then
            err "The timeout has expired for Curl"
        elif [ "$curl_exit_code" -eq 22 ]; then
            err "The server returned an HTTP error (for example, 404 or 403 or 500)"
        elif [ "$curl_exit_code" -eq 23 ]; then
            err "Error writing the file to disk."
        fi
        exit 1
    fi

    # Checking if the file has been downloaded, or is there an error from the api?
    # The file command checks the file header. A correct archive will return "gzip compressed data"
    if ! file "$edition_id_archive" | grep -q "gzip compressed data"; then
      err "MaxMind server error when downloading '$edition_id':"
      # Output the error text (for example: "Invalid license key")
      edition_id_archive_error=$(cat "$edition_id_archive")
      err "$edition_id_archive_error"
      # Delete temporary downloading File
      info "Temporary files deleted ..."
      rm -f "$edition_id_archive"
      exit 1
    fi

    info "The archive has been downloaded successfully."

    # Getting the path to the Destination file

    info "Search for the path of the database file inside the archive..."

    edition_id_target_path=$(tar -tf "$edition_id_archive" | grep "$edition_id_base")

    # Extracting the final file from the archive

    info "Unpacking the database file..."

    tar -zxf "$edition_id_archive" "$edition_id_target_path"

    # Moving the destination file to the current directory

    info "Moving the file to the current directory..."

    mv "$edition_id_target_path" "$edition_id_base"

    # Delete temporary Extractiong directory

    info "Clearing temporary files and folders..."

    rm -rf "$(dirname "$edition_id_target_path")"

    # Delete temporary downloading Archives

    rm -f "$edition_id_archive"

    info "The $edition_id database has been updated."

  done

  info "All GeoIP databases have been successfully updated!"

} # main()

main "$@"
