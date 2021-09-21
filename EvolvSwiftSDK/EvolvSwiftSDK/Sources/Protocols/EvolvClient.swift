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

import Combine

public protocol EvolvClient {
    /// Active keys evaluated in the current Evolv context.
    var activeKeys: CurrentValueSubject<Set<String>, Never> { get }
    
    var activeVariantKeys: CurrentValueSubject<Set<String>, Never> { get }
    
    /// Initialises EvolvClient with desired EvolvClientOptions
    /// - Parameter options: Provide desired options for the EvolvClient.
    /// - Returns: Publisher for the EvolvClient object.
    static func initialize(options: EvolvClientOptions) -> AnyPublisher<EvolvClient, Error>
    
    /// Sends a confirmed event to Evolv.
    ///
    /// Method produces a confirmed event which confirms the participant's
    /// allocation. Method will not do anything in the event that the allocation
    /// timed out or failed.
    /// Confirm that the consumer has successfully received and applied values, making them eligible for inclusion in optimization statistics.
    func confirm()
    
    /// Sends a contamination event to Evolv.
    ///
    /// Method produces a contamination event which will contaminate the
    /// participant's allocation. Method will not do anything in the event
    /// that the allocation timed out or failed.
    /// - Parameter details: Optional. Information on the reason for contamination.
    /// - Parameter allExperiments: If true, the user will be excluded from all optimizations, including optimization not applicable to this page.
    func contaminate(details: EvolvContaminationReason?, allExperiments: Bool)
    
    /// Get the value of a specified key.
    /// - Parameter valueForKey: The identifier of the event.
    func get(valueForKey key: String) -> Any?
    
    func get<T: Decodable>(decodableValueForKey key: String) throws -> T?
    
    func get(subscriptionOnValueForKey key: String) -> AnyPublisher<Any?, Never>
    
    func get<T: Decodable>(subscriptionDecodableOnValueForKey key: String) -> AnyPublisher<T?, Never>
    
    /// Sets a value in the current context.
    /// - Note: This will cause the effective genome to be recomputed.
    /// - Parameter key: The key to associate the value to.
    /// - Parameter value: The value to associate with the key.
    /// - Parameter local: If true, the value will only be added to the localContext.
    /// - Returns: True if the context was updated. False if the the context already had the provided value set for this key.
    @discardableResult
    func set(key: String, value: Any, local: Bool) -> Bool
    
    /// Reevaluates the current context.
    func reevaluateContext()
    
    /// Gets active keys.
    func getActiveKeys() -> Set<String>
}

// MARK: - Default implementation and optional protocol methods
//extension EvolvClient {
//
//    /// Check all active keys that start with the specified prefix.
//    /// - Parameter prefix: The prefix of the keys to check.
//    func getActiveKeys(for prefix: String) -> Bool {
//        return true
//    }
//
//    //    Deprecated
//    /// Clears the active keys to reset the key states.
//    /// - Parameter prefix: The prefix of the keys clear.
//    func clearActiveKeys(for prefix: String) -> Bool {
//        return true
//    }
//
//    /// If the client was configured with bufferEvents: true then calling this will allow data to be sent back to Evolv
//    func allowEvents() -> Bool {
//        return true
//    }
//
//    /// Destroy the client and its dependencies.
//    func destroy() -> Bool {
//        return true
//    }
//
//    /// Emits a generic event to be recorded by Evolv.
//    ///
//    /// Sends an event to Evolv to be recorded and reported upon.
//    ///
//    /// - Parameter key: The identifier of the event.
//    func emit(for key: String) -> Bool {
//        return true
//    }
//
//    /// Force all beacons to transmit.
//    func flush() -> Bool {
//        return true
//    }
//
//    /// Check if a specified key is currently active.
//    /// - Parameter key: The key to check.
//    func isActive(for key: String) -> Bool {
//        return true
//    }
//
////    TODO: check method and implementation in Javascript SDK
//    /// Add listeners to lifecycle events that take place in to client.
//    /// See Constants/Events for currently supported events
//    /// - Parameter topic: The event topic on which the listener should be invoked.
//    /// - Parameter listener: The listener to be invoked for the specified topic.
//    func on(with topic: String, for listener: () -> ()) -> Bool {
//        return true
//    }
//
////    TODO: check method and implementation in Javascript SDK
//    /// Add a listener to a lifecycle event to be invoked once on the next instance of the event to take place in to client.
//    /// See Constants/Events for currently supported events
//    /// - Parameter topic: The event topic on which the listener should be invoked.
//    /// - Parameter listener: The listener to be invoked for the specified topic.
//    func once(with topic: String, for listener: () -> ()) -> Bool {
//        return true
//    }
//
////    TODO: check method and implementation in Javascript SDK
//    /// Preload all keys under under the specified prefixes.
//    /// - Parameter prefixes: A list of prefixes to keys to load.
//    /// - Parameter configOnly: If true, only the config would be loaded. (default: false)
//    /// - Parameter immediate: Forces the requests to the server. (default: false)
//    func preload(for prefixes: [String: String], with configOnly: Bool, immediate: Bool) -> Bool {
//        return true
//    }
//
//    /// Get the configuration for a specified key.
//    /// - Parameter key: The key to retrieve the configuration for.
//    func getConfig(for key: String) -> Bool {
//        return true
//    }
//
//
//
//
//
//}
