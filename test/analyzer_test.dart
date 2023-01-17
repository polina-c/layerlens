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

import 'package:layerlens/src/analyzer.dart';
import 'package:test/test.dart';

import 'test_infra/tests.dart';

void main() {
  for (final t in layeringTests) {
    test('$Analyzer works for t.name', () async {
      final analyzer = Analyzer(t.input);
      expect(analyzer.files, hasLength(t.input.length), reason: t.name);
      expect(analyzer.nodes, hasLength(t.nodes), reason: t.name);
      expect(
        analyzer.root.children,
        hasLength(t.rootChildren),
        reason: t.name,
      );
    });
  }
}
