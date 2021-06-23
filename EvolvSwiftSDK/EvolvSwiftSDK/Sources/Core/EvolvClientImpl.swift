//
//  EvolvClientImpl.swift
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

public struct EvolvClientImpl: EvolvClient {
    
    private var initialized = false
    
    
    
    public func confirm() {
        return
    }
    
    public func contaminate() {
        return
    }
    
    public func get(value forKey: String) {
        return
    }
    
    public func initialize(uid: String, remoteContext: [String : Any], localContext: [String : Any]?) {
        return
    }
    
    public func reevaluateContext() {
        return
    }
    
}


public struct Options {
    let version: Int = 1
    let environment: Any
    let autoConfirm: Bool
    let endpoint: URL
    let analytics: String
    let store: EvolvStore
    let context: EvolvContext
    let beacon: EvolvBeacon
    let bufferEvents: [String: Any]
    
    
}


