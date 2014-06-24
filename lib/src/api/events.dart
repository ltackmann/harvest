// Copyright (c) 2013-2014, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_api;

/** The dead event is fired when a message is placed on the eventbus without any event listners associated with it. */
class DeadEvent extends Message {
  DeadEvent(this.deadMessage);
  
  final Message deadMessage;
}

/** Events that can be stored, ususally named in the past tense as they describe a event that has taken place */
abstract class DomainEvent extends Message {
  int version;
}






