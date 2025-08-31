//  Copyright 2025 Google LLC
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

enum CliOptions {
  path('path'),
  package('package'),
  usage('usage'),
  only('only'),
  except('except'),
  help('help'),
  failOnCycles('fail-on-cycles'),
  failIfChanged('fail-if-changed'),
  ;

  const CliOptions(this.name);

  final String name;
}

final _failureMessages = {
  FailureCodes.cycles: '''Error: cycles detected.

To see the cycles, do one of the following:

* Copy the diagram above and paste it somewhere, where the diagram can be previewed, for example, to a comment on a GitHub PR.
* Regenerate the diagrams by running `layerlens` in the project root and search for '--!--'

The tool failed because the CLI option --${CliOptions.failOnCycles.name} is set.
''',
  FailureCodes.diagramsOutdated: '''Error: diagrams are outdated.
To fix, regenerate the diagrams.
The tool failed because the CLI option --${CliOptions.failIfChanged.name} is set.
''',
};

/// Function to call to exit the tool.
///
/// Needed to mock [exit] in tests.
typedef ExitCallback = Function(int code);

String pathSeparator = Platform.pathSeparator;

Future<void> deleteDiagramFile({
  required String path,
  required bool failIfExists,
}) async {
  final file = File(path);
  bool exists = await file.exists();
  if (!exists) return;
  if (failIfExists) {
    print('The diagram $path should be deleted.');
    failExecution(FailureCodes.diagramsOutdated);
    return;
  }
  await file.delete();
}

Future<void> updateDiagramFile(
  String path,
  String content,
  bool failIfDifferent,
) async {
  final file = File(path);
  if (!(await file.exists()) && failIfDifferent) {
    failExecution(FailureCodes.diagramsOutdated);
    return;
  }
  if (failIfDifferent) {
    final existingContent = await file.readAsString();
    if (existingContent != content) {
      print('The diagram $path should be regenerated.');
      failExecution(FailureCodes.diagramsOutdated);
      return;
    }
  }
  await file.writeAsString(content);
}

enum FailureCodes {
  /// Cycles found.
  cycles(1),

  /// Diagrams are outdated.
  diagramsOutdated(2),
  ;

  const FailureCodes(this.value);

  final int value;
}

/// Fails execution of the tool with message.
void failExecution(
  FailureCodes code, {
  ExitCallback? exitFn,
}) {
  print(
    _failureMessages[code] ?? 'Error: unknown error. Code: ${code.value}',
  );
  print('Read more at https://pub.dev/packages/layerlens.');
  exitFn ??= exit;
  exitFn(code.value);
}
