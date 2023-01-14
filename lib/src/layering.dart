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

import 'model.dart';

const String _rootName = '.';

class Layering {
  Layering(Dependencies dependencies) : files = _depsToFiles(dependencies) {
    root = _root(files);
  }

  final Map<FullName, SourceFile> files;
  late final SourceFolder root;
}

SourceFolder _root(Map<FullName, SourceFile> files) {
  final result = SourceFolder([_rootName], {});

  for (final fullName in files.keys) {
    final file = files[fullName]!;
    _propogateFileToFolder(result, file, file.path, 0);
  }

  return result;
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
    () => SourceFolder(subFolderPath, {}),
  ) as SourceFolder;

  _propogateFileToFolder(subFolder, file, path, pathIndex + 1);
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
