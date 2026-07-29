# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Multi-database support: `Manager` accepts a `connection:` argument, and the
  rake tasks resolve a connection class from the `PG_OBJECTS_CONNECTION_CLASS`
  environment variable ([#296](https://github.com/marinazzio/pg_objects/issues/296))
- New parsed object types: enum, range, base and shell `TYPE` variants,
  `DOMAIN` ([#299](https://github.com/marinazzio/pg_objects/issues/299)),
  `EXTENSION`, `INDEX`, `POLICY`, `RULE`, `SEQUENCE`
  ([#300](https://github.com/marinazzio/pg_objects/issues/300))
- Schema-qualified object names (`schema.name`) recognized in `--!depends_on`
  directives for unambiguous dependency resolution
- Manual `db:create_objects:before` / `db:create_objects:after` rake tasks and
  the `auto_hook_migrations` / `hook_tasks` settings controlling migration hooks
- `transactional` setting wrapping each run in a single database transaction
- Logger severity levels (`info`, `warn`, `error`) with an injectable output
  stream; `error` messages print even in silent mode
  ([#308](https://github.com/marinazzio/pg_objects/issues/308))
- `MalformedStatementError` for statements whose object name cannot be extracted
- README sections on supported object types, multiple databases, and re-run
  idempotency patterns ([#307](https://github.com/marinazzio/pg_objects/issues/307))

### Changed

- Dependency errors now carry context: `CyclicDependencyError#cycle_path`
  (full A → B → A chain), `AmbiguousDependencyError#candidates`/`#referrer`,
  `DependencyNotExistError#referrer`
  ([#301](https://github.com/marinazzio/pg_objects/issues/301),
  [#302](https://github.com/marinazzio/pg_objects/issues/302),
  [#303](https://github.com/marinazzio/pg_objects/issues/303))
- YAML configuration loading is deferred to first config access and resolved
  against `Rails.root` when available, fixing preloader/CWD issues
  ([#304](https://github.com/marinazzio/pg_objects/issues/304))
- Object files are loaded in sorted path order, and the object list is reset on
  each `load_files` call
- Statement type dispatch refactored from a Try chain to a hash lookup

## [1.4.8] - 2026-05-15

### Added

- Mutation testing (Evilution) development configuration

### Changed

- Dependency updates

## [1.4.7] - 2026-02-07

### Changed

- Dependency updates (notably pg_query 6.2.2 in the development lockfile)

## [1.4.6] - 2026-01-21

### Added

- Ruby 4 support

### Changed

- Dependency updates

[Unreleased]: https://github.com/marinazzio/pg_objects/compare/v1.4.8...HEAD
[1.4.8]: https://github.com/marinazzio/pg_objects/compare/v1.4.7...v1.4.8
[1.4.7]: https://github.com/marinazzio/pg_objects/compare/v1.4.6...v1.4.7
[1.4.6]: https://github.com/marinazzio/pg_objects/compare/v1.4.5...v1.4.6
