// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_test;

class MessageTest {
  MessageTest() {
    group('message bus -', () {
      var messageRecievedCount = 0;
      var messageBus = new MessageBus();
      
      test('listen to messages', () {
        messageBus.stream(TestMessage).listen((e) {
          expect(e.data, equals('test'));
          messageRecievedCount++;
        });
        messageBus.everyMessage.listen((e) {
          expect(e.data, equals('test'));
          messageRecievedCount++;
        });
      });
      
      test('fire message', () {
        messageBus.fire(new TestMessage('test'));
        expect(messageRecievedCount, equals(2));
      });
    });
  }
}

class TestMessage extends Message {
  TestMessage(this.data);
  final String data;
}
