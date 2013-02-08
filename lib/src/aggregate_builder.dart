// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Function that returns a bare aggregate root for the supplied id 
 */ 
typedef AggregateRoot AggregateBuilder(Uuid aggregateId);
