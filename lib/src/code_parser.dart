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

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:path/path.dart';
import 'package:surveyor/src/driver.dart';
import 'package:surveyor/src/visitors.dart';

import 'model.dart';

Future<Dependencies> collectDeps(String packageFolder) async {
  var collector = _DepsCollector(packageFolder);
  var driver = Driver.forArgs([packageFolder]);
  driver.forceSkipInstall = true;
  driver.showErrors = false;
  driver.resolveUnits = true;
  driver.visitor = collector;
  driver.silent = true;

  await driver.analyze();
  return collector.collectedDeps;
}

/// If non-null, stops once limit is reached (for debugging).
int? _debugLimit; //500;

class _DepsCollector extends RecursiveAstVisitor
    implements PreAnalysisCallback, PostAnalysisCallback, AstContext {
  int _count = 0;
  String? _filePath;
  final String homePath;

  Map<String, Set<String>> collectedDeps = {};

  _DepsCollector(this.homePath);

  @override
  void postAnalysis(SurveyorContext context, DriverCommands cmd) {
    cmd.continueAnalyzing = _debugLimit == null || _count < _debugLimit!;
  }

  @override
  void setFilePath(String filePath) {
    this._filePath = filePath;
  }

  @override
  void setLineInfo(LineInfo lineInfo) {}

  static Source source(NamespaceDirective node) {
    final selectedSource = node.selectedSource;
    if (selectedSource == null) throw 'selectedSource should not be null';
    return selectedSource;
  }

  String get filePath {
    final filePath = _filePath;
    if (filePath == null) throw 'File path should be set';
    return filePath;
  }

  @override
  dynamic visitImportDirective(ImportDirective node) {
    _collectDep(filePath, source(node).fullName);
    return super.visitImportDirective(node);
  }

  @override
  visitExportDirective(ExportDirective node) {
    _collectDep(filePath, source(node).fullName);
    return super.visitExportDirective(node);
  }

  _collectDep(String dependentAbsolutePath, String dependencyAbsolutePath) {
    String? dependent = _toRelative(dependentAbsolutePath);
    String? dependency = _toRelative(dependencyAbsolutePath);
    if (!isIncluded(dependency) || !isIncluded(dependent)) return;

    if (!collectedDeps.containsKey(dependent))
      collectedDeps[dependent] = Set<String>();
    if (!collectedDeps.containsKey(dependency))
      collectedDeps[dependency] = Set<String>();

    collectedDeps[dependent]!.add(dependency);
  }

  String _toRelative(String path) {
    return relative(path, from: homePath);
  }

  bool isIncluded(String relativePath) {
    return relativePath.startsWith('bin/') || relativePath.startsWith('lib/');
  }

  @override
  void preAnalysis(SurveyorContext context,
      {bool? subDir, DriverCommands? commandCallback}) {}
}
