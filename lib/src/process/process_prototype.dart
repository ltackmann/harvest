// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Reusable description of a process that can be run repeatedly
 */
class ProcessPrototype {
  final List<WorkItem> steps;

  ProcessPrototype(this.steps);
}
