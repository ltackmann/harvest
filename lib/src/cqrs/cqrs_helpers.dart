// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store_cqrs;

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
 * Application events are not part of the CQRS event chain (and thus not persisted). They serve the same purpose
 * within the application as ordinary events (to signal that something has happend).
 *
 * A typical usage scenario would be a event that signal widgets that something has happend elsewhere on the screen. This 
 * type of information is typically not persisted and should therefor not be handled by ordinary event handlers.
 *
 * Since these events are not persisted they are allowed to hold access to complicated objects such as view models
 */
class ApplicationEvent extends Message { }

/**
 * Commands represents a serialized method call and are created by the application. Commands are usually 
 * written in the imperative tense and cannot be persisted as they can have possible side effects
 *
 * Since commands are not persisted they can contain arbitraly complex types 
 */
class Command extends Message {
  completeSuccess() {
    if(_successHandler != null) {
      _successHandler();
    }
  }
  
  /**
   * Helper function that fires command on [messageBus] and executes [onSuccess] when its done
   * 
   * TODO use named argument for onSuccess
   */
  Future fireAsync(MessageBus messageBus, var onSuccess) {
    var completer = new Completer();
    _successHandler = () {
      onSuccess();
      completer.complete();
    };
    messageBus.fire(this);
    return completer.future;
  }
      
  CommandCompleter _successHandler;
}

typedef CommandCompleter();
