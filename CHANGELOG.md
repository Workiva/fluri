# Changelog

## 1.3.0

- Add a `removeQueryParam()` method.

## 1.2.8

- Readme updates.

## 1.2.7

- Readme updates.

## 1.2.6

- Drop Dart 1 support.

## 1.2.5

- **Improvement:** Dart 2 compatible! CI now runs on Dart 2 stable and Dart 1.

## 1.2.4

- **Improvement:** Initial Dart 2 and DDC compatibility changes.

- **Documentation:** Add a `CODEOWNERS` file.

## 1.2.3

- **Tech Debt:** Update some dependency ranges for DDC compatibility.

## 1.2.2

- **Tech Debt:** Add and address lints.

## 1.2.1

- **Bug Fix:** Calling `.appendToPath()` will check for and prevent double
  slashes when joining the current path with the additional path.

- **Documentation:** Add GitHub Issue and Pull Request templates.

## 1.2.0

- **Feature:** Support for multi-value parameters.

- **Dart SDK:** In order to support multi-value parameters, the minimum required
  Dart SDK version is now 1.15.0 since that is when the `queryParametersAll`
  field was added to the `Uri` class.

## 1.1.1

- **Bug Fix:** `FluriMixin` now defaults to an empty URI when `uri` is set to
  null.

## 1.1.0

**New Features:**

- `appendToPath(path)` - append a path literal to the current path.
- `addPathSegment(segment)` - add a single path segment to the current path.
- `setQueryParam(param, value)` - set a single query parameter.
- `Fluri.from(other)` - construct a `Fluri` instance from another.
- `Fluri.fromUri(uri)` - construct a `Fluri` instance from a `Uri` instance.

## 1.0.1

_No source changes in this release._

- Add code coverage reporting.
- Minor fixes and improvements to the readme.
- Code formatting improvements thanks to `dartfmt`.

## 1.0.0

- Initial version of Fluri: a fluent URI library for Dart built to make URI
  mutation easy.
