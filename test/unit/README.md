# Unit Tests for geoipdownload

Unit tests for [geoipdownload](./geoipdownload) written 
with [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

## Requirements

- Bash 4.0+
- BATS 1.5+

### Installing BATS

**Debian / Ubuntu**
```bash
apt-get install bats
```

**macOS (Homebrew)**
```bash
brew install bats-core
```

**From source (any Linux)**
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

Verify the installation:
```bash
bats --version
```

## Structure

```
tests/
├── helpers.bash          # Shared setup, teardown, and helper functions
├── test_messaging.bats   # message(), err(), info(), version(), usage()
├── test_config.bats      # take_checked_config_exists()
├── test_directory.bats   # take_checked_directory_exists_and_writable()
├── test_readers.bats     # read_account_id(), read_license_key(),
│                         # read_edition_ids(), read_database_directory()
├── test_builders.bats    # build_download_url(), build_archive_name(),
│                         # build_database_name()
├── test_lock.bats        # acquire_lock(), release_lock()
├── test_archive.bats     # extract_database_from_archive(),
│                         # delete_database_archive()
└── test_args.bats        # parse_and_default_args()
```

`helpers.bash` is loaded by every test file via `load 'helpers'`. It sources the main script (without calling `main()`) and provides two shared helpers:

- `make_conf <path>` — creates a minimal valid `GeoIP.conf` at the given path
- `make_test_archive <dir> <edition>` — creates a real `.mmdb.tar.gz` archive with a fake `.mmdb` file inside

Each `setup()` creates a fresh temporary directory (`TEST_DIR`) and each `teardown()` removes it, so tests do not interfere with each other.

## Running tests

Place the `test/unit/` directory next to the `geoipdownload` script:

```
project/
├── geoipdownload
└── test/unit/
    ├── helpers.bash
    ├── test_messaging.bats
    └── ...
```

The tests for the current directory are listed below.

If you want to run tests relative to the [geoipdownload](../../geoipdownload) file, replace the "`.`" path with the "`/test/unit`" path ...

Run all tests at once:
```bash
bats .
```

Run a single file:
```bash
bats ./test_lock.bats
```

Run with TAP output (useful for CI):
```bash
bats --tap .
```

Run with a readable report:
```bash
bats --pretty .
```

## Notes

- Tests for file permission checks (`chmod 000`) are automatically skipped when running as `root`, since the superuser bypasses filesystem permission enforcement.
- The `download_database_archive()` function is not covered by unit tests as it performs a live HTTP request to the MaxMind server. Test it manually with valid credentials or mock `curl` in your environment.


## Author

- [Dmitriy Kepov][link-author]


## License

The MIT License (MIT). Please see [License File][license] for more information.


---

[link-author]: https://github.com/dkepov
[license]: ../LICENSE
