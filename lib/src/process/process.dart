// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Processes are used to model long running business processes where multiple steps (commands) needs
 * to be executed in sequence. The actual work done in the process is performed by the commands executed
 * in each step, thus a step should effectivly not contain any business logic but only dispatch commands
 * to carry out the actual work.
 * 
 * There is no central state in the process, each step is allowed to add values to a worklog (routing slip) 
 * which is passed to each step. The steps in the process can be compensating, in which case the process 
 * manager will try to roll them back in case of failure. 
 * 
 * For more information [see][http://vasters.com/clemensv/2012/09/01/Sagas.aspx]
 */
class Process {
  final _subscriptions = new List<StreamSubscription>(); 
  final List<WorkLog> _completedWork = new List<WorkLog>();
  final Queue<WorkItem> _remainingWork = new Queue<WorkItem>();
  final MessageBus _messageBus;

  Process(this._messageBus, Iterable<WorkItem> work) {
    _remainingWork.addAll(work);
  }
    
  bool get isCompleted => _remainingWork.isEmpty;
    
  bool get isInProgress => _completedWork.isNotEmpty;
    
  /** Execute the next step in the process */
  Future<bool> next() async {
    if(isCompleted) {
      throw "Work is completed";
    }
      
    // execute step 
    var currentWork = _remainingWork.removeFirst();
    var step = currentWork.step;
    WorkLog workLog = await step.doWork(currentWork, this);
    
    // work is done cancel subscriptions so following steps are not impacted by earlier event handlers 
    cancelSubscriptions();
    
    if(workLog != null) {
      _completedWork.add(workLog);
      return new Future.value(true);
    }
    return new Future.value(false);
  }
   
  /** Undo the previous step in the process */
  Future<bool> undoLast() {
    if(!isInProgress) {
      throw "No work completed";
    }
   
    var lastWork = _completedWork.removeLast();
    var step = lastWork.step;
    var result = step.compensate(lastWork, this);
    // compensation is done, so cancel subscripitons so following compensations are not effected by earlier event handlers
    cancelSubscriptions();
    
    return result;
  }
  
  /** Listen to messages of type [messageType] */
  listenTo(Type messageType, MessageHandler handler) {
    _subscriptions.add(_messageBus.stream(messageType).listen(handler) );
  }
  
  /** Publish commands */
  publish(DomainCommand command) {
    _messageBus.publish(command);
  }
  
  /** Cancel subscriptions */ 
  cancelSubscriptions() {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
  }
  
  /** Search work log */
  operator [](String key) {
    if(!isInProgress) {
      throw "No work completed";
    }
    return _completedWork.firstWhere((worklog) => worklog.containsKey(key))[key];
  }
}

/**
 * Function responsible for enriching a [Message] with extra data, such as session tokens before its fired
 */
typedef ContentEnricher(Message message);