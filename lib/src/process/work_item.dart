// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

class WorkItem<T extends Step> {
  final UnmodifiableMapView<String, Object> _args;  
  StepCreator _stepCreator;
  
  WorkItem(this._stepCreator, [Map<String, Object> arguments = const {}]): _args = new UnmodifiableMapView(arguments);
  
  T get step => _stepCreator();
  
  /**
   * True if work item contains argument [arg]
   */
  bool containsArgument(String arg) => _args.containsKey(arg);
  
  /**
   * Look up value for argument [arg], throws exception if not present
   */
  Object getArgument(String arg) {
    if(!containsArgument(arg)) {
      throw new ArgumentError("no work item entry for $arg in step ${runtimeType}");
    }
    return _args[arg];
  }
  
  /**
   * Look up value for argument [arg], returns [defaultValue] if not present
   */
  Object getArgumentOrDefault(String arg, Object defaultValue) {
    if(!containsArgument(arg)) {
      return defaultValue;
    }
    return _args[arg];
  }
}

