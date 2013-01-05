// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Application commands are not part of the CQRS event chain (and are thus not handled by ordinary command handlers). 
 * They serve the same purpose within the application as ordinary commands (to signal that something should be done).
 *
 * A typical usage scenario would be a command that tells the user interface to change it self. This is typically not
 * something that is part of the domain and should thus not be handled by it.
 *
 * Since these events are not persisted they are allowed to hold access to complicated objects such as view models
 */
class ApplicationCommand extends Message {
  ApplicationCommand(String type): super(type);
}
