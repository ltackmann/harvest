// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Commands represents a serialized method call and are created by the application. Commands are usually 
 * written in the imperative tense and cannot be persisted as they can have possible side effects
 *
 * Since commands are not persisted they can contain arbitraly complex types 
 */
class Command extends Message {
  Command(String type): super(type);

  completeSuccess() {
    if(_successHandler != null) {
      _successHandler();
    }
  }
  
  onSuccess(CommandCompleter onSuccess) => _successHandler = onSuccess; 
      
  CommandCompleter _successHandler;
}

typedef CommandCompleter();
