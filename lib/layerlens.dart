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

import 'src/generator.dart';
import 'src/analyzer.dart';

import 'src/code_parser.dart';

/// Generates dependency diagram in eash source folder
/// where dart libraries or folders depend on eash other.
///
/// Returns number of generated diagrams.
Future<int> generateLayering({
  required String rootDir,
  required String? packageName,
}) async {
  final deps = await collectDeps(
    rootDir: rootDir,
    packageName: packageName,
  );
  final layering = Analyzer(deps);
  return await MdGenerator(sourceFolder: layering.root, rootDir: rootDir)
      .generateFiles();
}
