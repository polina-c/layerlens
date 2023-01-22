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

Future<void> generateLayering({
  required String packageFolder,
  required String? packageName,
}) async {
  final deps = await collectDeps(
    packageFolder: packageFolder,
    packageName: packageName,
  );
  final layering = Analyzer(deps);
  await MdGenerator(folder: layering.root).generateFiles();
}
