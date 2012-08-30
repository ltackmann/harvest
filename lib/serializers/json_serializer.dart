// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Serialize [DomainEventDescriptor]'s to and from JSON
 */ 
class JsonSerializer {
  JsonSerializer(this._eventFactory);
  
  List<DomainEventDescriptor> loadJsonEventDescriptors(List<Map> jsonEventDescriptors) {
    var eventDescriptors = new List<DomainEventDescriptor>();
    if(!jsonEventDescriptors.isEmpty()) {
      jsonEventDescriptors.forEach((Map jsonEventDescriptor) {
        var domainEvent = _loadJsonDomainEvent(jsonEventDescriptor["eventData"]);
        var id = new Guid.fromValue(jsonEventDescriptor["id"]);
        eventDescriptors.add(new DomainEventDescriptor(id, domainEvent));
      });
    }
    return eventDescriptors;
  }
  
  DomainEvent _loadJsonDomainEvent(Map jsonDomainEvent) {
    var type = jsonDomainEvent["type"];
    var event = _eventFactory.build(type);
    // TODO load data using mirror API
    return event;
  }
  
  Map _writeJsonDomainEvent(DomainEvent event) {
    
  }
  
  Map writeJsonEventDescriptors(List<DomainEventDescriptor> eventDescriptors) {
    
  }
  
  final DomainEventFactory _eventFactory;
}
