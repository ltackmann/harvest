// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest_test_helpers;

/**
 * Test [EventStore] implementations
 */
class EventStoreTester {
  EventStoreTester(EventStore eventStore) {
    Guid streamId = new Guid();
    EventStream stream;

    test('get stream', () async {
      stream = await eventStore.openStream(streamId);;
      expect(stream, isNotNull);
    });

    test('add events', () {
      stream.add(new TestEvent('initial event'));
      stream.add(new TestEvent('another event'));
      expect(stream.hasUncommittedEvents, isTrue);
      expect(stream.committedEvents, isEmpty);
    });

    test('commit events', () async {
      var committedEvents = await stream.commitChanges();
      expect(committedEvents, greaterThan(0));
      expect(stream.hasUncommittedEvents, isFalse);
      expect(stream.committedEvents, isNot(isEmpty));
    });

    test('reload stream', () async {
      var stream2 = await eventStore.openStream(streamId);
      expect(stream.id, equals(stream2.id));
      expect(stream.streamVersion, equals(stream2.streamVersion));
      expect(stream.committedEvents, orderedEquals(stream2.committedEvents));
    });
  }
}

class TestEvent extends DomainEvent {
  final String data;
  Guid id;

  TestEvent(this.data);
}

class TestCommand extends DomainCommand with CallbackCompleted {
  final String data;

  TestCommand(this.data);
}
