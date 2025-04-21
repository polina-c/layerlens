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

import 'cli.dart';

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

bool isInversion(SourceNode consumer, SourceNode dependency) =>
    consumer.layer! > dependency.layer!;

class SourceFolder extends SourceNode {
  SourceFolder(super.path, this.children);

  Map<ShortName, SourceNode> children;
  late int localInversions;
  late int totalInversions;

  void orderChildrenByLayer() {
    final entries = children.entries.toList()
      ..sort((a, b) => a.value.layer!.compareTo(b.value.layer!));
    children = Map.fromEntries(entries);
  }

  void calculateLocalInversions() {
    var result = 0;
    for (final consumer in children.values) {
      result += consumer.siblingDependencies
          .where((dependency) => isInversion(consumer, dependency))
          .length;
    }
    localInversions = result;
  }
}

class SourceFile extends SourceNode {
  SourceFile(FullName fullName) : super.parse(fullName);

  final Set<SourceFile> dependencies = {};
}

class Dependency {
  Dependency({
    required this.dependency,
    required this.consumer,
  });

  final String dependency;
  final String consumer;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Dependency &&
        other.dependency == dependency &&
        other.consumer == consumer;
  }

  @override
  int get hashCode => Object.hash(dependency, consumer);

  @override
  String toString() => '$consumer -> $dependency';
}
