// Copyright (c) 2012 Solvr, Inc. all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * The dead event is fired when a message is placed on the eventbus without any event listners associated with it.
 *
 * This is useful for ensuring the application works as expected. 
 */
class DeadEvent extends Message {
  static final String TYPE = "DeadEvent";
  final Message deadMessage;
  
  DeadEvent(this.deadMessage): super(TYPE);
}
