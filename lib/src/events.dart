// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/** Events that can be stored, ususally named in the past tense as they describe a event that has taken place */
abstract class DomainEvent extends Message {
  int version;
}

/**
 * Application events are not part of the CQRS event chain (and thus not persisted). They serve the same purpose
 * within the application as ordinary events (to signal that something has happend).
 *
 * A typical usage scenario would be a event that signal widgets that something has happend elsewhere on the screen. This
 * type of information is typically not persisted and should therefor not be handled by ordinary event handlers.
 *
 * Since application events are not persisted they are allowed to hold access to complicated objects such as view models
 */
class ApplicationEvent extends Message { }
