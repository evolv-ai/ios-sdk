//
//  EvolvContextImpl.swift
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

public struct EvolvContextImpl: EvolvContext {
    private var remoteContext: [String : Any] = [:]
    private var localContext: [String : Any] = [:]
    
    public init(remoteContext: [String : Any], localContext: [String : Any]) {
        self.localContext = localContext
        self.remoteContext = remoteContext
    }
    
    public func resolve() -> [String: Any] {
        return [:]
    }
    
    public mutating func set(key: String, value: Any, local: Bool = false) -> [String : Any] {
        if local {
            localContext[key] = value
            return localContext
        } else {
            remoteContext[key] = value
            return remoteContext
        }
    }
    
    func mergeContext(localContext: [String : Any], remoteContext: [String : Any]) -> [String : Any] {
        return remoteContext.merging(localContext) { (current, _) in current }
    }
}
