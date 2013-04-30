// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of harvest_cqrs;

/**
 * Application events are not part of the CQRS event chain (and thus not persisted). They serve the same purpose
 * within the application as ordinary events (to signal that something has happend).
 *
 * A typical usage scenario would be a event that signal widgets that something has happend elsewhere on the screen. This 
 * type of information is typically not persisted and should therefor not be handled by ordinary event handlers.
 *
 * Since these events are not persisted they are allowed to hold access to complicated objects such as view models
 */
class ApplicationEvent extends Message { }

/**
 * Domain events are produced by the domain when an action is completed. Domain events are usually 
 * named in the past tense and can be persisted in a event store and replaied later to set the 
 * domain in any state
 *
 * Since these events are persisted its best they be constructed from primitive serializable types
 */
class DomainEvent extends PersistentEvent { }

