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
  final bool sync;
  
  MessageBusTest(this.sync) {
    var testType = sync ? "synchronous" : "asynchronous";
    
    group("$testType message bus -", () {
      test("one message type subscriber, no every message subscriber", () async {
        var messageBus = getMessageBus(); 
        var messageRecieved = 0;
        messageBus.subscribe(TestEvent, (_) {
          messageRecieved++;
        });
        var delivered = await messageBus.publish(new TestEvent('test1'));  
        expect(delivered, equals(1), reason:"delivered to one subscriber");
        expect(messageRecieved, equals(1), reason:"subscriber recieved one message");
      });  
     
      test("no message type subscriber, one every message subscriber", () async {
         var messageBus = getMessageBus(); 
         var messageRecieved = 0;
         messageBus.everyMessage.listen((_) {
           messageRecieved++;
         });
         var delivered = await messageBus.publish(new TestEvent('test1'));  
         expect(delivered, equals(1), reason:"delivered to one subscriber");
         expect(messageRecieved, equals(1), reason:"subscriber recieved one message");
      });
      
      test("one message type subscriber, one every message subscriber", () async {
        var messageBus = getMessageBus(); 
        var messageRecieved = 0;
        messageBus.everyMessage.listen((_) {
          messageRecieved++;
        });
        messageBus.subscribe(TestEvent, (_) {
          messageRecieved++;
        });
        var delivered = await messageBus.publish(new TestEvent('test1'));  
        expect(delivered, equals(2), reason:"delivered to two subscribers");
        expect(messageRecieved, equals(2), reason:"two subscribers recieved one message");
      });
      
      test("no message type subscriber, no every message subscriber", () async {
        var messageBus = getMessageBus(); 
        var messageRecieved = 0;
        var deadEventsRecived = 0;
        messageBus.deadMessageHandler = (Message m) {
          deadEventsRecived++;
        };
        var delivered = await messageBus.publish(new TestEvent('test1'));  
        expect(delivered, equals(0), reason:"no subscribers recieved message");
        expect(messageRecieved, equals(0), reason:"no subscribers recieved message");
        expect(deadEventsRecived, equals(1), reason:"one dead events should be recieved");
      });
      
      test("message unsubscribing", () async {
        var messageBus = getMessageBus();
        var testMessageRecieved = 0;
                         
        // register two subscribers for TestEvent
        var subscription1 = messageBus.subscribe(TestEvent, (_) {
         testMessageRecieved++;
        });
        var subscription2 = messageBus.subscribe(TestEvent, (_) {
          testMessageRecieved++;
        });
        
        // deliver to both subscribers
        var delivered = await messageBus.publish(new TestEvent('test1'));  
        expect(delivered, equals(2), reason:"delivered to two subscribers");
        expect(testMessageRecieved, equals(2), reason:"delivered to two subscribers");
        
        // cancel one subscription and deliver
        await subscription1.cancel();
        expect(subscription2.isPaused, equals(false), reason:"second subscription should be unaffected");
        delivered = await messageBus.publish(new TestEvent('test3'));
        expect(delivered, equals(1), reason:"delivered to one subscriber");
        expect(testMessageRecieved, equals(3), reason:"one subcriber active for second delivery (2 prior messages and 1 new)");
      });
      
      
      test("messages should be enriched", () async {
        var messageBus = getMessageBus();
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
             
         var delivered = await messageBus.publish(new TestEvent("test 2"));
         expect(delivered, equals(1));
         expect(messageTypes, hasLength(1));
         expect(messageTypes.first, equals(TestEvent));
      });
    });
    
    // TODO test using stream API
    // TODO ubsubscribe all
  }
  
  MessageBus getMessageBus() => sync ? new MessageBus() : new MessageBus.async();
}