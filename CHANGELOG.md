# Changelog

All notable changes to this gem are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org).

## [Unreleased]

## [0.1.0] - 2026-11-10

Changes since 0.0.12. Versions 0.0.13 and 0.0.14 shipped them under a patch number and are yanked.

### Changed

- **Breaking:** requires Ruby 3.2 or later ([#11](https://github.com/devengoapp/ibancom-ruby/pull/11)).
- **Breaking:** depends on Faraday `>= 2.14.3, < 3` instead of `>= 0.15`. The client already needed Faraday 2, and 2.14.3 is the first release without the open Faraday advisories ([#11](https://github.com/devengoapp/ibancom-ruby/pull/11)).
- Releases are published with trusted publishing and a Sigstore attestation ([#12](https://github.com/devengoapp/ibancom-ruby/pull/12), [#20](https://github.com/devengoapp/ibancom-ruby/pull/20)).

### Security

- `Ibancom::Client#inspect` no longer prints the API key ([#10](https://github.com/devengoapp/ibancom-ruby/pull/10)).

[Unreleased]: https://github.com/devengoapp/ibancom-ruby/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/devengoapp/ibancom-ruby/compare/v0.0.12...v0.1.0
