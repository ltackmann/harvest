// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

import 'package:harvest/harvest.dart';
import 'package:test/test.dart';

import 'src/harvest_test_helpers.dart';

main() {
  new MessageBusTest(true);
  //new MessageBusTest(false);
}

class MessageBusTest {
  final bool sync;

  MessageBusTest(this.sync) {
    var testType = sync ? "synchronous" : "asynchronous";

    group("$testType message bus -", () {
      test("deliver messages with one message type subscriber and no every message subscriber", () async {
        var messageBus = getMessageBus();
        var messageRecieved = 0;
        messageBus.subscribe(TestEvent, (_) {
          messageRecieved++;
        });
        var delivered = await messageBus.publish(new TestEvent('message 1'));
        expect(delivered, equals(1), reason:"delivered to one subscriber");
        expect(messageRecieved, equals(1), reason:"subscriber recieved one message");
      });

      test("deliver message with no message type subscriber and one every message subscriber", () async {
         var messageBus = getMessageBus();
         var messageRecieved = 0;
         messageBus.everyMessage.listen((_) {
           messageRecieved++;
         });
         var delivered = await messageBus.publish(new TestEvent('message 1'));
         expect(delivered, equals(1), reason:"delivered to one subscriber");
         expect(messageRecieved, equals(1), reason:"subscriber recieved one message");
      });

      test("deliver messages with one message type subscriber and one every message subscriber", () async {
        var messageBus = getMessageBus();
        var messageRecieved = 0;
        messageBus.everyMessage.listen((_) {
          messageRecieved++;
        });
        messageBus.subscribe(TestEvent, (_) {
          messageRecieved++;
        });
        var delivered = await messageBus.publish(new TestEvent('message 1'));
        expect(delivered, equals(2), reason:"delivered to two subscribers");
        expect(messageRecieved, equals(2), reason:"two subscribers recieved one message");
      });

      test("deliver messages with no message type subscriber and no every message subscriber", () async {
        var messageBus = getMessageBus();
        var messageRecieved = 0;
        var deadEventsRecived = 0;
        messageBus.deadMessageHandler = (Message m) {
          deadEventsRecived++;
        };
        var delivered = await messageBus.publish(new TestEvent('message 1'));
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
        var delivered = await messageBus.publish(new TestEvent('message 1'));
        expect(delivered, equals(2), reason:"delivered to two subscribers");
        expect(testMessageRecieved, equals(2), reason:"delivered to two subscribers");

        // cancel one subscription and deliver
        await subscription1.cancel();
        expect(subscription2.isPaused, equals(false), reason:"second subscription should be unaffected");
        delivered = await messageBus.publish(new TestEvent('message 2'));
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

        var delivered = await messageBus.publish(new TestEvent("message 1"));
        expect(delivered, equals(1));
        expect(messageTypes, hasLength(1));
        expect(messageTypes.first, equals(TestEvent));
      });

      test("message looping", () async {
        var messageBus = getMessageBus();
        var messageRecieved = 0;
        messageBus.subscribe(TestEvent, (_) {
          messageRecieved++;
        });

        var messages = [new TestEvent("message 1"), new TestEvent("message 2"), new TestEvent("message 3")];
        for(Message message in messages) {
          var delivered = await messageBus.publish(message);
          expect(delivered, equals(1), reason:"delivered to one subscriber");
        }
        expect(messageRecieved, equals(3), reason:"one subscriber recieved three message");
      });
    });

    group("$testType message bus error handling -", () {
      test("cancelOnError=false causes all subscribers to be invoked", () async {
        var messageBus = getMessageBus();
        int errors = 0;
        // register subscribers that fails
        messageBus.stream(TestEvent).listen((TestEvent e) => throw "error 1", onError: (_) => errors++);
        messageBus.stream(TestEvent).listen((TestEvent e) => throw "error 2", onError: (_) => errors++);
        var result;
        try {
          await messageBus.publish(new TestEvent("message 1"));
        } catch(e) {
          result = e;
        }
        expect(result, orderedEquals(["error 1", "error 2"]));
        expect(errors, equals(2));
      });

      test("cancelOnError=true causes only failed subscriber to be invoked", () async {
        var messageBus = getMessageBus();
        int errors = 0;
        // register subscribers that fails first and second time they recieve a message
        messageBus.stream(TestEvent).listen((TestEvent e) => (errors==0) ? throw "error 1" : null, onError: (e) {
          errors++;
        }, cancelOnError: true);
        messageBus.stream(TestEvent).listen((TestEvent e) => (errors==1) ? throw "error 2" : null, onError: (e) {
          errors++;
        }, cancelOnError: true);

        // first message
        var result1;
        try {
           await messageBus.publish(new TestEvent("message 1"));
        } catch(e) {
          result1 = e;
        }
        expect(result1, orderedEquals(["error 1"]), reason:"first delivery causes first subscriber to fail");

        // second message
        var result2;
        try {
           await messageBus.publish(new TestEvent("message 2"));
        } catch(e) {
          result2 = e;
        }
        expect(result2, orderedEquals(["error 2"]), reason:"second delivery causes second subscriber to fail");

        // third message
        var delivered = await messageBus.publish(new TestEvent("message 3"));
        expect(delivered, equals(2));
      });

      test("message call back success", () async {
        var messageBus = getMessageBus();
        messageBus.stream(TestCommand).listen((TestCommand cmd) {
          cmd.succeeded("success");
        });
        var delivered = await messageBus.publish(new TestCommand("command 1"));
        expect(delivered, equals("success"));
      });

      test("message call back fails", () async {
        var messageBus = getMessageBus();
        messageBus.stream(TestCommand).listen((TestCommand cmd) {
          cmd.failed("failure");
        });
        var result;
        try {
          await messageBus.publish(new TestCommand("command 2"));
        } catch(e) {
          result = e;
        }
        expect(result, equals("failure"));
      });

      test("nested message call back fails", () async {
        var messageBus = getMessageBus();
        messageBus.stream(TestEvent).listen((TestEvent e) {
          throw "nested event failure";
        });
        messageBus.stream(TestCommand).listen((TestCommand cmd) {
          messageBus.publish(new TestEvent("event")).catchError((e) => cmd.failed(e.toString()));
        });
        var result;
        try{
          result = await messageBus.publish(new TestCommand("command 3"));
        } catch(e) {
          result = e;
        }
        expect(result, equals("[nested event failure]"));
      });
    });

    // TODO ubsubscribe all
    // TODO look into coveralls report and test missing areas
  }

  MessageBus getMessageBus() => sync ? new MessageBus() : new MessageBus.async();
}
