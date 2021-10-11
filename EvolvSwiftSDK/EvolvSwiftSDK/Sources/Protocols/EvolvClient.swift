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

/// The EvolvClient provides a low level integration with the Evolv participant APIs.
public protocol EvolvClient {
    /// Active keys evaluated in the current Evolv context.
    var activeKeys: AnyPublisher<Set<String>, Never> { get }
    
    /// Active variant keys evaluated in the current Evolv context.
    var activeVariantKeys: AnyPublisher<Set<String>, Never> { get }
    
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
    /// - Parameter valueForKey: The key of the value to retrieve.
    /// - Returns: Value for the provided key.
    func get(valueForKey key: String) -> Any?
    
    /// Get the value of a specified key.
    /// - Parameter valueForKey: The key of the value to retrieve.
    /// - Returns: Decoded value for the provided key. Value MUST be of `JSON` type.
    func get<T: Decodable>(decodableValueForKey key: String, type: T.Type) throws -> T?
    
    /// Get the publisher of values of the specified key.
    /// - Parameter valueForKey: The key of the value to retrieve.
    /// - Returns: Publisher that will broadcast values whenever the change for the specified key.
    func get(subscriptionOnValueForKey key: String) -> AnyPublisher<Any?, Never>
    
    /// Get the publisher of values of the specified key & decode it.
    /// - Parameter valueForKey: The key of the value to retrieve.
    /// - Returns: Publisher that will broadcast decoded values whenever the change for the specified key. Value MUST be of `JSON` type.
    func get<T: Decodable>(subscriptionDecodableOnValueForKey key: String, type: T.Type) -> AnyPublisher<T?, Never>
    
    /// Sets a value in the current context.
    /// - Note: This will cause the effective genome to be recomputed.
    /// - Parameter key: The key to associate the value to.
    /// - Parameter value: The value to associate with the key.
    /// - Parameter local: If true, the value will only be added to the localContext.
    /// - Returns: True if the context was updated. False if the the context already had the provided value set for this key.
    @discardableResult
    func set(key: String, value: String, local: Bool) -> Bool
    
    /// Remove a specified key from the context.
    /// - Note: This will cause the effective genome to be recomputed.
    /// - Parameter key: The key to remove from the current context.
    /// - Returns: True if the context was updated. False if the the context didn't have specified key.
    @discardableResult
    func remove(key: String) -> Bool
    
    /// Send an event to the events endpoint.
    /// - Parameter eventType: The type associated with the event.
    /// - Parameter metadata: Any metadata to attach to the event.
    /// - Parameter flush: If true, the event will be sent immediately.
    func emit<T: Encodable>(eventType: String, metadata: T?, flush: Bool)
    
    /// Send an event to the events endpoint.
    /// - Parameter eventType: The type associated with the event.
    /// - Parameter flush: If true, the event will be sent immediately.
    func emit(eventType: String, flush: Bool)
    
    /// Reevaluates the current context.
    func reevaluateContext()
    
    /// Gets active keys.
    func getActiveKeys() -> Set<String>
    
    /// Add listeners to lifecycle events that take place in to client.
    /// - Parameter topic: The event topic on which the listener should be invoked.
    /// - Parameter listener: The listener to be invoked for the specified topic.
    func on(topic: String, listener: (@escaping (_ userInfo: [String : Any?]) -> Void))
    
    /// Add a listener to a lifecycle event to be invoked once on the next instance of the event to take place in to client.
    /// - Parameter topic: The event topic on which the listener should be invoked.
    /// - Parameter listener: The listener to be invoked for the specified topic.
    func once(topic: String, listener: (@escaping (_ userInfo: [String : Any?]) -> Void))
}
