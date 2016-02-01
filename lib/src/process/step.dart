// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * A step in a business process (see [Process]) responsible carrying out a atomic piece
 * of work. Steps have the responsibility of
 *
 *
 * The actual business logic should not be placed here, instead steps should
 * fire commands recieved by [AggregateRoot]s where the actual business logic is placed
 *
 *
 * to carry out its work as well as providing possible compensatin actions if the
 * step fails.
 *
 * Note steps are created each time they are needed in a [Process] and thus cannot safely
 * retain any state.
 */
abstract class Step {
  /**
   * Execute and log the work in the step
   */
  Future<WorkLog> doWork(WorkItem item, Process process);

  /**
   * Implement a compensating step to be executed in case future steps in the process fails
   * and we have to roll back the work done by each of the prior step
   */
  Future<bool> compensate(WorkLog log, Process process);

  /**
   *  Create log of the work done
   */
  Future<WorkLog> logWork(String message, {Map<String, Object> workLog:const {}}) async {
    logger.debug(message);
    return new WorkLog(this, loggedWork:workLog);
  }

  /**
   * Advice process that compensation of this step was successful
   */
  Future<bool> compensationSucceded([String message = null]) async {
    if(message == null) {
      message = "sucessfully compensated step ${this.runtimeType.toString()}";
    }
    logger.debug(message);
    return true;
  }

  /**
   * Advice process that compensation of this step failed
   */
  Future<bool> compensationFailed([String message = null]) async {
    if(message == null) {
      message = "failed compensating step ${this.runtimeType.toString()}";
    }
    logger.warn(message);
    return false;
  }

  Logger get logger => LoggerFactory.getLoggerFor(this.runtimeType);
}

/**
 * Used by [Process] to creating [Step]'s each time they are needed to perform work or compensate
 */
typedef Step StepCreator();
