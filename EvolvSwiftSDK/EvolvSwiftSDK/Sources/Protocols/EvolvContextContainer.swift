//
//  EvolvContext.swift
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

/// The EvolvContext provides functionality to manage data relating to the client state, or context in which the variants will be applied.
/// This data is used for determining which variables are active, and for general analytics.
protocol EvolvContextContainer {
    var remoteContext: [String : Any] { get }
    
    var localContext: [String : Any] { get }
    
    var mergedContextUserInfo: [String : Any] { get }
    
    var activeKeys: CurrentValueSubject<Set<String>, Never> { get }
    
    var activeVariants: CurrentValueSubject<Set<String>, Never> { get }
    
    var activeEntryKeys: CurrentValueSubject<Set<String>, Never> { get }
    
    var confirmations: [EvolvConfirmation] { get set }
    
    var contaminations: [EvolvContamination] { get set }
    
    var events: [EvolvCustomEvent] { get set }
    
    /// Computes the effective context from the local and remote contexts.
    func resolve() -> [String: Any]
    
    /// Sets a value in the current context.
    /// - Note: This will cause the effective genome to be recomputed.
    /// - Parameter key: The key to associate the value to.
    /// - Parameter value: The value to associate with the key.
    /// - Parameter local: If true, the value will only be added to the localContext.
    /// - Returns: True if the context was updated. False if the the context already had the provided value set for this key.
    @discardableResult
    mutating func set(key: String, value: Any, local: Bool) -> Bool
    
//    /// Merge the specified object into the current context.
//    /// Note: This will cause the effective genome to be recomputed.
//    /// - Parameter update: The values to update the context with.
//    /// - Parameter value: If true, the values will only be added to the localContext.
//    func update(update: AnyObject, local: Bool)
    func getActiveKeys() -> Set<String>
    
    mutating func reevaluateContext(with configuration: Configuration, allocations: [Allocation])
}
