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

import 'package:layerlens/src/layering.dart';
import 'package:layerlens/src/model.dart';
import 'package:test/test.dart';

import 'test_infra/tests.dart';

final _tests = <String, Dependencies>{
  'simple': {
    'a/b/c/d.dart': {},
    'a/b/c.dart': {},
    'a/b.dart': {},
    'a.dart': {}
  },
};

void main() {
  test('creates folder structure', () async {
    for (final name in _tests.keys) {
      final deps = _tests[name]!;
      final layering = Layering(deps);

      expect(layering.files, hasLength(deps.length));
      expect(layering.root.children, hasLength(2));
    }
  });

  test('parses dependencies', () async {
    for (final test in layeringTests) {
      final layering = Layering(test.input);
      expect(layering.nodes, hasLength(test.nodes));
      expect(layering.files, hasLength(test.files));
    }
  });
}
