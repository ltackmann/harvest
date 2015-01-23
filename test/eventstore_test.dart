// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

import 'package:harvest/harvest.dart';
import 'package:harvest/harvest_file.dart';
import 'package:unittest/unittest.dart';

main() {
  new EventStoreTest();
}

class EventStoreTest {
  EventStoreTest() {
    group('message bus -', () {
      var messageRecievedCount = 0;
      var messageBus = new MessageBus();
      
      test('listen to messages', () {
        messageBus.stream(TestEvent).listen((TestEvent message) {
          expect(message.data, equals('test'));
          messageRecievedCount++;
        });
        messageBus.everyMessage.listen((TestEvent message) {
          expect(message.data, equals('test'));
          messageRecievedCount++;
        });
      });
      
      test('fire message', () {
        messageBus.fire(new TestEvent('test'));
        // TODO how to test async expect(messageRecievedCount, equals(2));
      });
    });
    
    group('memory event stream', () {
      var memoryEventStore = new MemoryEventStore();
      _testEventStore(memoryEventStore);
    });
    
    group('file event stream', () {
      var fileEventStore = new FileEventStore("/tmp/eventlog");
      _testEventStore(fileEventStore);
    });
  }
  
  _testEventStore(EventStore eventStore) {
    Guid streamId = new Guid();
    EventStream stream;
    
    test('get stream', () {
      eventStore.openStream(streamId).then(expectAsync((EventStream s) {
        stream = s;
        expect(stream, isNotNull);
      }));
    });
    
    test('add events', () {
      stream.add(new TestEvent('initial event'));
      stream.add(new TestEvent('another event'));
      expect(stream.hasUncommittedEvents, isTrue);
      expect(stream.committedEvents, isEmpty);
    });
    
    test('commit events', () {
      stream.commitChanges().then(expectAsync((int committedEvents) {
        expect(committedEvents, greaterThan(0));
        expect(stream.hasUncommittedEvents, isFalse);
        expect(stream.committedEvents, isNot(isEmpty));
      })); 
    });
    
    test('reload stream', () {
      eventStore.openStream(streamId).then(expectAsync((EventStream stream2) {
        expect(stream.id, equals(stream2.id));
        expect(stream.streamVersion, equals(stream2.streamVersion));
        expect(stream.committedEvents, orderedEquals(stream2.committedEvents));
      }));
    });
  }
}

class TestEvent extends DomainEvent {
  TestEvent(this.data);
  
  final String data;
}

