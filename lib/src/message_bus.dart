// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
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
  set deadMessageHandler(MessageHandler handler) => _coordinator.deadMessageHandler = handler;

  /**
   * Set [enricher] to enrich [Message] before they are fired
   */
  set enricher(MessageEnricher enricher) => _coordinator.enricher = enricher;

  /**
   * Stream that recieves every message regardless of type
   */
  Stream<Message> get everyMessage => stream(null);

  /**
   * Publish messages on the message bus. Completes with future that contains the number of subscribers that
   * have recieved the event. Note if the message uses the [CallbackCompleted] mixin then the future contains
   * data returned by the message handlers complete function.
   *
   * Subscriber error handling may impact the number of delivery targets returned as cancelOnError will cause delivery
   * to cease on the first error.
   */
  Future<Object> publish(Message message) async {
    var messageSink = sink(message.runtimeType) as MessageStreamSink;
    var messageCompleter = messageSink.add(message);
    var result = await messageCompleter.future;
    return result;
  }

  /**
   * Subscribe to [messageType].
   *
   * [errorHandler] is invoked with any exception thrown by a failed subscriber function. If [cancelOnError] is true then delivery
   * stops after a subscribers fails.
   */
  StreamSubscription<Message> subscribe(Type messageType, MessageHandler handler, {MessageErrorHandler errorHandler, bool cancelOnError:false}) {
    var messageStream = stream(messageType);
    var subscription = messageStream.listen(handler, onError:errorHandler, cancelOnError:cancelOnError);
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
  MessageHandler deadMessageHandler = (Message message) => print("no message handler registered for message type ${message.runtimeType}");

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
   *
   * [onError] is invoked with any exception thrown by a failed subscriber function. If [cancelOnError] is true then delivery
   * stops when a subscriber fails.
   */
  MessageStreamSubscription listen(Type messageType,
                                   StreamController<Message> controller,
                                   void onData(Message message), MessageErrorHandler onError, bool cancelOnError) {
    StreamSubscription<Message> subscription;
    subscription = controller.stream.listen((Message message) {
      // check if subscription is still active before each delivery to satiesfy cancelOnError
      if(_isMessageDeliverable(message)) {
        // called each time message is put on the [MessageStreamSink] belonging to this [MessageStream]
        var errorOccurred = false;
        cancelOnError = (cancelOnError == null) ? false : cancelOnError;
        try{
          onData(message);
        } catch(e) {
          errorOccurred = true;
          (message.headers["messageFailures"] as List).add(e);
          if(onError != null) {
            onError(e);
          }
        }
        if(errorOccurred && cancelOnError) {
          _notifyError(message);
        } else {
          _notifyDelivery(message);
        }
      }
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

  /**
   * Deliver [message] to subscribers
   */
  Completer deliver(Message message) {
    if(_enricher != null) {
      _enricher(message);
    }
    final completer = _registerMessage(message);
    final subscribers = _getSubscribers(message.runtimeType);
    if(subscribers.isNotEmpty) {
      subscribers.forEach((s) {
        s.add(message);
      });
    } else {
      if(deadMessageHandler != null) {
        deadMessageHandler(message);
      }
      _completeSuccess(message, 0);
    }
    return completer;
  }

  set enricher(MessageEnricher enricher) => _enricher = enricher;

  _completeSuccess(Message message, Object successData) {
    Guid messageId = _getMessageId(message);
    var completer = _messageCompleters[messageId];
    // notify completer of successful delivery
    completer.complete(successData);
    _unregisterMessage(messageId);
  }

  _completeError(Message message) {
    Guid messageId = _getMessageId(message);
    var completer = _messageCompleters[messageId];
    // notify completer of delivery error
    var errorData = (message.headers["messageFailures"] as List);
    if(errorData.isEmpty) {
      throw new StateError("message $message cannot fail without errors");
    }
    completer.completeError(errorData);
    _unregisterMessage(messageId);
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

  int _incrementDelivery(Message message) {
    int deliveredTo = (message.headers["messageDeliveredTo"] as int) + 1;
    message.headers["messageDeliveredTo"] = deliveredTo;
    return deliveredTo;
  }

  bool _isMessageFailed(Message message) {
    return (message.headers["messageFailures"] as List).isNotEmpty;
  }

  bool _isMessageDeliverable(Message message) {
    return message.headers["messageDeliverable"] as bool;
  }

  _notifyDelivery(Message message) {
    int deliveredTo = _incrementDelivery(message);
    int numberOfSubscribers = _numberOfSubscribers(message);
    if(deliveredTo >= numberOfSubscribers) {
      if(_isMessageFailed(message)) {
        _completeError(message);
      } else {
        _completeSuccess(message, deliveredTo);
      }
    }
  }

  _notifyError(Message message) {
   _incrementDelivery(message);
    message.headers["messageDeliverable"] = false;
    _completeError(message);
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

  /**
   * Register message in coordinators pipelines, creates notifcation completer and message id
   */
  Completer _registerMessage(Message message) {
    Guid messageId = _getMessageId(message);
    if(messageId == null) {
      messageId = new Guid();
      message.headers["messageId"] = messageId;     // id of message
      message.headers["messageDeliverable"] = true; // true if message can still be deliverd
      message.headers["messageFailures"] = [];      // list of failures emitted by message handlers for this message
      message.headers["messageDeliveredTo"] = 0;    // number of subscribers that have recived message
      var completer = new Completer();
      _messageCompleters[messageId] = completer;
    }
    return _messageCompleters[messageId];
  }

  /**
   * Unregister [Message] with [messageId] from coordinator, removes used completers
   */
  _unregisterMessage(Guid messageId) {
    _messageCompleters.remove(messageId);
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

    return _coordinator.listen(messageType, _wrapped, onData, onError, cancelOnError);
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
    Completer completer;
    if(message is CallbackCompleted) {
      // completes when custom code calls the messages succeded or failed handlers
      completer = new Completer();
      message._onSuccess = (callbackData) {
        completer.complete(callbackData);
      };
      message._onError = (errorData) {
        completer.completeError(errorData);
      };
      _coordinator.deliver(message);
    } else {
      // completes when message is delivered
      completer =  _coordinator.deliver(message);;
    }
    return completer;
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
