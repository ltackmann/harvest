// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Message bus for registrering and routing [Message]'s to their [MessageHandler] */
class MessageBus {
  /*
   * TODO refac so we only have one coordinator
   * 
   * - when a stream is listened to by type a type entry is added in coordinator and internal subscriber number is bumped in stream
   * - when every stream is listened to only internal subscriber number is bumped
   * - when message is added on type sink a completer is created with message id and the sum of every stream and type stream is counted as total
   * delivery targets by message id
   * 
   * Case: only type stream has listener
   * 
   * Case: only every stream has listener
   * 
   * Case: Both type and every stream has listener
   * 
   * Case: Both neither type and every stream has listener
   */
  _HandlerMap _handlerMap;
  MessageEnricher _enricher;
  
  /**
   * Create a message bus that delivers messages syncronously
   */
  MessageBus(): 
    _handlerMap = new _HandlerMap(sync:true);
  
  /**
   * Create a message bus that delivers messages asyncronously
   */
  MessageBus.async(): 
    _handlerMap = new _HandlerMap(sync:false);
  
  /** The enricher [enricher] to enrich [Message] before they are fired  */
  set enricher(MessageEnricher enricher) => _enricher = enricher;
  
  /** Stream that recieves every message regardless of type */
  Stream<Message> get everyMessage => _handlerMap.everyMessageController.stream;
  
  /** Broadcast message */
  Future<int> fire(Message message) {
    // TODO rename to publish
    if(!_handlerMap.hasListenerFor(message.runtimeType)) {
      // fire dead event to notify application that no event handlers existed for the message
      return _publishInternal(new DeadEvent(message));
    }
    return _publishInternal(message);
  }
  
  Future<int> _publishInternal(Message message) async {
    // TODO move enricher to coordinator
    if(_enricher != null) {
      _enricher(message);
    }
    var messageSink = sink(message.runtimeType) as MessageStreamSink;
    var messageCompleter = messageSink.add(message);
    int deliveredTo = await messageCompleter.future;
    return deliveredTo;
  }
  
  /**
   * Subscribe to [messageType]
   */
  StreamSubscription<Message> subscribe(Type messageType, MessageHandler handler) {
    var messageStream = stream(messageType);
    var subscription = messageStream.listen(handler);
    return subscription;
  }
  
  /**
   * Unsubscribe from [messageType]
   */
  unsubscribe(Type messageType) => _handlerMap.unsubscribe(messageType);
  
  /**
   * Unsubscribe message bus from all message type
   */
  unsubscribeAll() {
    _handlerMap.forEach((type, ctrl) => _handlerMap.unsubscribe(type));
    _handlerMap._handlers.clear();
    _handlerMap.everyMessageController.close();
    final bool isSync = _handlerMap.isSync;
    _handlerMap = new _HandlerMap(sync:isSync);
  }
  
  /**
   * Get [EventSink] for [messageType]
   */
  EventSink<Message> sink(Type messageType) => _handlerMap[messageType].sink;
  
  /**
   * Get a message [Stream] for [messageType]. 
   * 
   * A Stream is a source of messages with subscribed listeners that recieves the added messages
   */
  Stream<Message> stream(Type messageType) => _handlerMap[messageType].stream;
}

/**
 * Store the [MessageHandler]'s to be fired for a specific [Type] of a [Message]
 */
class _HandlerMap {
  final Map<Type, MessageStreamController> _handlers = <Type, MessageStreamController>{};
  final MessageStreamController everyMessageController;
  final bool isSync;
  
  /**
   * If [sync] is true then the underlying messages stream are will block until delivered.
   */
  _HandlerMap({bool sync}): everyMessageController = new MessageStreamController(sync), isSync = sync;

  MessageStreamController operator [](Type messageType) {
    return _handlers.putIfAbsent(messageType, () => new MessageStreamController(isSync, everyMessageController));
  }
  
  unsubscribe(Type messageType) {
    _handlers[messageType].close();
    _handlers[messageType] = null;
  }
  
  forEach(void f(Type type, MessageStreamController controller)) => _handlers.forEach(f);
  
  bool hasListenerFor(Type messageType) => _handlers.containsKey(messageType);
}

/**
 * Wrapper for creating and accessing the [Sink] and [Stream]s used to handle messages, 
 */
class MessageStreamController {
  final MessageStreamSink _sink;
  final MessageStream _stream;
  final MessageStreamCoordinator _coordinator;

  factory MessageStreamController(bool isSync, [MessageStreamController everyMessageController = null]) 
  {
    var coordinator = new MessageStreamCoordinator();
    var controller = new StreamController<Message>.broadcast(sync:isSync);
   
    var messageSink = new MessageStreamSink(controller.sink, coordinator, everyMessageController);
    var messageStream = new MessageStream(controller.stream, coordinator);
    return new MessageStreamController._internal(messageSink, messageStream, coordinator);
  }
  
  MessageStreamController._internal(this._sink, this._stream, this._coordinator);
  
  EventSink<Message> get sink => _sink;
  
  Stream<Message> get stream => _stream;
  
  close() => sink.close();
}

/**
 * Sink that notifies [MessageStreamCoordinator] when messages are dispatched
 */
class MessageStreamSink implements EventSink<Message> {
  final MessageStreamController everyMessageController;
  final MessageStreamCoordinator _coordinator;
  EventSink<Message> _wrapped;
  
  MessageStreamSink(this._wrapped, this._coordinator, this.everyMessageController);
  
  @override
  Completer add(Message message) {
    final bool hasSubscribers = _coordinator.hasSubscribers; 
    Completer completer;
    if(hasSubscribers) {
      // only deliver message if we have any subscribers
      completer = _coordinator.registerMessage(message);
      _wrapped.add(message);  
    } 
    if(everyMessageController != null) {
      // avoid unending recusion when deliver to every sink 
      var everySink = everyMessageController.sink as MessageStreamSink;
      if(completer == null) {
        completer = everySink.add(message);  
      } else {
        everySink.add(message);  
      }
    }
    if(completer == null) {
      // neither us nor the every message stream has any subscribers
      completer = new Completer();
      completer.complete(0);
    }
    return completer;
  }
  
  @override
  void addError(error, [StackTrace stackTrace]) {
    _wrapped.addError(error, stackTrace);
  }

  @override
  close() { 
    _wrapped.close(); 
    _coordinator.close();
  } 
}

/**
 * Stream that notifies [MessageStreamSubscription] when new subscriptions are added
 */
class MessageStream extends Stream<Message> {
  final MessageStreamCoordinator _coordinator;
  final Stream<Message> _wrapped;
  
  MessageStream(this._wrapped, this._coordinator);
  
  StreamSubscription<Message> listen(void onData(Message event),
                               { Function onError,
                                 void onDone(),
                                 bool cancelOnError}) {
    
    var subscription = _wrapped.listen((Message message) {
      onData(message);
      _coordinator.notifyDelivery(message);
    });
    _coordinator.addSubscriber(subscription);
    return subscription;
  }
}

/**
 * Coordinate delivery of messages so we can notify completers of their delivery
 */
class MessageStreamCoordinator {
  // number of subscribers
  final List<StreamSubscription<Message>> _subscribers = <StreamSubscription<Message>>[];
  // completers to notify when all subscribers have recived message
  final Map<Guid, Completer> _messageCompleters = <Guid, Completer> {};
  
  Completer addCompleter(Guid messageId) {
    var completer = new Completer();
    _messageCompleters[messageId] = completer;
    return completer;
  }
  
  addSubscriber(StreamSubscription<Message> subscriber)  {
    _subscribers.add(subscriber);  
  }
  
  close() {
    print("closing coordinator");
    _subscribers.forEach((s) => s.cancel());
    _subscribers.clear();
    _messageCompleters.clear();
  }
  
  Completer getCompleter(Guid messageId) {
    return _messageCompleters[messageId];
  }
  
  Guid getMessageId(Message message) => message.headers["messageId"] as Guid;
  
  bool get hasSubscribers => _subscribers.isNotEmpty;
  
  notifyDelivery(Message message) {
    int deliveredTo = (message.headers["deliveredTo"] as int) + 1;
    message.headers["deliveredTo"] = deliveredTo;
    if(deliveredTo == numberOfSubscribers) {
      complete(message, deliveredTo);
    }
  }
  
  complete(Message message, int deliveredTo) {
    Guid messageId = getMessageId(message);
    var completer = getCompleter(messageId);
    // notify completer of delivery
    completer.complete(deliveredTo);
    // cleanup
    removeCompleter(messageId);
  }
  
  int get numberOfSubscribers => _subscribers.length;
  
  Completer registerMessage(Message message) {
    Guid messageId = getMessageId(message);
    if(messageId == null) {
      messageId = new Guid();
      message.headers["messageId"] = messageId;
      message.headers["deliveredTo"] = 0;
    } 
    return addCompleter(messageId);  
  }
  
  removeCompleter(Guid messageId) {
    _messageCompleters.remove(messageId);
  }
  
  removeSubscriber(StreamSubscription<Message> subscriber) {
    _subscribers.remove(subscriber);
  }
}


