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
    test('toDependency produces correct output, ${t.name}', () {
      final result = toDependency(
        rootPath: t.rootPath,
        currentDir: t.currentDir,
        absoluteLibPath: t.absoluteLibPath,
        importPath: t.importPath,
      );

      expect(result, equals(t.result));
    });
  }
}

class _PathTest {
  final String name;

  final String rootPath;
  final String absoluteLibPath;
  final String? importPath;
  final String currentDir;

  final Dependency? result;

  _PathTest({
    required this.name,
    required this.rootPath,
    required this.absoluteLibPath,
    required this.importPath,
    required this.currentDir,
    required this.result,
  });
}

final _pathTests = [
  _PathTest(
    name: 'simple',
    rootPath: "../platform/packages/flutter",
    absoluteLibPath: '/root/_/platform/packages/flutter/lib/src/consumer.dart',
    currentDir: "/roor/_/layerlens",
    importPath: 'dependency.dart',
    result: Dependency(
      consumer: 'lib/src/consumer.dart',
      dependency: 'lib/src/dependency.dart',
    ),
  ),
];
