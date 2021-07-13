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


import Foundation

/// The EvolvContext provides functionality to manage data relating to the client state, or context in which the variants will be applied.
/// This data is used for determining which variables are active, and for general analytics.
public protocol EvolvContext {
    
    init(uid: String, remoteContext: [String: Any], localContext: [String: Any])
    
//    /// Checks if the specified key is currently defined in the context.
//    /// - Parameter key: The key to check.
//    func contains(key: Bool)
//
//    /// Checks if the specified key is currently defined in the context.
//    /// - Parameter key: The key associated with the value to retrieve.
//    func get(key: String)
//
//    /// Adds value to specified array in context. If array doesn't exist its created and added to.
//    /// - Parameter key: The array to add to.
//    /// - Parameter value: Value to add to the array.
//    /// - Parameter local: If true, the value will only be added to the localContext.
//    /// - Parameter limit: Max length of array to maintain.
//    func pushToArray(key: String, value: String, local: Bool, limit: Int)
//
//    /// Remove a specified key from the context.
//    /// Note: This will cause the effective genome to be recomputed.
//    /// - Parameter key: The key to remove from the context.
//    func remove(key: String)
    
    /// Computes the effective context from the local and remote contexts.
    func resolve() -> [String: Any]
    
    /// Sets a value in the current context.
    /// Note: This will cause the effective genome to be recomputed.
    /// - Parameter key: The key to associate the value to.
    /// - Parameter value: The value to associate with the key.
    /// - Parameter local: If true, the value will only be added to the localContext.
    func set(key: String, value: String, local: Bool) -> [String: Any]
    
//    /// Merge the specified object into the current context.
//    /// Note: This will cause the effective genome to be recomputed.
//    /// - Parameter update: The values to update the context with.
//    /// - Parameter value: If true, the values will only be added to the localContext.
//    func update(update: AnyObject, local: Bool)
    
}
