# geoipdownload

**GeoIP and GeoLite Update Program.**

Similar to the official ``geoipupdate`` client.

# Testing

Testing requires some manipulation.

Since this is a small program and there's no goal of end-to-end testing, we can make things easier for ourselves.

# Why bother?

Nobody's stopping you from testing with a real account.
Even better.

We need to conduct full end-to-end testing.
You can take the following approach, the one below.

We won't use a real server.

## Steps

Required:

- Use a config filled with placeholders
- Simulate a server to serve files
- Replace `DOWNLOAD_URL_TEMPLATE` with the URL in the program

## Preparing the server

The server must be run in the current directory.

How to run the server in a local directory:

- Python: `python -m http.server 8080`
- PHP: `php -S localhost:8080`
- NPX/Node.js: `npx http-server -p 8080`

Checking that the server is running: [`http://localhost:8080`](http://localhost:8080)

## Preparing the program

Changes to the program:

- Copy the program to another location
- Open the (copied) program file
- Replace the URL in the `DOWNLOAD_URL_TEMPLATE` constant with the following `http://localhost:8080/EDITION_ID.mmdb.tar.gz`
- Save changes

Note that for simplicity, we're changing the URL significantly.

## Testing

Important: You must run this without using actual files and directories.

It's best to follow these steps:

- `cd test` (in the current directory)
- `mkdir check`
- `cp ./../GeoIP.conf ./check/GeoIP.conf`
- `cp ./../geoipdownload.bash ./check/geoipdownload.bash`
- `sed -i "s|DOWNLOAD_URL_TEMPLATE='.*'|DOWNLOAD_URL_TEMPLATE='http://localhost:8080/EDITION_ID.mmdb.tar.gz'|g" ./check/geoipdownload.bash`
- `cd check`
- `./geoipdownload.bash -f GeoIP.conf -d . -v`


## Original database files

The original files can be found in the corresponding Maxmind project.

https://github.com/maxmind/MaxMind-DB/tree/main/test-data


## Author

- [Dmitriy Kepov][link-author]


## License

The MIT License (MIT). Please see [License File][license] for more information.


---

[link-author]: https://github.com/dkepov
[license]: LICENSE
