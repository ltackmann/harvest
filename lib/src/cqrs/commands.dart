// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_cqrs;

/**
 * Application commands are not part of the CQRS event chain (and are thus not handled by ordinary command handlers). 
 * They serve the same purpose within the application as ordinary commands (to signal that something should be done).
 *
 * A typical usage scenario would be a command that tells the user interface to change it self. This is typically not
 * something that is part of the domain and should thus not be handled by it.
 *
 * Since these events are not persisted they are allowed to hold access to complicated objects such as view models
 */
class ApplicationCommand extends Message { }

/**
 * Commands represents a serialized method call and are created by the application. Commands are usually 
 * written in the imperative tense and cannot be persisted as they can have possible side effects
 *
 * Since commands are not persisted they can contain arbitraly complex types 
 */
class DomainCommand extends Message {
  completeSuccess() {
    if(_successHandler != null) {
      _successHandler();
    }
    _commandCompleter.complete();
  }
  
  /** Register function to be executed when command has been handled by all command handlers */
  DomainCommand onSuccess(CommandSuccessHandler successHandler) {
    _successHandler = successHandler;
    return this;
  }
  
  /** Execute this command on [messageBus] */
  Future broadcastOn(MessageBus messageBus) {
    messageBus.fire(this);
    return _commandCompleter.future;
  }
      
  final _commandCompleter = new Completer();
  final Map<String, Object> headers = <String, Object>{};
  CommandSuccessHandler _successHandler;
}

typedef void CommandSuccessHandler(); 

