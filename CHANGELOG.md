# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2021-04-05
### Added
- Add Changelog file.

### Changed
- Improve `README.md`.
- update to latest base image `nginx:1.21.6`

### Removed
- Do not install [`wkhtmltopdf`](https://github.com/wkhtmltopdf/wkhtmltopdf) any longer in the base image.

## [2.0.0] - 2021-12-28
### Added
- Redirect for TYPO3 login in nginx configuration.

### Changed
- Lift `PHP` version from `7.4` to `8.1`.

## [1.2.0] - 2021-12-27
### Added
- Install `vim` instead of `nano`.
- Add logrotation incl configuration.

### Changed
- Update to latest base image `nginx:1.21.4`.

## [1.1.0] - 2021-07-27
### Added
- Add hook for nginx configuration by child images.

## [1.0.0] - 2021-07-23
### Added
- Add semantic versioning.

### Changed
- Update to latest base image `nginx:1.21.1`.
- Rename default conf for nginx to `default-base.conf` to avoid overwriting of child images which may use `default.conf` as name.

### Removed
- Remove basic auth.