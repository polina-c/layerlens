// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/source/line_info.dart';

import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as path;

class DriverCommands {
  bool continueAnalyzing = true;
}

// Under `flutter test`, `Platform.resolvedExecutable` is `flutter_tester` and
// analyzer's SDK auto-detection fails. Resolve the real dart-sdk so tests
// work under both `dart test` and `flutter test`.
String? _findDartSdk() {
  final flutterRoot = io.Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final dartSdk = path.join(flutterRoot, 'bin', 'cache', 'dart-sdk');
    if (io.File(path.join(dartSdk, 'version')).existsSync()) return dartSdk;
  }
  final candidate = path.dirname(path.dirname(io.Platform.resolvedExecutable));
  if (io.File(path.join(candidate, 'version')).existsSync()) return candidate;
  return null;
}

class Driver {
  final List<String> sources;
  AstVisitor? visitor;
  bool resolveUnits = true;
  bool silent = false;

  Driver._(this.sources);

  factory Driver.forArgs(List<String> args) {
    return Driver._(
      args.map((p) => path.normalize(io.File(p).absolute.path)).toList(),
    );
  }

  Future<void> analyze() async {
    if (sources.isEmpty) return;

    final cmd = DriverCommands();
    final resourceProvider = PhysicalResourceProvider.INSTANCE;

    for (final root in sources) {
      if (!cmd.continueAnalyzing) break;

      final collection = AnalysisContextCollection(
        includedPaths: [root],
        resourceProvider: resourceProvider,
        sdkPath: _findDartSdk(),
      );

      for (final context in collection.contexts) {
        final v = visitor;
        if (v == null) continue;
        final surveyorContext = SurveyorContext(context);

        if (v case PreAnalysisCallback pre) {
          pre.preAnalysis(surveyorContext);
        }

        for (final filePath in context.contextRoot.analyzedFiles()) {
          if (!filePath.endsWith('.dart')) continue;
          try {
            final result = resolveUnits
                ? await context.currentSession.getResolvedUnit(filePath)
                    as ResolvedUnitResult
                : context.currentSession.getParsedUnit(filePath)
                    as ParsedUnitResult;

            if (v case AstContext ctx) {
              ctx.setLineInfo(result.lineInfo);
              ctx.setFilePath(filePath);
            }
            result.unit.accept(v);
          } catch (e) {
            if (!silent) {
              io.stderr.writeln('Exception analyzing $filePath: $e');
            }
          }
        }

        if (v case PostAnalysisCallback post) {
          post.postAnalysis(surveyorContext, cmd);
        }
      }
    }
  }
}

class SurveyorContext {
  final AnalysisContext analysisContext;
  SurveyorContext(this.analysisContext);
}

abstract class AstContext {
  void setFilePath(String filePath);
  void setLineInfo(LineInfo lineInfo);
}

abstract class PreAnalysisCallback {
  void preAnalysis(
    SurveyorContext context, {
    bool? subDir,
    DriverCommands? commandCallback,
  });
}

abstract class PostAnalysisCallback {
  void postAnalysis(SurveyorContext context, DriverCommands commandCallback);
}
