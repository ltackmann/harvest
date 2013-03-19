// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest;

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

/**
 * Factory for building [DomainEvent]'s from type names
 * 
 * TODO remove when mirrors support emit
 */ 
class DomainEventFactory {
  DomainEventFactory(): builder = new Map<String, DomainEventBuilder>();
  
  DomainEvent build(String type) => builder[type]();

  final Map<String, DomainEventBuilder> builder;
}

/**
 * Function that returns a bare domain event 
 * 
 * TODO remove this once mirrors support emit 
 */ 
typedef DomainEvent DomainEventBuilder();

/**
 * Decorate [DomainEvent] with extra attributes so its easy to store/retrieve
 * 
 * TODO should this class be private ?
 */
class DomainEventDescriptor {
  DomainEventDescriptor(this.id, this.eventData) {
    version = eventData.version;
  }
  
  DomainEvent eventData;
  Guid id;
  int version;
}

/**
 * Base class for events  
 */
abstract class Message { }
