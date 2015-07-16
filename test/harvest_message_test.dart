// Copyright (c) 2013-2015, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

import 'package:harvest/harvest.dart';
import 'package:test/test.dart';

import 'src/harvest_test_helpers.dart';

main() {
  new MessageBusTest(true);
  new MessageBusTest(false);
}

class MessageBusTest {
  MessageBusTest(bool sync) {
    var testType = sync ? "synchronous" : "asynchronous";
    
    group("$testType message bus API", () {
      var messageBus = getMessageBus(sync);
      var testMessageRecieved = 0;
      var everyMessageRecieved = 0;
      var deadEventRecived = 0;
                     
      // register two listeners for TestEvent
      messageBus.subscribe(TestEvent, (_) {
       testMessageRecieved++;
      });
      messageBus.subscribe(TestEvent, (_) {
        testMessageRecieved++;
      });
      // listen to every message
      var everySubscription = messageBus.everyMessage.listen((Message m) {
        everyMessageRecieved++;
        if(m is DeadEvent) {
          deadEventRecived++;
        }
      });
      
      test('messages must be delivered to subscribers', () async {
        var delivered = await messageBus.fire(new TestEvent('test1'));  
        expect(delivered, equals(2), reason:"delivered to two test subscription");
        expect(testMessageRecieved, equals(2), reason:"two subscribers on every message");
        expect(deadEventRecived, equals(0), reason:"no dead events should be fored");
        expect(everyMessageRecieved, equals(1));
      });  
      
      test("unsubscribing should stop delivering messages", () async {
        await everySubscription.cancel();
        var delivered = await messageBus.fire(new TestEvent('test3'));
        expect(delivered, equals(4), reason:"delivered to two test subscription");
        expect(testMessageRecieved, equals(4), reason:"two subscribers on every message");
        expect(deadEventRecived, equals(0), reason:"no dead events should be fored");
        expect(everyMessageRecieved, equals(1), reason:"we have cancelled subscription to every message");
      }, skip:true);
      
      test("messages should be enriched", () async {
        messageBus.unsubscribeAll();
        // enricher that stores message type in headers
        messageBus.enricher = (Message m) {
          m.headers["messageType"] = m.runtimeType;    
        };  
        // listener that records message types stored by enricher
        var messageTypes = <Type>[];
        messageBus.everyMessage.listen((Message m) {
          var messageType = m.headers["messageType"] as Type;
          messageTypes.add(messageType); 
        });
            
        var delivered = await messageBus.fire(new TestEvent("test 2"));
        expect(delivered, equals(1));
        expect(messageTypes, hasLength(1));
        expect(messageTypes.first, equals(DeadEvent));
      });
      
      // TODO test unsubscribing for every body
    });
    
    // TODO test using stream API
  }
  
  MessageBus getMessageBus(bool sync) => sync ? new MessageBus() : new MessageBus.async();
}