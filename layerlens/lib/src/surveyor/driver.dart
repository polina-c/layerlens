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

import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as path;

import 'visitors.dart';

class DriverCommands {
  bool continueAnalyzing = true;
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
