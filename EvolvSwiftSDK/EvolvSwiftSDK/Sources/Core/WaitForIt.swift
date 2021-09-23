//
//  WaitForIt.swift
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

class WaitForIt {
    typealias HandlerFunc = ((Any) -> Void)
    
    private var scopedHandlers = OrderedDictionary<AnyHashable, [AnyHashable: [HandlerFunc]]>()
    private var scopedOnceHandlers = OrderedDictionary<AnyHashable, [AnyHashable: [HandlerFunc]]>()
    private var scopedPayloads = OrderedDictionary<AnyHashable, [AnyHashable: Any]>()
    
    static let shared = WaitForIt()
    
    func waitFor(scope: AnyHashable, it: AnyHashable, handler: @escaping HandlerFunc) {
        ensureScope(scope)
        
        if scopedHandlers[scope]?[it] == nil {
            scopedHandlers[scope]?[it] = [handler]
        } else {
            scopedHandlers[scope]?[it]?.append(handler)
        }
        
        if let payload = scopedPayloads[scope]?[it] {
            handler(payload)
        }
    }
    
    func waitOnceFor(scope: AnyHashable, it: AnyHashable, handler: @escaping HandlerFunc) {
        ensureScope(scope)
        
        if let payload = scopedPayloads[scope]?[it] {
            handler(payload)
            return
        }
        
        if scopedOnceHandlers[scope]?[it] == nil {
            scopedOnceHandlers[scope]?[it] = [handler]
        } else {
            scopedOnceHandlers[scope]?[it]?.append(handler)
        }
    }
    
    func emit(scope: AnyHashable, it: AnyHashable, _ other: Any...) {
        ensureScope(scope)
        
        var payload = other
        payload.insert(it, at: 0)
        scopedPayloads[scope]?[it] = payload
        
        scopedOnceHandlers[scope]?[it]?.forEach { $0(payload) }
        scopedOnceHandlers[scope] = nil
        
        scopedHandlers[scope]?[it]?.forEach { $0(payload) }
    }
    
    func destroyScope(scope: AnyHashable) {
        scopedHandlers[scope] = nil
        scopedOnceHandlers[scope] = nil
        scopedPayloads[scope] = nil
    }
    
    private func ensureScope(_ scope: AnyHashable) {
        guard scopedHandlers[scope] == nil else { return }
        
        scopedHandlers[scope] = [:]
        scopedOnceHandlers[scope] = [:]
        scopedPayloads[scope] = [:]
    }
}
