# fluri 
[![Pub](https://img.shields.io/pub/v/fluri.svg)](https://pub.dartlang.org/packages/fluri)
[![Build Status](https://travis-ci.org/Workiva/fluri.svg?branch=master)](https://travis-ci.org/Workiva/fluri)
[![codecov.io](http://codecov.io/github/Workiva/fluri/coverage.svg?branch=master)](http://codecov.io/github/Workiva/fluri?branch=master)
[![documentation](https://img.shields.io/badge/Documentation-fluri-blue.svg)](https://www.dartdocs.org/documentation/fluri/latest/)

> Fluri is a fluent URI library for Dart built to make URI mutation easy.

The `dart:core.Uri` class provides an immutable representation of URIs, which makes it difficult to incrementally build
them or update them at a later time. If you wanted to build a long URI from the individual pieces, you would do something like this:

```dart
Uri uri = new Uri(
  scheme: 'https',
  host: 'example.com',
  path: 'path/to/resource'
);
```

If you later wanted to update the path and add a query parameter, you'd have to do this:

```dart
uri = uri.replace(
  path: 'new/path',
  query: 'foo=true'
);
```

Now let's say you want update the query without losing what you already have:

```dart
Map query = new Map.from(uri.queryParameters);
query['bar'] = '10';
uri = uri.replace(queryParameters: query);
```

As you can see, incremental or fluent-style URI mutations become a hassle with the core `Uri` class.

With fluri, the above interactions are easy:

```dart
import 'package:fluri/fluri.dart';

Fluri fluri = new Fluri()
  ..scheme = 'https'
  ..host = 'example.com'
  ..path = 'path/to/resource';

fluri
  ..path = 'new/path'
  ..query = 'foo=true';

fluri.updateQuery({'bar': '10'});
```

Additional methods like `appendToPath` and `setQueryParam` make it easy to
build on top of a base URL:

```dart
import 'package:fluri/fluri.dart';

Fluri base = new Fluri('https://example.com/base/');

Fluri fluri = new Fluri.from(base)
  ..appendToPath('path/to/resource')
  ..setQueryParam('count', '10');
```

## Development

This project leverages [the dart_dev package](https://github.com/Workiva/dart_dev)
for most of its tooling needs, including static analysis, code formatting,
running tests, collecting coverage, and serving examples. Check out the dart_dev
readme for more information.