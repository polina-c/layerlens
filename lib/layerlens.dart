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

import 'dart:io';

import 'package:glob/glob.dart';
import 'package:meta/meta.dart';

import 'src/analyzer.dart';
import 'src/code_parser.dart';
import 'src/generator.dart';
import 'src/cli.dart';

/// Generates dependency diagram in each source folder
/// where there are dependencies between dart libraries or folders.
///
/// Returns number of generated diagrams.
Future<int> generateLayering({
  required String rootDir,
  required String? packageName,
  required bool failOnCycles,
  required bool failIfChanged,
  required List<Glob> buildFilters,
  ExitCallback exitFn = exit,
}) async {
  final deps = await collectDeps(
    rootDir: rootDir,
    packageName: packageName,
  );
  final layering = Analyzer(deps);
  handleCycles(
    layering,
    exitFn,
    failOnCycles: failOnCycles,
  );
  return await MdGenerator(
    sourceFolder: layering.root,
    rootDir: rootDir,
    buildFilters: buildFilters,
    failIfChanged: failIfChanged,
  ).generateFiles();
}

@visibleForTesting
void handleCycles(
  Analyzer layering,
  ExitCallback exitFn, {
  required bool failOnCycles,
}) {
  if (layering.root.totalInversions > 0 && failOnCycles) {
    failExecution(FailureCodes.cycles, exitFn: exitFn);
  }
}
