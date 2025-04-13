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
  buildFilter('build-filter'),
  help('help'),
  failOnCycles('fail-on-cycles'),
  failIfChanged('fail-if-changed'),
  ;

  const CliOptions(this.name);

  final String name;
}

final _failureMessages = {
  FailureCodes.cycles: '''Error: cycles detected.
To see the cycles, regenerate the diagrams and search for '--!--'.
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

Future<void> deleteFile(String path, bool failIfExists) async {
  final file = File(path);
  bool exists = await file.exists();
  if (!exists) return;
  if (failIfExists) {
    failExecution(FailureCodes.diagramsOutdated);
  }
  await file.delete();
}

Future<void> writeFile(
  String path,
  String content,
  bool failIfDifferent,
) async {}

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
  ExitCallback exitFn = exit,
}) {
  print(
    _failureMessages[code] ?? 'Error: unknown error. Code: ${code.value}',
  );
  print('Read more at https://pub.dev/packages/layerlens.');
  exitFn(code.value);
}
