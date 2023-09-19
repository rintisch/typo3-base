# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.1.0] - 2023-09-19
### Added
* Add apt package `patch` to enable installation of patches.

### Removed
* Removed docker default volumes for site configurations and labels.

## [3.0.0] - 2023-07-10
### Changed
- Lift to base image `nginx:1.25.1`.
- Create image according to Semantic Versioning not only with patch version but also with major and minor version.
- Changed name of resulting image from `docker.pkg.github.com/rintisch/typo3-base/nginx-typo3-base` to `ghcr.io/rintisch/typo3-base`.

## [2.4.0] - 2023-02-04
### Added
- Add .gitignore

### Changed
- Run cron as user `nginx`
- Lift to base image `nginx:1.23.3`.
- Lift supercronic to `v0.2.1`.
- Lift `PHP` version from `7.4` to `8.1`.

## [2.3.0] - 2022-10-25
### Added
- `unzip` in container

### Changed
- Version of nodejs in container (v12 -> v16)
- Update to latest base image `nginx:1.23.2`
- Use `actions/checkout@v3` in github Actions

## [2.2.1] - 2022-07-15
### Changed
- Fix cronjob to run TYPO3 scheduler

## [2.2.0] - 2022-05-12
### Added
- Sent cache header for all kind of fonts

### Changed
- Try to fix logrotate

## [2.1.0] - 2022-04-05
### Added
- Add Changelog file.

### Changed
- Improve `README.md`.
- Update to latest base image `nginx:1.21.6`

### Removed
- Do not install [`wkhtmltopdf`](https://github.com/wkhtmltopdf/wkhtmltopdf) any longer in the base image.

## [2.0.0] - 2021-12-28
### Added
- Redirect for TYPO3 login in nginx configuration.

### Changed
- Lift `PHP` version from `7.4` to `8.1`.

## [1.3.0] - 2023-02-04
### Changed
- Run cron as user `nginx`

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

