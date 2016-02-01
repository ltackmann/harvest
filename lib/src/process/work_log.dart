// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Log of the work executed by a step
 */
class WorkLog<T extends Step> {
  final UnmodifiableMapView<String, Object> _loggedWork;
  T step;

  WorkLog(this.step, {Map<String, Object> loggedWork:const {}}): _loggedWork = new UnmodifiableMapView(loggedWork);

  /**
   * True if worklog contains values for [key]
   */
  bool containsKey(String key) => _loggedWork.containsKey(key);

  /**
   * Look up entry in work log
   */
  Object operator [](String key) {
    if(!containsKey(key)) {
      throw new ArgumentError("no log entry for $key in step ${step.runtimeType}");
    }
    return _loggedWork[key];
  }

  String get loggedWork => _loggedWork.toString();

  String get workName => step.runtimeType.toString();
}
