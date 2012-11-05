// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Domain events are produced by the domain when an action is completed. Domain events are usually 
 * named in the past tense and can be persisted in a event store and replaied later to set the 
 * domain in any state
 *
 * Since these events are persisted its best they be constructed from primitive serializable types
 */
class DomainEvent extends Message {
  DomainEvent(String type): super(type);
  
  int version;
}
