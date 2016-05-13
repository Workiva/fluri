// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library fluri.test.fluri_test;

import 'package:fluri/fluri.dart';
import 'package:test/test.dart';

/// A suite of common tests that should be run against an instance of [Fluri],
/// an instance of a class that extends [FluriMixin], and an instance of a class
/// that mixes in [FluriMixin].
void commonFluriTests(FluriMixin getFluri()) {
  test('should allow setting the scheme', () {
    getFluri().scheme = 'https';
    expect(getFluri().scheme, equals('https'));
  });

  test('should allow setting the host', () {
    getFluri().host = 'example.org';
    expect(getFluri().host, equals('example.org'));
  });

  test('should allow setting the port', () {
    getFluri().port = 8080;
    expect(getFluri().port, equals(8080));
  });

  test('should allow setting the path', () {
    getFluri().path = 'new/path';
    expect(getFluri().path, equals('/new/path'));
  });

  test('should allow path with trailing slash', () {
    getFluri().path = 'path/with/trailing/';
    expect(getFluri().path, equals('/path/with/trailing/'));
  });

  test('should allow setting the path via a list of path segments', () {
    getFluri().pathSegments = ['new', 'path'];
    expect(getFluri().pathSegments, equals(['new', 'path']));
  });

  test('should allow appending to the path', () {
    getFluri().path = 'base/path/';
    getFluri().appendToPath('segment');
    expect(getFluri().path, equals('/base/path/segment'));
  });

  test('should allow appending multiple path segments', () {
    getFluri().path = 'base/path/';
    getFluri().appendToPath('with/additional/segments');
    expect(getFluri().path, equals('/base/path/with/additional/segments'));
  });

  test('should allow adding a path segment', () {
    getFluri().path = 'base/path';
    getFluri().addPathSegment('segment');
    expect(getFluri().path, equals('/base/path/segment'));
  });

  test('should allow setting the query', () {
    getFluri().query = 'limit=5&format=text';
    expect(getFluri().query, equals('limit=5&format=text'));
  });

  test('should allow setting the query via a map of query parameters', () {
    getFluri().queryParameters = {'limit': '5', 'format': 'text'};
    expect(getFluri().query, equals('limit=5&format=text'));
  });

  test('should allow setting a single query parameter', () {
    getFluri().setQueryParam('test', 'true');
    expect(getFluri().queryParameters, containsPair('test', 'true'));
  });

  test('should allow updating the query parameters', () {
    getFluri().updateQuery({'limit': '5', 'format': 'text'});
    expect(getFluri().query, equals('limit=5&format=text'));
  });

  test('should allow setting the fragment', () {
    getFluri().fragment = 'hashtag';
    expect(getFluri().fragment, equals('hashtag'));
  });
}

/// A class to exercise extending [FluriMixin].
class ExtendingClass extends FluriMixin {
  /// Construct an instance from a [uri].
  ExtendingClass(String uri) {
    this.uri = Uri.parse(uri);
  }
}

/// A class to exercise mixing in [FluriMixin].
class MixingClass extends Object with FluriMixin {
  /// Construct an instance from a [uri].
  MixingClass(String uri) {
    this.uri = Uri.parse(uri);
  }
}

/// Runs the Fluri test suite.
void main() {
  String url = 'http://example.com/path/to/resource?limit=10&format=list#test';

  group('Fluri', () {
    Fluri fluri;

    setUp(() {
      fluri = new Fluri(url);
    });

    test('should accept an optional starting URI upon construction', () {
      expect(new Fluri().toString(), equals(''));
      expect(new Fluri('example.com').toString(), equals('example.com'));
    });

    test('should be an empty uri by default', () {
      expect(new Fluri().toString(), equals(''));
    });

    test('should allow replacing the entire url', () {
      fluri.uri = Uri.parse('example.com/path');
      expect(fluri.toString(), equals('example.com/path'));
    });

    test('should support constructing from another Fluri instance', () {
      Fluri other = new Fluri('example.com');
      expect(new Fluri.from(other).toString(), equals('example.com'));
    });

    test('should support constructing from a Uri instance', () {
      var uriStr = 'https://example.com/path?query=true#fragment';
      Uri uri = Uri.parse(uriStr);
      expect(new Fluri.fromUri(uri).toString(), equals(uriStr));
    });

    commonFluriTests(() => fluri);
  });

  group('FluriMixin', () {
    ExtendingClass extender;
    MixingClass mixer;

    setUp(() {
      extender = new ExtendingClass(url);
      mixer = new MixingClass(url);
    });

    test('should be an empty uri by default', () {
      expect(new FluriMixin().uri.toString(), equals(''));
    });

    test('should be an empty uri even if uri set to null', () {
      var fluri = new FluriMixin()..uri = null;
      expect(fluri.uri.toString(), equals(''));
    });

    commonFluriTests(() => extender);
    commonFluriTests(() => mixer);
  });
}
