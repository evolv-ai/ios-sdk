//
//  EvolvStore.swift
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
import Combine

public class EvolvStoreImpl: EvolvStore, ObservableObject {
    
}

extension EvolvStoreImpl {
    
    func expKeyStatesHas(keyStates: Any, stateName: String, key: String, prefix: Bool = false) {
        
    }
    
    func setConfigLoadedKeys(keyStates: Any, exp: Any) {
        
    }
    
    func moveKeys(keys: Any, from: Any, to: Any) {
        
    }
    
    func wrapListener(listener: Any) {
        
    }
    
    func getValue(for key: String, with genome: GenomeObject) {
        
    }
    
    func getConfigValue(for key: String, genome: GenomeObject, config: EvolvConfig) {
      
    }
    
    func getValueActive(activeKeys: [String], key: String) -> Bool {
        return activeKeys.contains(key)
    }
    
    func getActiveKeys(activeKeys: [String], previousKeys: [String], prefix: [String]) -> ([String], [String]) {
        
        var result: Array<String> = []
        var previous: Array<String> = []
        
        func hasPrefix(key: String) -> Bool {
            return prefix.isEmpty || !prefix.contains(key)
        }
        
        for key in activeKeys {
            if hasPrefix(key: key) {
                result.append(key)
                previous.append(key)
            }
        }
        
        for key in previousKeys {
            if hasPrefix(key: key) {
                previous.append(key)
            }
        }
        
        return ( result, previous )
    }
    
    func activeEntryPoints(entryKeys: [String: Any]) -> [String] {
        var eids: [String] = []
        
        
        return []
    }
    
    public func evaluatePredicates(version: Int, context: EvolvContext, config: EvolvConfig){
        
    }
    
    
}
