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

import 'dart:math';

import 'model.dart';

// `wl` in this file means 'without layer'

/// Recursively assigns layers.
void assignLayers(SourceFolder folder) {
  _assignLocalLayerToChildren(folder);
  folder.orderChildrenByLayer();

  for (final child in folder.children.values) {
    if (child is SourceFolder) {
      assignLayers(child);
    }
  }
}

// TODO(polina-c): convert to record.
class _NodesAndValue {
  final Set<SourceNode> nodes;
  final int value;

  _NodesAndValue(this.nodes, this.value);
}

void _assignLocalLayerToChildren(SourceFolder folder) {
  // Items without layer.
  final wl = folder.children.values.toSet();
  int layer = 1;

  while (wl.isNotEmpty) {
    final withMinConsumersWl = _withMinConsumersWl(wl);
    final nextSet = _withMaxDependenciesWl(withMinConsumersWl.nodes).nodes;

    assert(nextSet.isNotEmpty);

    if (withMinConsumersWl.value > 0) {
      // If there are cycles, layer alphabetically.
      final sorted = nextSet.toList()
        ..sort((a, b) => a.shortName.compareTo(b.shortName));

      for (final node in sorted) {
        node.layer = layer;
        wl.remove(node);
        layer++;
      }
    } else {
      // Assign the same number to all.
      for (final node in nextSet) {
        node.layer = layer;
        wl.remove(node);
      }
      layer++;
    }

    // Safety check for infinite loop:
    if (layer > 10000) throw 'The loop seems to be infinite';
  }
}

/// This method is very similar to [_withMaxDependenciesWl].
///
/// It is possible to generalize them into one.
_NodesAndValue _withMinConsumersWl(Set<SourceNode> nodes) {
  final byNumberOfConsumersWl = <int, Set<SourceNode>>{};

  for (final node in nodes) {
    assert(node.layer == null);
    int numOfConsumersWl = 0;

    for (final consumer in node.siblingConsumers) {
      if (consumer.layer == null) {
        numOfConsumersWl += 1;
      }
    }

    byNumberOfConsumersWl.putIfAbsent(numOfConsumersWl, () => {}).add(node);
  }

  final minNumber = byNumberOfConsumersWl.keys.reduce((v, e) => min(v, e));

  return _NodesAndValue(
    byNumberOfConsumersWl[minNumber]!,
    minNumber,
  );
}

_NodesAndValue _withMaxDependenciesWl(Set<SourceNode> nodes) {
  final byNumberOfDependenciesWl = <int, Set<SourceNode>>{};

  for (final node in nodes) {
    assert(node.layer == null);
    int numOfDependenciesWl = 0;

    for (final dependency in node.siblingDependencies) {
      if (dependency.layer == null) {
        numOfDependenciesWl += 1;
      }
    }

    byNumberOfDependenciesWl
        .putIfAbsent(numOfDependenciesWl, () => {})
        .add(node);
  }

  final maxNumber = byNumberOfDependenciesWl.keys.reduce((v, e) => max(v, e));

  return _NodesAndValue(
    byNumberOfDependenciesWl[maxNumber]!,
    maxNumber,
  );
}
