// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_api;

abstract class EventStore {
  /** Open an [EventStream] asynchronously for [id], fails if [EventStream] version does not match [expectedVersion]*/
  Future<EventStream> openStream(Guid id, [int expectedVersion = -1]);
}

/** Track a series of events and commit them to durable storage */
abstract class EventStream {
  Guid get id;

  /// List of events persisted in the event store 
  Iterable<DomainEvent> get committedEvents;

  /// List of events that are not persisted in the event store 
  Iterable<DomainEvent> get uncommittedEvents;
  
  /// true if uncommited events exists
  bool get hasUncommittedEvents;

  /// Commits uncommitted events, returns future with the number of events commited
  Future<int> commitChanges();

  /// Clears uncommitted changes.
  clearChanges();
  
  addAll(Iterable<DomainEvent> events);
  
  add(DomainEvent event);
  
  /// Version of the latest event stored in the stream
  int streamVersion;
}

/** Optimistic concurrency conflict between multiple writers. */
class ConcurrencyError implements Error {
  ConcurrencyError(this.message);

  String toString() => message;
  
  final String message;
}