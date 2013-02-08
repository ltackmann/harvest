// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dart_store;

/**
 * Application events are not part of the CQRS event chain (and thus not persisted). They serve the same purpose
 * within the application as ordinary events (to signal that something has happend).
 *
 * A typical usage scenario would be a event that signal widgets that something has happend elsewhere on the screen. This 
 * type of information is typically not persisted and should therefor not be handled by ordinary event handlers.
 *
 * Since these events are not persisted they are allowed to hold access to complicated objects such as view models
 */
class ApplicationEvent extends Message {
  ApplicationEvent(String type): super(type);
}
