// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Message bus for registrering and routing [Message]'s to their [MessageHandler] */
class MessageBus {
  MessageCoordinator _coordinator;
  
  /**
   * Message bus that delivers messages syncronously
   */
  MessageBus(): 
    _coordinator = new MessageCoordinator(isSync:true);
  
  /**
   * Message bus that delivers messages asyncronously
   */
  MessageBus.async(): 
    _coordinator = new MessageCoordinator(isSync:false);
  
  /**
   * Set [MessageHandler] to be invoked if event is published with no active listeners 
    */
  set deadEventHandler(MessageHandler handler) => _coordinator.deadEventHandler = handler;
  
  /**
   * Set [enricher] to enrich [Message] before they are fired
   */
  set enricher(MessageEnricher enricher) => _coordinator.enricher = enricher;
  
  /**
   * Stream that recieves every message regardless of type
   */
  Stream<Message> get everyMessage => stream(null);
  
  /**
   * Publish message
   */
  Future<int> publish(Message message) {
    return _publishInternal(message);
  }
  
  Future<int> _publishInternal(Message message) async {
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
  unsubscribe(Type messageType) => _coordinator.closeSubscriptionsForMessageType(messageType);
  
  /**
   * Unsubscribe message bus from all message type
   */
  unsubscribeAll() {
    _coordinator._subscribers.clear();
    _coordinator._messageCompleters.clear();
    _coordinator._handlers.clear();
    final bool sync = _coordinator.isSync;
    _coordinator = null;
    _coordinator = new MessageCoordinator(isSync:sync);
  }
  
  /**
   * Get [EventSink] for [messageType]
   */
  EventSink<Message> sink(Type messageType) => _coordinator[messageType].sink;
  
  /**
   * Get a message [Stream] for [messageType]. 
   * 
   * A Stream is a source of messages with subscribed listeners that recieves the added messages
   */
  Stream<Message> stream(Type messageType) => _coordinator[messageType].stream;
}

/**
 * Coordinate delivery of messages to listeners so we can notify completers of their delivery
 */
class MessageCoordinator {
  final Map<Type, MessageStreamController> _handlers = <Type, MessageStreamController>{};
  // true if underlying stream is syncronous
  final bool isSync;
  // number of subscribers
  final Map<Type, List<MessageStreamSubscription>> _subscribers = <Type, List<MessageStreamSubscription>>{};
  // completers to notify when all subscribers have recived message
  final Map<Guid, Completer> _messageCompleters = <Guid, Completer> {};
  // enricher to enhance message when comming through
  MessageEnricher _enricher;
  // handler to recieve dead events
  MessageHandler deadEventHandler = (Message message) => print("no message handler registered for message type ${message.runtimeType}");
  
  /**
   * If [isSync] is true then the underlying messages stream are will block until delivered.
   */
  MessageCoordinator({this.isSync});
  
  /**
   * Get a [MessageStreamController] for [messageType]
   */
  MessageStreamController operator [](Type messageType) {
    return _handlers.putIfAbsent(messageType, () => new MessageStreamController(this, messageType));
  }
   
  /**
   * Add a subscription for messages of type [messageType]
   */
  MessageStreamSubscription listen(Type messageType, StreamController<Message> controller, void onData(Message message)) {
    var subscription = controller.stream.listen((Message message) {
      // called each time message is put on the [MessageStreamSink] belonging to this [MessageStream]
      onData(message);
      _notifyDelivery(message);
    });
    var messageSubscribers = _subscribers.putIfAbsent(messageType, () => new List<MessageStreamSubscription>());
    var wrapped = new MessageStreamSubscription(subscription, this, controller.sink, messageType);
    messageSubscribers.add(wrapped);
    return wrapped;
  }
  
  /**
   * Close message sink and any subsriptions
   */
  closeSink(MessageStreamSink sink) {
    var messageSubscribers = _subscribers[sink.messageType];
    var messageSubscription = messageSubscribers.firstWhere((ms) => identical(ms.messageSink, sink));
    if(messageSubscription != null) {
      closeSubscription(messageSubscription);
    }
  }
  
  /**
   * Close subscription
   */
  closeSubscription(MessageStreamSubscription subscriber) {
     var messageSubscribers = _subscribers[subscriber.messageType];
     messageSubscribers.remove(subscriber);
     if(messageSubscribers.isEmpty) {
       _subscribers.remove(subscriber.messageType);
       _handlers.remove(subscriber.messageType);
     }
   }
  
  /**
   * Close subscriptions for message type 
   */
  closeSubscriptionsForMessageType(Type messageType) {
    var messageSubscribers = _subscribers[messageType];  
    for(int i=0; i<messageSubscribers.length; i++) {
      closeSubscription(messageSubscribers[i]);
    }
  }
  
  Completer deliver(Message message) {
    if(_enricher != null) {
      _enricher(message);
    }
    final completer = _registerMessage(message);
    final subscribers = _getSubscribers(message.runtimeType);
    if(subscribers.isNotEmpty) {
      subscribers.forEach((s) => s.add(message));
    } else {
      if(deadEventHandler != null) {
        deadEventHandler(message);
      }
      _complete(message, 0);
    }
    return completer;
  }
  
  set enricher(MessageEnricher enricher) => _enricher = enricher;
  
  _complete(Message message, int deliveredTo) {
    Guid messageId = _getMessageId(message);
    var completer = _messageCompleters[messageId];
    // notify completer of delivery
    completer.complete(deliveredTo);
    // cleanup
    _messageCompleters.remove(messageId);
  }
  
  StreamSink<Message> _getDeliverySink(Type messageType) {
    StreamSink<Message> targetSink = null;
    if(_subscribers.containsKey(messageType)) {
      // only return one sink for each message type as sinks are shared between identical types 
      targetSink = _subscribers[messageType].firstWhere((ms) => !ms.isPaused, orElse:() => null).messageSink;
    }
    return targetSink;
  }
  
  Guid _getMessageId(Message message) => message.headers["messageId"] as Guid;
  
  Iterable<StreamSink<Message>> _getSubscribers(Type messageType) {
    var messageSubscribers = new List<StreamSink<Message>>();
    // message type subscribers
    var messageTypeTarget = _getDeliverySink(messageType);
    if(messageTypeTarget != null) {
      messageSubscribers.add(messageTypeTarget);
    }
    // every message type subscribers
    var everyMessageTypeTarget = _getDeliverySink(null);
    if(everyMessageTypeTarget != null) {
      messageSubscribers.add(everyMessageTypeTarget);
    }
    return messageSubscribers;
  }
  
  _notifyDelivery(Message message) {
     int deliveredTo = (message.headers["deliveredTo"] as int) + 1;
     message.headers["deliveredTo"] = deliveredTo;
     if(deliveredTo >= _numberOfSubscribers(message)) {
       _complete(message, deliveredTo);
     }
   }
  
  int _numberOfSubscribers(Message message) {
    int numSub = 0;
    // message type subscribers
    if(_subscribers.containsKey(message.runtimeType)) {
       numSub += _subscribersFor(message.runtimeType);
    }
    // every message type subscribers
    if(_subscribers.containsKey(null)) {
      numSub += _subscribersFor(null);
    }
    return numSub;
  }
  
  int _subscribersFor(Type messageType) {
    return _subscribers[messageType].where((ms) => !ms.isPaused).toList().length;
  }
  
  Completer _registerMessage(Message message) {
    Guid messageId = _getMessageId(message);
    if(messageId == null) {
      messageId = new Guid();
      message.headers["messageId"] = messageId;
      message.headers["deliveredTo"] = 0;
      var completer = new Completer();
      _messageCompleters[messageId] = completer;
    } 
    return _messageCompleters[messageId];
  }
}

/**
 * Stream that notifies [MessageStreamSubscription] when new subscriptions are added for messages of type [messageType]
 */
class MessageStream extends Stream<Message> {
  final MessageCoordinator _coordinator;
  final StreamController<Message> _wrapped;
  final Type messageType;
  
  MessageStream(this._wrapped, this._coordinator, this.messageType);
  
  StreamSubscription<Message> listen(void onData(Message event),
                               { Function onError,
                                 void onDone(),
                                 bool cancelOnError}) {
   
    return _coordinator.listen(messageType, _wrapped, onData);
  }
}

/**
 * Wrapper for creating and accessing the [Sink] and [Stream]s used to handle messages of type [messageType]
 */
class MessageStreamController {
  final MessageStreamSink _sink;
  final MessageStream _stream;
  final MessageCoordinator _coordinator;
  final Type messageType;

  factory MessageStreamController(MessageCoordinator coordinator, Type messageType) 
  {
    var wrappedController = new StreamController<Message>.broadcast(sync:coordinator.isSync);
   
    var messageSink = new MessageStreamSink(wrappedController, coordinator, messageType);
    var messageStream = new MessageStream(wrappedController, coordinator, messageType);
    return new MessageStreamController._internal(messageSink, messageStream, coordinator, messageType);
  }
  
  MessageStreamController._internal(this._sink, this._stream, this._coordinator, this.messageType);
  
  EventSink<Message> get sink => _sink;
  
  Stream<Message> get stream => _stream;
  
  close() => sink.close();
}

/**
 * Sink that notifies [MessageCoordinator] when messages of type [messageType] are dispatched
 */
class MessageStreamSink implements EventSink<Message> {
  final MessageCoordinator _coordinator;
  final StreamController<Message> _wrapped;
  final Type messageType;
  
  MessageStreamSink(this._wrapped, this._coordinator, this.messageType);
  
  @override
  Completer add(Message message) {
    return _coordinator.deliver(message);
  }
  
  @override
  void addError(error, [StackTrace stackTrace]) {
    _wrapped.addError(error, stackTrace);
  }

  @override
  close() { 
    _coordinator.closeSink(this);
  } 
}

class MessageStreamSubscription implements StreamSubscription<Message> {
  final StreamSubscription<Message> _wrapped;
  final MessageCoordinator _coordinator;
  final StreamSink<Message> messageSink;
  final Type messageType;
 
  MessageStreamSubscription(this._wrapped, this._coordinator, this.messageSink, this.messageType);
  
  @override
  Future cancel() {
    _coordinator.closeSubscription(this); 
    return _wrapped.cancel();
  }

  @override
  void onData(void handleData(Message data)) => _wrapped.onData(handleData);

  @override
  void onError(Function handleError) => _wrapped.onError(handleError);

  @override
  void onDone(void handleDone()) => _wrapped.onDone(handleDone);

  @override
  void pause([Future resumeSignal]) => _wrapped.pause(resumeSignal);

  @override
  void resume() => _wrapped.resume();

  @override
  bool get isPaused => _wrapped.isPaused;

  @override
  Future asFuture([var futureValue]) => _wrapped.asFuture(futureValue);
}

