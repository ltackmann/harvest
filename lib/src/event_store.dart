// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Facade for creating and accessing [EventStream]s
 */
abstract class EventStore {
  /**
   * Open an [EventStream] asynchronously for [id], fails if [EventStream] version does not match [expectedVersion]
   */
  Future<EventStream> openStream(Guid id, [int expectedVersion = -1]);

  /**
   * True if the [EventStore] contains a stream for [id]
   */
  bool containsStream(Guid id);
}

/** Track a series of events and commit them to durable storage */
abstract class EventStream {
  add(DomainEvent event);

  addAll(Iterable<DomainEvent> events);

  /// Clears uncommitted changes.
  clearChanges();

  /// Commits uncommitted events, returns future with the number of events commited
  Future<int> commitChanges();

  /// List of events persisted in the event store
  Iterable<DomainEvent> get committedEvents;

  /// true if uncommited events exists
  bool get hasUncommittedEvents;

  Guid get id;

  /// Version of the latest event stored in the stream
  int get streamVersion;

  /// List of events that are not persisted in the event store
  Iterable<DomainEvent> get uncommittedEvents;
}

/** Optimistic concurrency conflict between multiple writers. */
class ConcurrencyError extends Error {
  ConcurrencyError(this.message);

  String toString() => message;

  final String message;
}
