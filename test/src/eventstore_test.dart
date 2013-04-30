// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_test;

class EventStoreTest {
  EventStoreTest() {
    group('message bus -', () {
      var messageRecievedCount = 0;
      var messageBus = new MessageBus();
      
      test('listen to messages', () {
        messageBus.stream(TestEvent).listen((e) {
          expect(e.data, equals('test'));
          messageRecievedCount++;
        });
        messageBus.everyMessage.listen((e) {
          expect(e.data, equals('test'));
          messageRecievedCount++;
        });
      });
      
      test('fire message', () {
        messageBus.fire(new TestEvent('test'));
        expect(messageRecievedCount, equals(2));
      });
    });
    
    group('event stream', () {
      EventStream stream;
      
      test('get stream', () {
        var eventStore = new MemoryEventStore();
        stream = eventStore.openStream(new Guid());
        expect(stream, isNotNull);
      });
      
      test('add events', () {
        stream.add(new TestEvent('initial event'));
        stream.add(new TestEvent('another event'));
        expect(stream.hasUncommittedEvents, isTrue);
        expect(stream.committedEvents, isEmpty);
      });
      
      test('commit events', () {
        stream.commitChanges(); 
        expect(stream.hasUncommittedEvents, isFalse);
        expect(stream.committedEvents, isNot(isEmpty));
      });
      
      test('fail opening stream if version is incorrect', () {
        // TODO fix expect(() => eventStore.openStream(id, 0), throws);
      });
      // https://github.com/joliver/EventStore/blob/master/doc/EventStore.Example/MainProgram.cs
    });
  }
}

class TestEvent extends DomainEvent {
  TestEvent(this.data);
  final String data;
}

