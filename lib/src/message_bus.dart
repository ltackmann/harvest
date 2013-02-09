// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Message bus for registrering and routing [Message]'s to their [MessageHandler]
 */
class MessageBus {
  static MessageBus _instance;
  
  factory MessageBus() {
    if(_instance == null) {
      _instance = new MessageBus._internal();
    }
    return _instance;
  }
  
  MessageBus._internal()
    : _handlerMap = new HandlerMap(),
      _catchAllHandlers = new List<MessageHandler>();
  
  /**
   * Get handler map to assign handlers for specific events
   */ 
  HandlerMap get on => _handlerMap;
  
  /**
   * Add a handler that will recieve all events
   */ 
  List<MessageHandler> get onAny => _catchAllHandlers;
  
  fire(Message message) {
    print(message.runtimeType.toString());
    if(_handlerMap.noHandlersFor(message.runtimeType) && message is! DeadEvent) {
      // fire dead event to notify application that no event handlers existed for the message
      message = new DeadEvent(message);
    }
    _catchAllHandlers.forEach((MessageHandler messageHandler) => messageHandler(message));
    _handlerMap.forEach((Type messageType, List<MessageHandler> messageHandlers){
      if(message.runtimeType == messageType) {
        messageHandlers.forEach((MessageHandler messageHandler) => messageHandler(message));
      }
    });
  }
  
  final List<MessageHandler> _catchAllHandlers;
  final HandlerMap _handlerMap;
}

/**
 * Store the [MessageHandler]'s to be fired for a specific [Type] of a [Message]
 */
class HandlerMap {
  HandlerMap(): _handlers = new Map<Type, List<MessageHandler>>();
  
  operator [](Type messageType) {
    return _handlers.putIfAbsent(messageType, () => new List<MessageHandler>()); 
  }
  
  forEach(Function f) {
    return _handlers.forEach(f);
  }
  
  bool noHandlersFor(Type messageType) => this[messageType].length == 0;
  
  final Map<Type, List<MessageHandler>> _handlers;
}

/**
 * Function executed when a message is placed on the [MessageBus]
 */
typedef MessageHandler(Message message);


