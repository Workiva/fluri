library fluri.test.fluri_test;

import 'package:fluri/fluri.dart';
import 'package:test/test.dart';

void commonFluriTests(dynamic getFluri()) {
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

  test('should allow setting the path via a list of path segments', () {
    getFluri().pathSegments = ['new', 'path'];
    expect(getFluri().pathSegments, equals(['new', 'path']));
  });

  test('should allow setting the query', () {
    getFluri().query = 'limit=5&format=text';
    expect(getFluri().query, equals('limit=5&format=text'));
  });

  test('should allow setting the query via a map of query parameters', () {
    getFluri().queryParameters = {'limit': '5', 'format': 'text'};
    expect(getFluri().query, equals('limit=5&format=text'));
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

class ExtendingClass extends FluriMixin {
  ExtendingClass(String uri) {
    this.uri = Uri.parse(uri);
  }
}

class MixingClass extends Object with FluriMixin {
  MixingClass(String uri) {
    this.uri = Uri.parse(uri);
  }
}

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

    commonFluriTests(() => fluri);
  });

  group('FluriMixin', () {
    ExtendingClass extender = new ExtendingClass(url);
    MixingClass mixer = new MixingClass(url);

    test('should be an empty uri by default', () {
      expect(new FluriMixin().uri.toString(), equals(''));
    });

    commonFluriTests(() => extender);
    commonFluriTests(() => mixer);
  });
}
