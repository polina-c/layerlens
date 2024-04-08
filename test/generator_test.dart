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

import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:glob/glob.dart';
import 'package:layerlens/src/analyzer.dart';
import 'package:layerlens/src/code_parser.dart';
import 'package:layerlens/src/generator.dart';
import 'package:layerlens/src/model.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem memoryFileSystem;
  late LocalFileSystem localFileSystem;

  const rootDir = 'test/test_project';

  late File rootFile;
  late File subfolderFile1;
  late File subfolderFile2;

  setUp(() async {
    memoryFileSystem = MemoryFileSystem();
    localFileSystem = LocalFileSystem();

    rootFile = memoryFileSystem.file('$rootDir/lib/DEPENDENCIES.md');
    subfolderFile1 =
        memoryFileSystem.file('$rootDir/lib/subfolder1/DEPENDENCIES.md');
    subfolderFile2 =
        memoryFileSystem.file('$rootDir/lib/subfolder2/DEPENDENCIES.md');

    /// Copy test/test_project to MemoryFileSystem, so the files are created and tested in memory.
    await memoryFileSystem.directory(rootDir).create(recursive: true);
    await for (final file
        in localFileSystem.directory(rootDir).list(recursive: true)) {
      if (file is Directory) {
        await memoryFileSystem.directory(file.path).create(recursive: true);
      } else if (file is File) {
        final content = await (file as File).readAsBytes();
        await memoryFileSystem.file(file.path).writeAsBytes(content);
      }
    }
  });

  /// Generate files in MemoryFileSystem and return number of generated files.
  Future<int> generateFiles(MdGenerator generator) {
    return IOOverrides.runZoned(
      () async {
        final noGeneratedFiles = await generator.generateFiles();
        return noGeneratedFiles;
      },
      createFile: (path) => memoryFileSystem.file(path),
      createDirectory: (path) => memoryFileSystem.directory(path),
    );
  }

  test('generator marks inversions', () async {
    final deps = await collectDeps(rootDir: rootDir);
    final analyzer = Analyzer(deps);

    final content =
        MdGenerator.content(analyzer.root.children['lib'] as SourceFolder);
    expect(content, contains('--!-->'));
    expect(content, contains('this folder: 1'));
    expect(content, contains('sub-folders: 2'));
  });
  group('build filters', () {
    test('build all files (without any filters)', () async {
      final deps = await collectDeps(rootDir: rootDir);
      final analyzer = Analyzer(deps);

      final generator = MdGenerator(
        sourceFolder: analyzer.root,
        rootDir: rootDir,
        buildFilters: [],
      );

      final noGeneratedFiles = await generateFiles(generator);

      expect(rootFile.existsSync(), true);
      expect(noGeneratedFiles, 3);
      expect(subfolderFile1.existsSync(), true);
      expect(subfolderFile2.existsSync(), true);
    });
    test('build only root', () async {
      final deps = await collectDeps(rootDir: rootDir);
      final analyzer = Analyzer(deps);

      final generator = MdGenerator(
        sourceFolder: analyzer.root,
        rootDir: rootDir,
        buildFilters: [Glob('lib')],
      );

      final noGeneratedFiles = await generateFiles(generator);

      expect(rootFile.existsSync(), true);
      expect(noGeneratedFiles, 1);
      expect(subfolderFile1.existsSync(), false);
      expect(subfolderFile2.existsSync(), false);
    });

    test('build root and one subfolder', () async {
      final deps = await collectDeps(rootDir: rootDir);
      final analyzer = Analyzer(deps);

      final generator = MdGenerator(
        sourceFolder: analyzer.root,
        rootDir: rootDir,
        buildFilters: [Glob('lib'), Glob('lib/subfolder1')],
      );

      final noGeneratedFiles = await generateFiles(generator);

      expect(rootFile.existsSync(), true);
      expect(noGeneratedFiles, 2);
      expect(subfolderFile1.existsSync(), true);
      expect(subfolderFile2.existsSync(), false);
    });
  });
}
