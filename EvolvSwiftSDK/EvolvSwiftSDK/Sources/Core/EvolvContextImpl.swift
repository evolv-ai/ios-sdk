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

public class EvolvContextImpl: EvolvContext {
    
    private var uid: String
    private var sid: String?
    private var remoteContext: [String : Any] = [:]
    private var localContext: [String : Any]?
    private var initialized = false
    
    
    private var evolvConfig: EvolvConfigImpl?
    private var evolvStore: EvolvStoreImpl?
    
    public required init(uid: String, remoteContext: [String : Any], localContext: [String : Any]?) {
        
        self.uid = uid
        self.localContext = localContext
        self.remoteContext = remoteContext
    }
    
    public func resolve() -> [String: Any] {
        var effectiveContext: [String: Any] = [:]
        return effectiveContext
    }
    
    public func set(key: String, value: [String: Any], local: Bool) {
        print("\(key) for \(value)")
    }
    
    
    
}


