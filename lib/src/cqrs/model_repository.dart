// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Repository for working with read-models */
abstract class ModelRepository<T> {
  /** Get all instances of T */
  List<T> get all;

  T getById(Guid id);

  /**
   * Get instance of T for [id] if any exists or use [builder] to make a new one.
   */
  T getOrNew(Guid id, T builder());

  remove(T instance);

  removeById(Guid id);

  save(T instance);
}

/**
 * Marker interface than can optionally be put on models to ensure they can
 * be saved in the model repository.
 */
abstract class Identifiable {
  Guid get id;

  bool operator ==(o) => o is Identifiable && o.id == id;

  int get hashCode => id.hashCode;
}
