// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
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
  final Map<String, Object> _arguments;

  Process(this._messageBus, Iterable<WorkItem> work, this._arguments) {
    work.forEach((workItem) {
      _remainingWork.add(workItem);
      _arguments.addAll(workItem._args);
    });
  }

  bool get isCompleted => _remainingWork.isEmpty;

  bool get isInProgress => _completedWork.isNotEmpty;

  /** */
  /**
   * Execute the next step in the process, returns **true** if the step was successfully executed
   */
  Future<bool> next() async {
    if(isCompleted) {
      throw "Work is completed";
    }

    // execute step
    var currentWork = _remainingWork.removeFirst();
    var step = currentWork.step;
    try {
      WorkLog workLog = await step.doWork(currentWork, this);
      _completedWork.add(workLog);
      _arguments.addAll(workLog._loggedWork);
      return new Future.value(true);
    } catch(e) {
      return new Future.value(false);
    } finally {
      // work is done cancel subscriptions so following steps are not impacted by earlier event handlers
      cancelSubscriptions();
    }
  }

  /**
   * Undo the previous step in the process, returns **true** if the step was successfully undone
   */
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

  /** Subscribe to messages of type [messageType] */
  subscribe(Type messageType, MessageHandler handler) {
    _subscriptions.add(_messageBus.subscribe(messageType, handler));
  }

  /** Publish commands */
  Future<int> publish(DomainCommand command) {
    return _messageBus.publish(command);
  }

  /** Cancel subscriptions */
  cancelSubscriptions() {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
  }

  /** Search work log */
  operator [](String key) {
    if(!_arguments.containsKey(key)) {
      throw new ArgumentError("no value for key $key");
    }
    return _arguments[key];
  }

  /** Get description of completed work */
  String get completedWork {
    String s = "{";
    _completedWork.forEach((WorkLog workLog) {
      s += "${workLog.workName}:${workLog.loggedWork}";
      if(!identical(_completedWork.last, workLog)) {
        s += ",";
      }
    });
    s += "}";
    return s;
  }
}

/**
 * Function responsible for enriching a [Message] with extra data, such as session tokens before its fired
 */
typedef ContentEnricher(Message message);
