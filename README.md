# geoipdownload

**GeoIP and GeoLite Update Program.**

A lightweight bash alternative to the official `geoipupdate` client from MaxMind.

_Development of this program began even before the official client was released. It has now been finalized._

# GeoIP Database Downloader

Bash script for downloading and updating GeoIP/GeoLite MaxMind databases in the current directory.

- reads `LicenseKey` and `EditionIDs` from `GeoIP.conf`
- downloads MaxMind archives in the format `tar.gz`
- extracts `*.mmdb` files directly to the working folder

It is suitable as an easy alternative to `geoipupdate` if you need a simple and controlled way to update databases.

## Overview

`geoipdownload` is a simple, robust Bash script that downloads and updates MaxMind GeoIP / GeoLite2 databases.

It reads configuration from a `GeoIP.conf` file (just like the official tool), downloads the latest database archives from MaxMind, extracts the `.mmdb` files, and places them in the specified directory.

This script is ideal when you want a minimal, transparent, and easily auditable solution without installing the official Go-based `geoipupdate` tool.

## Requirements

You most likely have the following dependencies. But you can check the list yourself.

- `bash` (version 4+ recommended, uses `mapfile` and other bashisms)
- `curl` — for downloading database archives
- `tar` — for extracting `.mmdb` files from archives
- `file` — for validating downloaded archive type
- `getopt` GNU (util-linux) — for argument parsing
    - On macOS, install via `brew install gnu-getopt` and ensure it's first in `$PATH`
- `grep` GNU with PCRE support (`-P` flag) — for parsing `GeoIP.conf`
- `coreutils` (`rm`, `touch`, `cat`, `printf`, `mkdir`) - they are everywhere

## Features

- Pure Bash implementation with minimal external dependencies: `curl`, `tar`, `file`, `getopt`, `grep`
- Supports all GeoLite2 and GeoIP2 editions
- Full error handling and validation
- Verbose output mode
- Compatible with the same `GeoIP.conf` format used by official `geoipupdate`

## Command Line Usage

```bash
geoipdownload [-f /etc/GeoIP.conf] [-d /usr/share/GeoIP]
```

If run without `-f`/`-d`, the script uses the default config file path `/etc/GeoIP.conf` and the default database directory `/usr/share/GeoIP`:

```bash
geoipdownload
```

You can still specify custom paths explicitly:

```bash
geoipdownload -f /etc/GeoIP.conf -d /usr/share/GeoIP
```

### Parameters

- `-f, --config-file` (optional)  
  Path to the `GeoIP.conf` configuration file.
  Defaults to `/etc/GeoIP.conf` if not specified.

- `-d, --database-directory` (optional)  
  Target directory where `.mmdb` files will be written. The directory must exist and be writable.
  Defaults to `/usr/share/GeoIP` if not specified.

- `-v, --verbose, --vvv`  
  Enable verbose output (shows detailed progress and debug information).

- `-h, --help`  
  Show help message and exit.

This script follows a similar interface to the official `geoipupdate` tool. For complete reference see:  
[geoipupdate.md](https://github.com/maxmind/geoipupdate/blob/main/doc/geoipupdate.md)

## Configuration File (`GeoIP.conf`)

The script expects a configuration file in the same format as the official MaxMind `geoipupdate` tool.

### Required settings:

- `LicenseKey` — Your case-sensitive MaxMind license key.
- `EditionIDs` — Space-separated list of database edition IDs (e.g. `GeoLite2-City GeoLite2-Country GeoLite2-ASN`).

### Optional settings (supported by official tool, partially by this script):

- `DatabaseDirectory` — Directory where databases will be stored (can be overridden via `-d` flag).
- `AccountID` — (Not required for direct download method used by this script)

**Example `GeoIP.conf`:**

```conf
# MaxMind License Key
LicenseKey YOUR_LICENSE_KEY_HERE

# Databases to download
EditionIDs GeoLite2-City GeoLite2-Country GeoLite2-ASN
```

For full documentation of the configuration file, see the official reference:  
[GeoIP.conf.md](https://github.com/maxmind/geoipupdate/blob/main/doc/GeoIP.conf.md)

## The program works visually

This is what a successful database update looks like.

```bash
dkepov@dkepov:/current_project$ ./geoipdownload -f /etc/GeoIP.conf -d /usr/share/GeoIP -vvv
[2026-06-23T03:05:36+0000]: [INFO]  The configuration file 'GeoIP.conf' found and ready for use.
[2026-06-23T03:05:36+0000]: [INFO]  The database directory '/usr/share/GeoIP' found and ready for use.
[2026-06-23T03:05:36+0000]: [INFO]  The 'LicenseKey' has been successfully read.
[2026-06-23T03:05:36+0000]: [INFO]  The 'EditionIDs' has been successfully read.
[2026-06-23T03:05:36+0000]: [INFO]  The following databases were found for download: ('GeoLite2-ASN' 'GeoLite2-City' 'GeoLite2-Country')
[2026-06-23T03:05:36+0000]: [INFO]  The databases downloading cycle is starting ...
[2026-06-23T03:05:36+0000]: [INFO]  The current database is: 'GeoLite2-ASN'
[2026-06-23T03:05:36+0000]: [INFO]  Downloading the database archive from the MaxMind server ...
[2026-06-23T03:05:36+0000]: [INFO]  Downloading the database archive from the MaxMind server is successfully
[2026-06-23T03:05:36+0000]: [INFO]  Extracting the Database file from the Database archive ...
[2026-06-23T03:05:36+0000]: [INFO]  Extracting the Database file from the Database archive is successfully
[2026-06-23T03:05:36+0000]: [INFO]  The 'GeoLite2-ASN' database has been updated.
[2026-06-23T03:05:36+0000]: [INFO]  The current database is: 'GeoLite2-City'
[2026-06-23T03:05:36+0000]: [INFO]  Downloading the database archive from the MaxMind server ...
[2026-06-23T03:05:36+0000]: [INFO]  Downloading the database archive from the MaxMind server is successfully
[2026-06-23T03:05:36+0000]: [INFO]  Extracting the Database file from the Database archive ...
[2026-06-23T03:05:36+0000]: [INFO]  Extracting the Database file from the Database archive is successfully
[2026-06-23T03:05:36+0000]: [INFO]  The 'GeoLite2-City' database has been updated.
[2026-06-23T03:05:36+0000]: [INFO]  The current database is: 'GeoLite2-Country'
[2026-06-23T03:05:36+0000]: [INFO]  Downloading the database archive from the MaxMind server ...
[2026-06-23T03:05:36+0000]: [INFO]  Downloading the database archive from the MaxMind server is successfully
[2026-06-23T03:05:36+0000]: [INFO]  Extracting the Database file from the Database archive ...
[2026-06-23T03:05:36+0000]: [INFO]  Extracting the Database file from the Database archive is successfully
[2026-06-23T03:05:36+0000]: [INFO]  The 'GeoLite2-Country' database has been updated.
[2026-06-23T03:05:36+0000]: [INFO]  All GeoIP databases have been successfully updated!
```

## Code Quality

This script did checked with [ShellCheck](https://www.shellcheck.net/), a static analysis tool that catches common bugs and pitfalls in shell scripts. 
No warnings or errors are reported.

You can verify it yourself:

```bash
shellcheck geoipdownload
```

## Useful MaxMind Resources

- [MaxMind GeoIP Portal](https://dev.maxmind.com/geoip/) — Main page for GeoIP and GeoLite products, services, and documentation.
- [Updating GeoIP and GeoLite Databases](https://dev.maxmind.com/geoip/updating-databases/) — Official guide on how to keep your databases up to date.
- [City and Country Databases – Example Files](https://dev.maxmind.com/geoip/docs/databases/city-and-country/#example-files) — Examples and structure of City/Country database content.
- [MaxMind-DB File Format Specification](https://maxmind.github.io/MaxMind-DB/) — Technical specification of the `.mmdb` binary database format.

## Original Project

- https://github.com/maxmind/geoipupdate


## Author

- [Dmitriy Kepov][link-author]


## License

The MIT License (MIT). Please see [License File][license] for more information.


---

[link-author]: https://github.com/dkepov
[license]: LICENSE
