# geoipdownload

Analog for Official GeoIpUpdate

# GeoIP Database Downloader

Bash script for downloading and updating GeoIP/GeoLite MaxMind databases in the current directory.

- reads `LicenseKey` and `EditionIDs` from `GeoIP.conf`
- downloads MaxMind archives in the format `tar.gz`
- extracts `*.mmdb` files directly to the working folder

It is suitable as an easy alternative to `geoipupdate` if you need a simple and controlled way to update databases.



# Original Project

https://github.com/maxmind/geoipupdate

# Documentation for Updating Database

https://dev.maxmind.com/geoip/updating-databases/


# Credits

- [Dmitriy Kepov][link-author]


# License

The MIT License (MIT). Please see [License File][license] for more information.


---

[link-author]: https://github.com/dkepov
[license]: LICENSE
