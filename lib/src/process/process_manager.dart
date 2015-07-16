// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Create and manage life cycle of long running processes
 */
class ProcessManager {
  final MessageBus _messageBus;
  
  ProcessManager(this._messageBus); 
  
  /**
   * Create a new process that executes each step in order
   */
  Process createProcess(List<WorkItem> steps) {
    var process = new Process(_messageBus, steps);
    return process;
  }
  
  /** 
   * Start [process] and executes its steps in order, on failure try to compensate the executed steps
   */
  Future<bool> startProcess(Process process) async {
    if(process.isInProgress) {
      throw new StateError("Process already started");
    }
    bool succeded = false;
    while(!process.isCompleted) {
      succeded = await process.next();
      if(!succeded) {
        break;
      }
    }
    if(!succeded) {
      return undoProcess(process);
    } 
    return new Future.value(succeded);
  }
  
  /**
   * Undo the steps in [process]
   */
  Future<bool> undoProcess(Process process) async {
    if(process.isCompleted) {
      throw new StateError("Process already completed sucessfully");
    }
    bool succeded = false;
    while(!process.isInProgress) {
      succeded = await process.undoLast();
      if(!succeded) {
        throw new StateError("unable to undo work");
      }
    }
    return new Future.value(succeded);
  }
}

/** Create processes running on [messageBus] */
typedef Process ProcessCreator(MessageBus messageBus); 