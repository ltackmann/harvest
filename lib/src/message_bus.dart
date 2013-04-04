// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Message bus for registrering and routing [Message]'s to their [MessageHandler] */
class MessageBus {
  MessageBus() {
    print("create bus");
  }
  
  /** Get [Stream] for [eventType] */
  Stream<Message> stream(Type messageType) => _handlerMap[messageType].stream;

  /** Get [EventSink] for [eventType] */
  EventSink<Message> sink(Type messgeType) => _handlerMap[messgeType].sink;
  
  /** Stream that recieves every message regardless of type */
  Stream<Message> get everyMessage => _handlerMap._messageController.stream;
  
  /** Broadcast message */
  fire(Message message) => sink(message.runtimeType).add(message);
  
  fire2(Message message) {
    if(_handlerMap.noHandlersFor(message.runtimeType) && message is! DeadEvent) {
      // TODO use a stream transformer to change event instead
      // fire dead event to notify application that no event handlers existed for the message
      message = new DeadEvent(message);
    }
    _handlerMap.forEach((Type messageType, List<MessageHandler> messageHandlers){
      if(message.runtimeType == messageType) {
        messageHandlers.forEach((MessageHandler messageHandler) => messageHandler(message));
      }
    });
  }
  
 
  final HandlerMap _handlerMap = new HandlerMap();
}

/** Store the [MessageHandler]'s to be fired for a specific [Type] of a [Message] */
class HandlerMap {
  operator [](Type messageType) {
    return _handlers.putIfAbsent(messageType, (){
      var controller = new StreamController<Message>.broadcast();
      // invoke data handlers that listens on any events
      controller.stream.listen((e) => _messageController.sink.add(e));
      return controller;
    });
  }
  
  forEach(Function f) => _handlers.forEach(f);
  
  bool noHandlersFor(Type messageType) => this[messageType].isEmpty;
  
  final Map<Type, StreamController<Message>> _handlers = new Map<Type, StreamController<Message>>();
  final _messageController = new StreamController<Message>.broadcast();
}

/** Function executed when a message is placed on the [MessageBus] */
typedef MessageHandler(Message message);


