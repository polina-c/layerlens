//  Copyright 2023 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import 'package:layerlens/src/code_parser.dart';
import 'package:layerlens/src/model.dart';
import 'package:test/test.dart';

void main() {
  group('collect deps for', () {
    test('example', () async {
      final deps = await collectDeps('example');
      expect(deps, hasLength(2));
    });

    test('self', () async {
      final deps = await collectDeps('.');
      expect(deps.length, greaterThan(5));
    });
  });

  for (final t in _pathTests) {
    test('toDependency, ${t.name}', () {
      final result = toDependency(
        absoluteRootPath: t.absoluteRootPath,
        absoluteLibPath: t.absoluteLibPath,
        importPath: t.importPath,
      );

      expect(result, equals(t.result));
    });
  }
}

class _PathTest {
  final String name;

  final String absoluteRootPath;
  final String absoluteLibPath;
  final String? importPath;

  final Dependency? result;

  _PathTest({
    required this.name,
    required this.absoluteRootPath,
    required this.absoluteLibPath,
    required this.importPath,
    required this.result,
  });
}

final _pathTests = [
  _PathTest(
    name: 'local',
    absoluteRootPath: "/root/flutter",
    absoluteLibPath: '/root/flutter/lib/src/consumer.dart',
    importPath: 'dependency.dart',
    result: Dependency(
      consumer: 'lib/src/consumer.dart',
      dependency: 'lib/src/dependency.dart',
    ),
  ),
  _PathTest(
    name: 'package:',
    absoluteRootPath: "/x/y",
    absoluteLibPath: '/x/y/z/consumer.dart',
    importPath: 'package:dependency/dependency.dart',
    result: null,
  ),
  _PathTest(
    name: 'dart:',
    absoluteRootPath: "/x/y",
    absoluteLibPath: '/x/y/z/consumer.dart',
    importPath: 'dart:dependency/dependency.dart',
    result: null,
  ),
  _PathTest(
    name: 'subdir',
    absoluteRootPath: "/x/y",
    absoluteLibPath: '/x/y/lib/consumer.dart',
    importPath: 'a/b/dependency.dart',
    result: Dependency(
      consumer: 'lib/consumer.dart',
      dependency: 'lib/a/b/dependency.dart',
    ),
  ),
  _PathTest(
    name: 'parent',
    absoluteRootPath: "/x/y",
    absoluteLibPath: '/x/y/lib/src/a/b/consumer.dart',
    importPath: '../../dependency.dart',
    result: Dependency(
      consumer: 'lib/src/a/b/consumer.dart',
      dependency: 'lib/src/dependency.dart',
    ),
  ),
];
