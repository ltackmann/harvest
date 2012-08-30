// Copyright (c) 2012 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * File backed domain repository 
 */
class FileDomainRepository<T extends AggregateRoot> extends DomainRepository<T> {
  static Map<String, DomainRepository> _cache;
  static EventStore _store;
  
  /**
   * Creates a file backed domain repository in folder [directory]. Creates folder if it
   * does not exists.
   */
  factory FileDomainRepository(String type, AggregateBuilder aggregateBuilder, DomainEventFactory domainEventFactory, String directoryPath) {
    var directory = new Directory(directoryPath);
    if(!directory.existsSync()) {
      directory.createSync();
    }
    return new FileDomainRepository.directory(type, aggregateBuilder, domainEventFactory, directory);
  }
  
  /**
   * Creates a file backed domain repository in folder [directoryPath]. Creates folder if it
   * does not exists, empties it if it does.
   */
  factory FileDomainRepository.reset(String type, AggregateBuilder aggregateBuilder, DomainEventFactory domainEventFactory, String directoryPath) {
    var directory = new Directory(directoryPath);
    if(directory.existsSync()) {
      directory.deleteRecursivelySync();
    }
    return new FileDomainRepository(type, aggregateBuilder, domainEventFactory, directoryPath);
  }
  
  /**
   * Creates a file backed domain repository in existing folder [directory]. 
   */
  factory FileDomainRepository.directory(String type, AggregateBuilder aggregateBuilder, DomainEventFactory domainEventFactory, Directory directory) {
    Expect.isTrue(directory.existsSync());
    if(_store == null) {
      _store = new FileEventStore(directory, domainEventFactory);
    }
    if(_cache == null) {
      _cache = new Map<String, DomainRepository>();
    }
    if(!_cache.containsKey(type)) {
      _cache[type] = new FileDomainRepository._internal(type, aggregateBuilder);
    }
    return _cache[type];
  }

  FileDomainRepository._internal(String type, AggregateBuilder aggregateBuilder): super(type, aggregateBuilder, _store);
}
