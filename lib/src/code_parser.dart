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

// ignore: implementation_imports
import 'dart:io';

// ignore: implementation_imports
import 'package:surveyor/src/driver.dart';
// ignore: implementation_imports
import 'package:surveyor/src/visitors.dart';
import 'package:path/path.dart';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
// ignore: implementation_imports
import 'package:analyzer/src/generated/source.dart';

import 'model.dart';
import 'primitives.dart';

Future<Dependencies> collectDeps(String packageFolder) async {
  var collector = _DepsCollector(packageFolder);
  var driver = Driver.forArgs([packageFolder]);
  driver.forceSkipInstall = true;
  driver.showErrors = true;
  driver.resolveUnits = true;
  driver.visitor = collector;
  driver.silent = false;

  await driver.analyze(requirePackagesFile: false);
  return collector.collectedDeps;
}

/// If non-null, stops once limit is reached (for debugging).
int? _debugLimit; //500;

class _DepsCollector extends RecursiveAstVisitor
    implements PreAnalysisCallback, PostAnalysisCallback, AstContext {
  final _count = 0;
  String? _filePath;
  final String _rootPath;

  Map<String, Set<String>> collectedDeps = {};

  _DepsCollector(this._rootPath);

  @override
  void postAnalysis(SurveyorContext context, DriverCommands cmd) {
    cmd.continueAnalyzing = _debugLimit == null || _count < _debugLimit!;
  }

  @override
  void setFilePath(String filePath) {
    _filePath = filePath;
  }

  @override
  void setLineInfo(LineInfo lineInfo) {}

  String get filePath {
    final filePath = _filePath;
    if (filePath == null) throw 'File path should be set';
    return filePath;
  }

  @override
  dynamic visitImportDirective(ImportDirective node) {
    _collectDep(_toDependency(node.uri.stringValue));
    return super.visitImportDirective(node);
  }

  @override
  visitExportDirective(ExportDirective node) {
    _collectDep(_toDependency(node.uri.stringValue));
    return super.visitExportDirective(node);
  }

  _collectDep(Dependency? dependency) {
    if (dependency == null) return;

    if (!collectedDeps.containsKey(dependency.consumer)) {
      collectedDeps[dependency.consumer] = <String>{};
    }
    if (!collectedDeps.containsKey(dependency)) {
      collectedDeps[dependency.dependency] = <String>{};
    }

    collectedDeps[dependency.consumer]!.add(dependency.dependency);
  }

  @override
  void preAnalysis(
    SurveyorContext context, {
    bool? subDir,
    DriverCommands? commandCallback,
  }) {}

  /// Returns null if imported lib is outside of the package's `lib` and `bin`.
  Dependency? _toDependency(String? importValue) {
    return toDependency(
      rootPath: _rootPath,
      absoluteLibPath: _filePath,
      importPath: importValue,
      currentDir: Directory.current.absolute.path,
    );
  }
}

/// Returns null if imported lib is outside of the package's `lib` and `bin`.
Dependency? toDependency({
  required String rootPath,
  required String currentDir,
  required String? absoluteLibPath,
  required String? importPath,
}) {
  if (absoluteLibPath == null || importPath == null) return null;
}

  // _PathTest(
  //   name: 'simple',
  //   rootPath: "../platform/packages/flutter",
  //   absoluteLibPath: '/root/_/platform/packages/flutter/lib/src/consumer.dart',
  //   currentDir: "/roor/_/layerlens",
  //   importPath: 'dependency.dart',
  //   result: Dependency(
  //     consumer: 'lib/src/consumer.dart',
  //     dependency: 'lib/src/dependency.dart',
  //   ),
  // ),



// String isRelative(String? lib) {
//   if (lib == null) return false;
//   return !lib.startsWith('package:') && !lib.startsWith('dart:');
// }

// bool isIncluded(String relativePath) {
//   return relativePath.startsWith('bin/') || relativePath.startsWith('lib/');
// }


// String _toRelative(String path) {
//   var result = normalize(relative(path, from: homePath));

//   // Leading '../' should be removed, because
//   // `normalize` does not handle it.
//   var count = 0;
//   final parentDir = '..$pathSeparator';
//   while (result.startsWith(parentDir)) {
//     result = result.substring(parentDir.length);
//     count++;
//   }

//   while (count > 0) {
//     final index = result.indexOf(pathSeparator);
//     result = result.substring(index + 1);

//     count--;
//   }

//   return result;
// }
