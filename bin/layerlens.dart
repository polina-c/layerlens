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

import 'package:args/args.dart';
import 'package:layerlens/layerlens.dart';

enum _Options {
  path('path'),
  package('package'),
  usage('usage'),
  failOnCycles('fail-on-cycles'),
  ;

  const _Options(this.name);

  final String name;
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      _Options.usage.name,
      defaultsTo: false,
      help: 'Prints usage.',
    )
    ..addFlag(
      _Options.failOnCycles.name,
      defaultsTo: false,
      help: 'Fail if there are circular dependencies.',
    )
    ..addOption(
      _Options.path.name,
      defaultsTo: '.',
      help: 'Root directory of the package.',
    )
    ..addOption(
      _Options.package.name,
      defaultsTo: null,
      help: 'Package name, that is needed when internal '
          'libraries reference each other with `package:` import.',
    );

  late final ArgResults parsedArgs;

  try {
    parsedArgs = parser.parse(args);
  } on FormatException catch (e) {
    print(e.message);
    print(parser.usage);
    return;
  }

  if (parsedArgs[_Options.usage.name] == true) {
    print(parser.usage);
    return;
  }

  final generatedDiagrams = await generateLayering(
    rootDir: parsedArgs[_Options.path.name],
    packageName: parsedArgs[_Options.package.name],
    failOnCycles: parsedArgs[_Options.failOnCycles.name] as bool,
    cyclesFailureMessage: '''Error: cycles detected.
To see the cycles, generate diagrams without --${_Options.failOnCycles.name} and search for '--!--'.
''',
  );
  print(
    'Generated $generatedDiagrams diagrams. Check files DEPENDENCIES.md in source folders.',
  );
}
