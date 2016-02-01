// Copyright (c) 2013, the Harvest project authors. Please see the AUTHORS 
// file for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of harvest;

/**
 * Application commands are not part of the CQRS event chain (and are thus not handled by ordinary command handlers).
 * They serve the same purpose within the application as ordinary commands (to signal that something should be done).
 *
 * A typical usage scenario would be a command that tells the user interface to change it self. This is typically not
 * something that is part of the domain and should thus not be handled by it.
 *
 * Since application commands are not persisted they are allowed to hold access to complicated objects such as view models
 */
class ApplicationCommand extends Message { }

/**
 * Commands represents a serialized method call and are created by the application. Commands are usually
 * written in the imperative tense and cannot be persisted as they can have possible side effects
 *
 * Since commands are not persisted they can contain arbitraly complex types
 */
class DomainCommand extends Message {

}
