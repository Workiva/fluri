# fluri

[![Pub](https://img.shields.io/pub/v/fluri.svg)](https://pub.dev/packages/fluri)
[![Build Status](https://travis-ci.org/Workiva/fluri.svg?branch=master)](https://travis-ci.org/Workiva/fluri)
[![documentation](https://img.shields.io/badge/Documentation-fluri-blue.svg)](https://pub.dev/documentation/fluri/latest/)

## Examples/Usage

> Fluri is a fluent URI library for Dart built to make URI mutation easy.

The `dart:core.Uri` class provides an immutable representation of URIs, which
makes it difficult to incrementally build them or update them at a later time.
If you wanted to build a long URI from the individual pieces, you would do
something like this:

```dart
var uri = Uri(
  scheme: 'https',
  host: 'example.com',
  path: 'path/to/resource'
);
```

If you later wanted to update the path and add a query parameter, you'd have to
do this:

```dart
uri = uri.replace(
  path: 'new/path',
  query: 'foo=true'
);
```

Now let's say you want update the query without losing what you already have:

```dart
var query = Map.from(uri.queryParameters);
query['bar'] = '10';
uri = uri.replace(queryParameters: query);
```

As you can see, incremental or fluent-style URI mutations become a hassle with
the core `Uri` class.

With fluri, the above interactions are easy:

```dart
import 'package:fluri/fluri.dart';

var fluri = Fluri()
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

var base = Fluri('https://example.com/base/');

var fluri = Fluri.from(base)
  ..appendToPath('path/to/resource')
  ..setQueryParam('count', '10');
```

Fluri also supports multi-value parameters. To access the query parameters as
`Map<String, List<String>>`, use `queryParametersAll` (just like the `Uri`
class):

```dart
var fluri = Fluri('/resource?format=json&format=text');
print(fluri.queryParameters); // {'format': 'text'}
print(fluri.queryParametersAll); // {'format': ['json', 'text']}
```

To set a single query parameter to multiple values:

```dart
var fluri = Fluri('/resource');
fluri.setQueryParam('format', ['json', 'text']);
print(fluri.queryParametersAll); // {'format': ['json', 'text']}
```

Using `setQueryParam` will always replace existing values:

```dart
var fluri = Fluri('/resource');
fluri.setQueryParam('format', ['json', 'text']);
fluri.setQueryParam('format', ['binary', 'text']);
print(fluri.queryParametersAll); // {'format': ['binary', 'text']}
```

You can use the `queryParametersAll` setter to set the entire query with
multi-value param support:

```dart
var fluri = Fluri('/resource');
fluri.queryParametersAll = {'format': ['json', 'text'], 'count': ['5']}
print(fluri.queryParametersAll); // {'format': ['json', 'text'], 'count': ['5']}
```

Again, if you need to preserve existing query parameters, you can use the
`updateQuery` method to do so. Set `mergeValues: true` and any values that you
provide will be merged with existing values:

```dart
var fluri = Fluri('/resource?format=json');
fluri.updateQuery({'format': ['binary', 'text'], 'count': '5'}, mergeValues: true);
print(fluri.queryParametersAll); // {'format': ['binary', 'json', 'text'], 'count': ['5']}
```
