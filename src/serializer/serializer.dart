// Copyright (c) 2012 Solvr, Inc. all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

abstract class Serializer<D, E extends DomainEvent> {
  abstract E fromData(D data);
  
  abstract D toData(E event);
}
