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

// ignore: implementation_imports
import 'package:surveyor/src/driver.dart';
// ignore: implementation_imports
import 'package:surveyor/src/visitors.dart';
import 'package:path/path.dart' as p;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
// ignore: implementation_imports
import 'package:analyzer/src/generated/source.dart';

import 'model.dart';
import 'primitives.dart';

Future<Dependencies> collectDeps({
  required String rootDir,
  String? packageName,
}) async {
  var collector = _DepsCollector(
    packageName: packageName,
    rootDir: rootDir,
  );
  var driver = Driver.forArgs([rootDir]);
  driver.forceSkipInstall = true;
  driver.showErrors = true;
  driver.resolveUnits = true;
  driver.visitor = collector;
  driver.silent = true;

  await driver.analyze(requirePackagesFile: false);
  return collector.collectedDeps;
}

/// If non-null, stops once limit is reached (for debugging).
const _limit = 100000;

class _DepsCollector extends RecursiveAstVisitor
    implements PreAnalysisCallback, PostAnalysisCallback, AstContext {
  final _count = 0;
  String? _filePath;
  final String _absoluteRootPath;
  final String? packagePrefix;

  Map<String, Set<String>> collectedDeps = {};

  _DepsCollector({required String rootDir, required packageName})
      : _absoluteRootPath = p.absolute(rootDir),
        packagePrefix = packageName == null ? null : 'package:$packageName/';

  @override
  void postAnalysis(SurveyorContext context, DriverCommands cmd) {
    if (_count > _limit) throw 'too many items';
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
    if (!collectedDeps.containsKey(dependency.dependency)) {
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
      absoluteRootPath: _absoluteRootPath,
      absoluteLibPath: _filePath,
      importPath: importValue,
      packagePrefix: packagePrefix,
    );
  }
}

/// Returns null if the import is outside of the package `lib` or `bin`.
Dependency? toDependency({
  required String absoluteRootPath,
  required String? absoluteLibPath,
  required String? importPath,
  required String? packagePrefix,
}) {
  if (absoluteLibPath == null || importPath == null) return null;
  if (importPath.startsWith('dart:')) return null;

  // Check if import statement references library
  // with `package:...` in the same package.
  final toSelfWithPackage =
      packagePrefix != null && importPath.startsWith(packagePrefix);

  if (importPath.startsWith('package:') && !toSelfWithPackage) return null;

  final consumer = _toRelative(absoluteRootPath, absoluteLibPath);
  if (!_isInLibOrBin(consumer)) return null;

  final absoluteLibDir = p.dirname(absoluteLibPath);

  final String dependencyAbsolute;
  if (toSelfWithPackage) {
    final fromLib = importPath.substring(packagePrefix.length);
    dependencyAbsolute = p.join(absoluteRootPath, 'lib', fromLib);
  } else {
    dependencyAbsolute = p.join(absoluteRootPath, absoluteLibDir, importPath);
  }

  final dependency = _toRelative(absoluteRootPath, dependencyAbsolute);
  if (!_isInLibOrBin(dependency)) return null;

  return Dependency(dependency: dependency, consumer: consumer);
}

bool _isInLibOrBin(String lib) =>
    lib.startsWith('bin/') || lib.startsWith('lib/');

String _toRelative(String home, String path) {
  var result = p.normalize(p.relative(path, from: home));

  // Leading '../' should be removed, because
  // `normalize` does not handle it.
  var count = 0;
  final parentDir = '..$pathSeparator';
  while (result.startsWith(parentDir)) {
    result = result.substring(parentDir.length);
    count++;
  }

  while (count > 0) {
    final index = result.indexOf(pathSeparator);
    result = result.substring(index + 1);

    count--;
  }

  return result;
}
