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
  ;

  const _Options(this.name);

  final String name;
}

void main(List<String> args) async {
  final parsedArgs =
      (ArgParser()..addOption(_Options.path.name, defaultsTo: '.')).parse(args);
  await generateLayering(parsedArgs[_Options.path.name]);
}
