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
import 'package:glob/glob.dart';
import 'package:layerlens/layerlens.dart';
import 'package:layerlens/src/cli.dart';
import 'package:layerlens/src/model.dart';

const _filterDocLink =
    'https://github.com/polina-c/layerlens/blob/main/README.md#filter';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      CliOptions.usage.name,
      defaultsTo: false,
      help:
          'Prints help on how to use the command. The same as --${CliOptions.usage.name}.',
    )
    ..addFlag(
      CliOptions.help.name,
      defaultsTo: false,
      help:
          'Prints help on how to use the command. The same as --${CliOptions.help.name}.',
    )
    ..addFlag(
      CliOptions.failOnCycles.name,
      defaultsTo: false,
      help: 'Fail if there are circular dependencies.',
    )
    ..addFlag(
      CliOptions.failIfChanged.name,
      defaultsTo: false,
      help: 'Fails if existing diagrams are different.',
    )
    ..addOption(
      CliOptions.path.name,
      defaultsTo: '.',
      help: 'Root directory of the package.',
    )
    ..addOption(
      CliOptions.package.name,
      defaultsTo: null,
      help: 'Package name, that is needed when internal '
          'libraries reference each other with `package:` import.',
    )
    ..addMultiOption(
      CliOptions.only.name,
      help: 'Which folders to generate diagrams for. Use glob syntax. '
          'If empty, all folders are included.'
          '\n$_filterDocLink',
    )
    ..addMultiOption(
      CliOptions.except.name,
      help: 'Which folders to exclude from diagram generation. Use glob syntax.'
          '\n$_filterDocLink',
    );

  late final ArgResults parsedArgs;

  try {
    parsedArgs = parser.parse(args);
  } on FormatException catch (e) {
    print(e.message);
    print(parser.usage);
    return;
  }

  if (parsedArgs[CliOptions.usage.name] == true ||
      parsedArgs[CliOptions.help.name] == true) {
    print(parser.usage);
    return;
  }

  List<Glob> parseFilters(CliOptions optionName) {
    final arg = parsedArgs[optionName.name] as List<String>? ?? [];
    return arg.map((filter) => Glob(filter)).toList();
  }

  Filter filter() {
    return Filter(
      only: parseFilters(CliOptions.only),
      except: parseFilters(CliOptions.except),
    );
  }

  final generatedDiagrams = await generateLayering(
    rootDir: parsedArgs[CliOptions.path.name],
    packageName: parsedArgs[CliOptions.package.name],
    failOnCycles: parsedArgs[CliOptions.failOnCycles.name] as bool,
    failIfChanged: parsedArgs[CliOptions.failIfChanged.name] as bool,
    filter: filter(),
  );
  print(
    'Generated $generatedDiagrams diagrams. Check files DEPS.md in source folders.',
  );
}
