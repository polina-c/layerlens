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

import 'package:layerlens/layerlens.dart';
import 'package:layerlens/src/analyzer.dart';
import 'package:layerlens/src/code_parser.dart';
import 'package:layerlens/src/generator.dart';
import 'package:layerlens/src/model.dart';
import 'package:test/test.dart';

void main() async {
  int? exitCodeUsed;
  void exitMock(int code) {
    exitCodeUsed = code;
  }

  final cycledLayering = {
    true: await collectDeps(rootDir: 'example'),
    false: await collectDeps(rootDir: '.'),
  };

  setUp(() {
    exitCodeUsed = null;
  });

  for (final failOnCycles in [true, false]) {
    for (final cycles in [true, false]) {
      test(
          'handleCycles exits for cycles with flag, cycles=$cycles, failOnCycles=$failOnCycles',
          () async {
        final layering = Analyzer(cycledLayering[cycles]!);
        handleCycles(
          layering,
          exitMock,
          failOnCycles: failOnCycles,
          failureMessage: 'Cycles found',
        );

        bool shouldExit = failOnCycles && cycles;
        if (shouldExit) {
          expect(exitCodeUsed, 1);
        } else {
          expect(exitCodeUsed, null);
        }
      });
    }
  }
}
