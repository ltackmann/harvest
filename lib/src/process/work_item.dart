// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

class WorkItem<T extends Step> {
  final UnmodifiableMapView<String, Object> _args;
  StepCreator _stepCreator;

  WorkItem(this._stepCreator, [Map<String, Object> arguments = const {}]): _args = new UnmodifiableMapView(arguments);

  T get step => _stepCreator();
}
