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
#  geoipdownload -f CONFIG_FILE -d TARGET_DIRECTORY
#
# Example to use:
#  geoipdownload -f /etc/GeoIP.conf -d /usr/share/GeoIP
#

# Strict mode
set -o errexit
set -o nounset
set -o pipefail


# Constants
readonly DOWNLOAD_URL_TEMPLATE='https://download.maxmind.com/app/geoip_download?edition_id=EDITION_ID&license_key=LICENSE_KEY&suffix=tar.gz'
readonly CURL_CONNECT_TIMEOUT=5
readonly CURL_MAX_TIME=60

CONFIG_FILE=""
DATABASE_DIRECTORY=""

VERBOSE=0

#
# Any message function template
#
message() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*"
} # mess()

#
# Error message
#
err() {
  local msg
  msg=$(message "[ERROR]" "$*")
  echo "${msg}"  >&2
} # err()

#
# Info message
#
info() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    local msg
    msg=$(message "[INFO] " "$*")
    echo "${msg}" >&2
  fi
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


Usage: geoipdownload [FLAGS] -f CONFIG_FILE -d TARGET_DIRECTORY

FLAGS:

  -h, --help                    Show this help message.
  -v, --vvv, --verbose          Print informational and error messages.

PARAMS (required):

  -f, --config-file             Path to GeoIP.conf.
                                This is required.
                                See GeoIP.conf and its documentation for
                                more information.

  -d, --database-directory      Path to Directory where .mmdb files will be written.
                                This is required.
                                For install databases to a custom directory
                                you need check documentation.

EOF
}

#
# Parsing of arguments
#
# Validation of the argument string via getopt
# Important: we are suppressing the verification of unknown parameters
#
parse_args() {

  local options
  local short_options
  local long_options

  # Validation of the argument string via getopt
  # --options sets short flags, --longoptions sets long flags.
  # "$@" passes the current script arguments.

  # Configuring the getopt utility
  short_options='f:d:vh'
  long_options='config-file:,database-directory:,verbose,vvv,help'

  # Important: we are suppressing the verification of unknown parameters with --quiet
  options=$(getopt --quiet --options "$short_options" --longoptions "$long_options" --name "$0" -- "$@") 2>/dev/null || true

  # Overwriting the positional parameters of the script ($1, $2...) the cleared string from getopt
  eval set -- "$options"

  while true; do
    case "${1:-}" in
      -f|--config-file)
        if [[ -z "${2:-}" || "$2" == -* || "$2" == --* ]]; then
          break
        fi
        CONFIG_FILE="$2"
        shift 2
        ;;
      -d|--database-directory)
        if [[ -z "${2:-}" || "$2" == -* || "$2" == --* ]]; then
          break
        fi
        DATABASE_DIRECTORY="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -v|--vvv|--verbose)
        VERBOSE=1
        shift
        ;;
      --)
        shift
        break
        ;;
      "")
        break
        ;;
      *)
        shift
        ;;
    esac
  done

# Checking required parameters (if the script was run without any flags at all)
if [[ -z "$CONFIG_FILE" || -z "$DATABASE_DIRECTORY" ]]; then
  err "The '--config-file (-f)' and '--database-directory (-d)' parameters are strictly required!"
  exit 1
fi

} # parse_args()

#
# Check Config exists
#
# Checking Config on exists
# We display errors and information messages inside
#
check_config_exists() {

  local conf_file="$1"

  if [[ ! -f "$conf_file" ]]; then
    err "The configuration file '$conf_file' not found!"
    exit 1
  fi

  if [[ ! -r "$conf_file" ]]; then
    err "The configuration file '$conf_file' cannot be read!"
    exit 1
  fi

  info "The configuration file '$conf_file' found and ready for use."

} # check_config_exists()

#
# Check Directory exists and writable
#
# Checking Directory on exists and writable
# We display errors and information messages inside
#
check_directory_exists_and_writable() {

  local database_directory="$1"

  if [[ ! -d "$database_directory" ]]; then
    err "The database directory '$database_directory' not found!"
    exit 1
  fi

  if [[ ! -w "$database_directory" ]]; then
    err "The database directory '$database_directory' is not writable!"
    exit 1
  fi

  # We are trying to create a hidden test file
  write_test_file="${database_directory}/.write_test"
  if touch "$write_test_file" 2>/dev/null; then
    # Deleting it if it was created successfully
    rm -f "$write_test_file"
  else
    err "The database directory '$database_directory' is not writable!"
    exit 1
  fi

  info "The database directory '$database_directory' found and ready for use."

} # check_directory_exists_and_writable()

#
# Read license key
#
# Reading license key to variable
# We display errors and information messages inside
#
read_license_key() {

  local conf_file="$1"
  local license_key

  license_key=$(grep -oP '^LicenseKey\s+\K\S+' "$conf_file")

  # Checking the existence of the 'LicenseKey' in the configuration file
  if [ -z "$license_key" ]; then
    err "The 'LicenseKey' parameter is empty or missing in '$conf_file'!"
    exit 1
  fi

  info "The 'LicenseKey' has been successfully read."

  printf '%s' "${license_key}"

} # read_license_key()

#
# Read edition ids
#
# Reading edition ids to array variable
# We display errors and information messages inside
#
read_edition_ids() {

  local conf_file="$1"
  local edition_ids
  local edition_ids_line

  edition_ids_line=$(grep -Po "(?<=EditionIDs\s).*" "$conf_file")

  # Checking the existence of the 'EditionIDs' in the configuration file
  if [ -z "$edition_ids_line" ]; then
    err "The 'EditionIDs' parameter is empty or missing in '$conf_file'!"
    exit 1
  fi

  info "The 'EditionIDs' has been successfully read."

  #declare -a edition_ids=(
  #  "GeoLite2-ASN"
  #  "GeoLite2-City"
  #  "GeoLite2-Country"
  #)

  read -ra edition_ids <<< "$edition_ids_line";

  edition_ids_line=$(printf "'%s' " "${edition_ids[@]}")
  edition_ids_line=${edition_ids_line% }
  info "The following databases were found for download: (${edition_ids_line})"

  printf '%s\n' "${edition_ids[@]}"

} # read_edition_ids()

#
# Build download url
#
# Building download url for current database
# We display errors and information messages inside
#
build_download_url() {

  local edition_id="$1"
  local license_key="$2"
  local url="${DOWNLOAD_URL_TEMPLATE}"

  url="${url/EDITION_ID/${edition_id}}"
  url="${url/LICENSE_KEY/${license_key}}"

  printf '%s' "${url}"

} # build_download_url()

#
# Build archive name
#
# Building archive name for current database
# We display errors and information messages inside
#
build_archive_name() {

    local edition_id="$1"
    local edition_id_archive

    edition_id_archive="${edition_id}.mmdb.gz"

    printf '%s' "${edition_id_archive}"

} # build_archive_name()

#
# Build database name
#
# Building database name for current database
# We display errors and information messages inside
#
build_database_name() {

    local edition_id="$1"
    local edition_id_database

    edition_id_database="${edition_id}.mmdb"

    printf '%s' "${edition_id_database}"

} # build_archive_name()

#
# Download database archive
#
# Downloading archive database from download_url into archive_name
# We display errors and information messages inside
#
download_database_archive() {

  local download_url="$1"
  local archive_name="$2"
  local curl_exit_code=0

  # CURL settings:
  # -sS : Hide the progress bar, but show a network error if it happens
  # --fail : Return an error code if the server responds with 404, 500, etc.
  # --connect-timeout : Wait no more than X seconds to establish a connection
  # --max-time : General limit time to download one file (optional, for security reasons)
  curl -sS \
    --connect-timeout "$CURL_CONNECT_TIMEOUT" \
    --max-time "$CURL_MAX_TIME" \
    --output "$archive_name" \
    "$download_url"

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

} # download_database_archive()

#
# Main function
#
main() {

  local license_key
  local edition_ids
  local edition_id
  local download_url
  local archive_name
  local database_name

  # Parsing of arguments
  parse_args "$@"

  # Checking Config on exists
  check_config_exists "$CONFIG_FILE"

  # Checking Directory on exists and writable
  check_directory_exists_and_writable "$DATABASE_DIRECTORY"

  # Will be working in current directory
  cd "${DATABASE_DIRECTORY}"

  # Reading Licence name for downloading
  license_key=$(read_license_key "${CONFIG_FILE}")

  # Reading Database names for downloading
  mapfile -t edition_ids < <(read_edition_ids "${CONFIG_FILE}")

  # In current point we are ready for downloading of databases

  info "The databases downloading cycle is starting ..."

  # Walking through the array
  # And downloading database in current directory

  for edition_id in "${edition_ids[@]}"
  do

    info "The current database is: '$edition_id'"

    # Building download url for current database
    download_url="$(build_download_url "${edition_id}" "${license_key}")"

    # Building archive name for current database
    archive_name="$(build_archive_name "${edition_id}")"

    # Building database name for current database
    database_name="$(build_database_name "${edition_id}")"

    # Downloading Bases

    info "Download the archive from the MaxMind server..."

    # Downloading archive database from download_url into archive_name
    download_database_archive "${download_url}" "${archive_name}"

    # Checking if the file has been downloaded, or is there an error from the api?
    # The file command checks the file header. A correct archive will return "gzip compressed data"
    if ! file "$archive_name" | grep -q "gzip compressed data"; then
      err "MaxMind server error when downloading '$edition_id':"
      # Output the error text (for example: "Invalid license key")
      edition_id_archive_error=$(cat "$archive_name")
      err "$edition_id_archive_error"
      # Delete temporary downloading File
      info "Temporary files deleted ..."
      rm -f "$archive_name"
      exit 1
    fi

    info "The archive has been downloaded successfully."

    # Getting the path to the Destination file

    info "Search for the path of the database file inside the archive..."

    edition_id_target_path=$(tar -tf "$archive_name" | grep "$database_name")

    # Extracting the final file from the archive

    info "Unpacking the database file..."

    tar -zxf "$archive_name" "$edition_id_target_path"

    # Moving the destination file to the current directory

    info "Moving the file to the current directory..."

    mv "$edition_id_target_path" "$database_name"

    # Delete temporary Extractiong directory

    info "Clearing temporary files and folders..."

    rm -rf "$(dirname "$edition_id_target_path")"

    # Delete temporary downloading Archives

    rm -f "$archive_name"

    info "The $edition_id database has been updated."

  done

  info "All GeoIP databases have been successfully updated!"

} # main()

main "$@"
