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

import Combine

public struct EvolvContextContainerImpl: EvolvContextContainer {
    private(set) var activeKeys = CurrentValueSubject<Set<String>, Never>([])
    
    private(set) var remoteContext: EvolvContext
    private(set) var localContext: EvolvContext
    
    var mergedContextUserInfo: [String : Any] {
        remoteContext.userInfo.merging(localContext.userInfo, uniquingKeysWith: { (l, r) in l })
    }
    
    public init(remoteContextUserInfo: [String : Any], localContextUserInfo: [String : Any]) {
        self.localContext = EvolvContextImpl(userInfo: localContextUserInfo)
        self.remoteContext = EvolvContextImpl(userInfo: remoteContextUserInfo)
    }
    
    public func resolve() -> [String: Any] {
        return mergedContextUserInfo
    }
    
    @discardableResult
    public mutating func set(key: String, value: Any, local: Bool) -> Bool {
        guard ((local ? localContext.userInfo[key] : remoteContext.userInfo[key]) as? String) != (value as? String) else { return false }
        
        if local {
            localContext.userInfo[key] = value
        } else {
            remoteContext.userInfo[key] = value
        }
        
        return true
    }
    
    func mergeContext(localContext: [String : Any], remoteContext: [String : Any]) -> [String : Any] {
        return remoteContext.merging(localContext) { (current, _) in current }
    }
    
    func getActiveKeys() -> Set<String> {
        activeKeys.value
    }
    
    func reevaluateContext(with configuration: Configuration) {
        activeKeys.send(configuration.evaluateActiveKeys(in: mergedContextUserInfo))
    }
}
