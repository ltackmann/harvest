// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Create and manage life cycle of long running processes
 */
class ProcessManager {
  static final Logger _logger = LoggerFactory.getLoggerFor(ProcessManager);
  
  final MessageBus _messageBus;
  
  ProcessManager(this._messageBus); 
  
  /** 
   * Start [Process] and executes its steps in order, on failure try to compensate the executed steps
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
      _logger.warn("process failed ${process.completedWork}");
      return undoProcess(process);
    } 
    _logger.debug("process succeded with work: ${process.completedWork}");
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
  
  ProcessPrototype createProcessPrototype(List<WorkItem> steps) => new ProcessPrototype(steps);
  
  Process createProcess(ProcessPrototype prototype, Map<String,Object> arguments) {
    var process = new Process(_messageBus, prototype.steps, arguments);
    return process;
  }
}

/** Create processes running on [messageBus] */
typedef Process ProcessCreator(MessageBus messageBus); 