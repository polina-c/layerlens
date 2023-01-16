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
import 'model.dart';

class MdGenerator {
  final SourceFolder folder;

  MdGenerator({
    required this.folder,
  });

  Future<void> generateFiles() async {
    await _generateFile(folder);
  }

  /// Recursively generates md files in source folders.
  Future<void> _generateFile(SourceFolder folder) async {
    final file =
        File('${folder.fullName}${Platform.pathSeparator}DEPENDENCIES.md');

    if (await file.exists()) {
      await file.delete();
    }

    // Diagram is generated if there are at least two children.
    if (folder.children.length > 1) {
      file.writeAsStringSync(_content(folder));
    }

    for (final node in folder.children.values) {
      if (node is SourceFolder) await _generateFile(node);
    }
  }

  String _content(SourceFolder folder) {
    final result = StringBuffer();

    result.writeln('<!---');
    result.writeln('Generated by https://github.com/polina-c/layerlens');
    result.writeln('-->');
    result.writeln('');
    result.writeln('```mermaid');
    result.writeln('flowchart TD;');
    for (final consumer in folder.children.values) {
      for (final dep in consumer.siblingDependencies) {
        result.writeln('${consumer.shortName}-->${dep.shortName};');
      }
    }
    result.writeln('```');
    result.writeln('');

    return result.toString();
  }
}
