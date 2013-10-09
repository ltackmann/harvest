// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_api;

/** Message bus for registrering and routing [Message]'s to their [MessageHandler] */
class MessageBus {
  /** Get [Stream] for [messageType] */
  Stream<Message> stream(Type messageType) => _handlerMap[messageType].stream;

  /** Get [EventSink] for [messageType] */
  EventSink<Message> sink(Type messageType) => _handlerMap[messageType].sink;
  
  /** Stream that recieves every message regardless of type */
  Stream<Message> get everyMessage => _handlerMap._everyMessageStream;
  
  /** Broadcast message */
  fire(Message message) {
    if(!_handlerMap.hasListenerFor(message.runtimeType) && message is! DeadEvent) {
      // fire dead event to notify application that no event handlers existed for the message
      message = new DeadEvent(message);
    }
    sink(message.runtimeType).add(message);
  }
  
  final _handlerMap = new _HandlerMap();
}

/** Store the [MessageHandler]'s to be fired for a specific [Type] of a [Message] */
class _HandlerMap {
  factory _HandlerMap() {
    final controller = new StreamController<Message>();
    return new _HandlerMap._internal(controller.stream.asBroadcastStream(), controller.sink);
  }
  
  _HandlerMap._internal(this._everyMessageStream, this._everyMessageSink);
  
  operator [](Type messageType) {
    return _handlers.putIfAbsent(messageType, () {
      var controller = new StreamControllerWrapper(new StreamController<Message>());
      // invoke data handlers that listens on any events
      controller.stream.listen((e) => _everyMessageSink.add(e));
      return controller;
    });
  }
  
  forEach(Function f) => _handlers.forEach(f);
  
  bool hasListenerFor(Type messageType) => _handlers.containsKey(messageType);
  
  final Stream<Message> _everyMessageStream;
  final EventSink<Message> _everyMessageSink;
  final _handlers = new Map<Type, StreamControllerWrapper>();
}

class StreamControllerWrapper {
  StreamControllerWrapper(StreamController<Message> controller)
    : stream = (controller.stream.asBroadcastStream()),
      sink = controller.sink;
  
  final Stream<Message> stream;
  final EventSink<Message> sink;
}

/** Function executed when a message is placed on the [MessageBus] */
typedef MessageHandler(Message message);

/** Message */
abstract class Message { }

