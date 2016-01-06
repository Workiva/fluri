# Changelog

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
