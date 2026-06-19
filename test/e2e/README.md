# E2E* Tests for geoipdownload

## Requirements

- Bash 4.0+

# Testing

This is end-to-end (e2e) testing with an imitation of the original server: 
instead of contacting the real MaxMind server, we substitute the `DOWNLOAD_URL_TEMPLATE` constant 
so that the program downloads files locally (via the `file://` protocol), using a fake config and a fake database directory.

Three test scripts are provided. All of them are based on the same scenario, 
differing only in which `geoipdownload` flags are passed and, accordingly, 
which source is used for the config file and the database directory:

| Script | Command | Config source | Database directory source |
|---|---|---|---|
| `test_with_c_and_d.bash` | `./geoipdownload -f GeoIP.conf -d . -v` | explicit `-f` flag | explicit `-d` flag |
| `test_with_c_config.bash` | `./geoipdownload -f GeoIP.conf -v` | explicit `-f` flag | `DatabaseDirectory` value inside `GeoIP.conf` |
| `test_with_c_default.bash` | `./geoipdownload -f GeoIP.conf -v` | explicit `-f` flag | program's default database directory (patched to the test directory) |

## Steps

All three scripts perform the same general sequence:

- Create a temporary `test/check` directory
- Copy a placeholder `GeoIP.conf` config and the `geoipdownload` binary into it
- Patch `DOWNLOAD_URL_TEMPLATE` inside the copied binary to point to `file://.../test-data/EDITION_ID.mmdb.tar.gz`
- (`test_with_c_config.bash` and `test_with_c_default.bash` only) patch the binary's default config/database-directory constants to point to the test directory
- (`test_with_c_config.bash` only) set the `DatabaseDirectory` value inside `GeoIP.conf` to the test directory
- Run `geoipdownload` with the corresponding flags
- Clean up the temporary directory

## Running

Running with explicit arguments for Config and Directory in program:

```shell
bash test_with_c_and_d.bash
```

Running with explicit Config argument, which have `DatabaseDirectory` path in Config-file:

```shell
bash test_with_c_config.bash
```

Running with explicit Config argument, which not have `DatabaseDirectory` path in Config-file, and we should use Defaults path:

```shell
bash test_with_c_default.bash
```


## Author

- [Dmitriy Kepov][link-author]


## License

The MIT License (MIT). Please see [License File][license] for more information.


---

[link-author]: https://github.com/dkepov
[license]: ../LICENSE
