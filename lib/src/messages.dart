// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Base class for events  
 */
abstract class Message { }

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
  
  onSuccess(CommandCompleter onSuccess) => _successHandler = onSuccess; 
      
  CommandCompleter _successHandler;
}

typedef CommandCompleter();

/**
 * The dead event is fired when a message is placed on the eventbus without any event listners associated with it.
 *
 * This is useful for ensuring the application works as expected. 
 */
class DeadEvent extends Message {
  DeadEvent(this.deadMessage);
  
  final Message deadMessage;
}

/**
 * Domain events are produced by the domain when an action is completed. Domain events are usually 
 * named in the past tense and can be persisted in a event store and replaied later to set the 
 * domain in any state
 *
 * Since these events are persisted its best they be constructed from primitive serializable types
 */
class DomainEvent extends Message {
  int version;
}

