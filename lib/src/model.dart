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

import 'package:layerlens/src/primitives.dart';

typedef ShortName = String;
typedef FullName = String;
typedef Dependencies = Map<FullName, Set<FullName>>;
typedef Path = List<String>;
typedef Layer = int;

abstract class SourceNode {
  final Path path;
  late ShortName shortName;
  final FullName fullName;

  final siblingDependencies = <SourceNode>{};
  final siblingConsumers = <SourceNode>{};

  Layer? layer;

  SourceNode(this.path)
      : shortName = path.last,
        fullName = path.join(pathSeparator);

  SourceNode.parse(this.fullName)
      : path = fullName
            .split(pathSeparator)
            .where((e) => e.trim().isNotEmpty)
            .toList() {
    shortName = path.last;
  }
}

class SourceFolder extends SourceNode {
  SourceFolder(super.path, this.children);

  Map<ShortName, SourceNode> children;

  void orderChildrenByLayer() {
    final entries = children.entries.toList()
      ..sort((a, b) => a.value.layer!.compareTo(b.value.layer!));
    children = Map.fromEntries(entries);
  }
}

class SourceFile extends SourceNode {
  SourceFile(FullName fullName) : super.parse(fullName);

  final Set<SourceFile> dependencies = {};
}
