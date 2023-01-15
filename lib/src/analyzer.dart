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

import 'package:layerlens/src/layering.dart';

import 'model.dart';
import 'primitives.dart';

const String _rootName = '.';

class Analyzer {
  Analyzer(Dependencies dependencies) : files = _depsToFiles(dependencies) {
    _createRoot();
    _setSiblingDependencies();
    assignLayers(root);
  }

  final Map<FullName, SourceFile> files;
  final nodes = <FullName, SourceNode>{};

  /// Children are ordered by layer.
  late final SourceFolder root;

  void _createRoot() {
    root = SourceFolder([_rootName], {});

    for (final fullName in files.keys) {
      final file = files[fullName]!;
      nodes[file.fullName] = file;
      _propogateFileToFolder(root, file, file.path, 0);
    }
  }

  /// Recursively adds file, and folders for the file path, to the
  /// source tree.
  _propogateFileToFolder(
    SourceFolder folder,
    SourceFile file,
    List<String> path,
    pathIndex,
  ) {
    assert(pathIndex < path.length);
    final isLast = pathIndex == path.length - 1;

    if (isLast) {
      assert(file.shortName == path[pathIndex]);
      assert(!folder.children.containsKey(file.shortName));
      folder.children[file.shortName] = file;
      return;
    }

    final subFolderPath = path.getRange(0, pathIndex + 1).toList();
    final subFolderName = subFolderPath.last;

    final SourceFolder subFolder = folder.children.putIfAbsent(
      subFolderName,
      () => _createFolder(subFolderPath),
    ) as SourceFolder;

    _propogateFileToFolder(subFolder, file, path, pathIndex + 1);
  }

  SourceFolder _createFolder(Path path) {
    final result = SourceFolder(path, {});
    nodes[result.fullName] = result;
    return result;
  }

  /// Detects dependencies between members of one folder.
  void _setSiblingDependencies() {
    for (final consumer in files.values) {
      for (final dependency in consumer.dependencies) {
        final siblingIndex = _findSiblingIndex(consumer.path, dependency.path);
        final consumerSibling =
            nodes[_pathFragment(consumer.path, siblingIndex)]!;
        final dependencySibling =
            nodes[_pathFragment(dependency.path, siblingIndex)]!;

        consumerSibling.siblingDependencies.add(dependencySibling);
        dependencySibling.siblingConsumers.add(consumerSibling);
      }
    }
  }
}

Map<FullName, SourceFile> _depsToFiles(Dependencies dependencies) {
  final result = <FullName, SourceFile>{};
  for (final consumerName in dependencies.keys) {
    result.putIfAbsent(consumerName, () => SourceFile(consumerName));

    for (final dependencyName in dependencies[consumerName]!) {
      result.putIfAbsent(dependencyName, () => SourceFile(dependencyName));

      final consumer = result[consumerName]!;
      final dependency = result[dependencyName]!;

      consumer.dependencies.add(dependency);
    }
  }
  return result;
}

/// Finds first index where paths are not equal, i.e. the nodes are siblings to each other.
int _findSiblingIndex(Path consumer, Path dependency) {
  var index = 0;

  while (consumer[index] == dependency[index]) {
    index++;
  }

  return index;
}

/// Fragment of path from beginning to the index, including it.
FullName _pathFragment(Path path, int toIndex) {
  final result = path.getRange(0, toIndex + 1);
  return result.join(pathSeparator);
}
