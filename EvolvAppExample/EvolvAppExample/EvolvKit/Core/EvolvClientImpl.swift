//
//  EvolvClient.swift
//
//  Copyright (c) 2021 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public protocol EvolvClient {
    
    /// If the client was configured with bufferEvents: true then calling this will allow data to be sent back to Evolv
    func allowEvents()
    
    //    Depricated
    /// Clears the active keys to reset the key states.
    /// - Parameter prefix: The prefix of the keys clear.
    func clearActiveKeys(for prefix: String)
    
    /// Sends a confirmed event to Evolv.
    ///
    /// Method produces a confirmed event which confirms the participant's
    /// allocation. Method will not do anything in the event that the allocation
    /// timed out or failed.
    /// Confirm that the consumer has successfully received and applied values, making them eligible for inclusion in optimization statistics.
    func confirm()
    
    /// Sends a contamination event to Evolv.
    ///
    ///  Method produces a contamination event which will contaminate the
    /// participant's allocation. Method will not do anything in the event
    /// that the allocation timed out or failed.
    /// - Parameter details: Optional. Information on the reason for contamination. If provided, the object should contain a reason. Optionally, a 'details' value should be included for extra debugging info
    /// - Parameter allExperiments: If true, the user will be excluded from all optimizations, including optimization not applicable to this page
    func contaminate(for details: AnyObject?, _ allExperiments: Bool)
    
    /// Destroy the client and its dependencies.
    func destroy()
    
    /// Emits a generic event to be recorded by Evolv.
    ///
    /// Sends an event to Evolv to be recorded and reported upon.
    ///
    /// - Parameter key: The identifier of the event.
    func emit(for key: String)
    
    /// Force all beacons to transmit.
    func flush()
    
    /// Get the value of a specified key.
    /// - Parameter forKey: The identifier of the event.
    func get(value forKey: String)
    
    /// Check all active keys that start with the specified prefix.
    /// - Parameter prefix: The prefix of the keys to check.
    func getActiveKeys(for prefix: String)
    
    /// Get the configuration for a specified key.
    /// - Parameter key: The key to retrieve the configuration for.
    func getCongig(for key: String)
    
    /// Initializes the client with required context information.
    /// - Parameter uid: A globally unique identifier for the current participant.
    /// - Parameter sid: A globally unique session identifier for the current participant.
    /// - Parameter remoteContext: A map of data used for evaluating context predicates and analytics.
    /// - Parameter localContext: A map of data used only for evaluating context predicates.
    func initialize(uid: String, sid: String, remoteContext: AnyObject, localContext: AnyObject)
    
    /// Check if a specified key is currently active.
    /// - Parameter key: The key to check.
    func isActive(for key: String)
    
//    TODO: check method and implementation in Javascript SDK
    /// Add listeners to lifecycle events that take place in to client.
    /// See Constants/Events for currently supported events
    /// - Parameter topic: The event topic on which the listener should be invoked.
    /// - Parameter listener: The listener to be invoked for the specified topic.
    func on(with topic: String, for listener: () -> ())
    
//    TODO: check method and implementation in Javascript SDK
    /// Add a listener to a lifecycle event to be invoked once on the next instance of the event to take place in to client.
    /// See Constants/Events for currently supported events
    /// - Parameter topic: The event topic on which the listener should be invoked.
    /// - Parameter listener: The listener to be invoked for the specified topic.
    func once(with topic: String, for listener: () -> ())
    
//    TODO: check method and implementation in Javascript SDK
    /// Preload all keys under under the specified prefixes.
    /// - Parameter prefixes: A list of prefixes to keys to load.
    /// - Parameter configOnly: If true, only the config would be loaded. (default: false)
    /// - Parameter immediate: Forces the requests to the server. (default: false)
    func preload(for prefixes: Array<String>, with configOnly: Bool, immediate: Bool)
    
    /// Reevaluates the current context.
    func reevaluateContext()
}
