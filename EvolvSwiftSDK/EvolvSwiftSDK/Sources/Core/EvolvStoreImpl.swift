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

public struct EvolvStoreImpl: EvolvStore {
    
    private let evolvConfig: EvolvConfig?
    private var initialized: Bool = false
    private var evolvContext: EvolvContext
    private var allocations: [Allocation]
    private var keyStates: KeyStates
    private var version: Int
    private var configKeyStates = KeyStates();
    private var genomeKeyStates = KeyStates();
    
    private var evolvPredicate: EvolvPredicateImpl
    private var reevaluatingContext: Bool = false
    
    

    struct KeyStates {
        var needed = Set<String>()
        var requested = Set<String>()
        var experiments = Array<String>()
    }
    
    private mutating func update(configRequest: Bool, requestedKeys: [String], value: Any) {
        
        keyStates = configRequest ? configKeyStates : genomeKeyStates
        
        reevaluateContext()
    }
    
    private mutating func reevaluateContext() {
        
    }
    
}



extension EvolvStoreImpl {
    
    func expKeyStatesHas(keyStates: KeyStates, stateName: String, key: String, prefix: Bool = false) {
        
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
    
    func getActiveKeys(activeKeys: [String], previousKeys: [String], prefix: [String]) -> [String] {
        
        var result: Array<String> = []
        
        func hasPrefix(key: String) -> Bool {
            return prefix.isEmpty || !prefix.contains(key)
        }
        
        for key in activeKeys {
            if hasPrefix(key: key) {
                result.append(key)
            }
        }
        return result
    }
    
    func activeEntryPoints(entryKeys: [String: Any]) -> [String] {
        var eids: [String] = []
//        TODO: implement function
        
        return []
    }
    
    public func evaluatePredicates(version: Int, context: EvolvContext, config: Configuration) -> [String: Any]{
        
        let result = [String: Any]()
        if (config.experiments.count == 0) {
            return result
        }
        
        // TODO: - Add functionality (lines 172-210)
        return result
    }
    
    public func getActiveAndEntryExperimentKeyStates(results: Array<String>, keyStatesLoaded: [String: Any]) {
        // TODO: - Add functionality (lines 216-240)
    }
    
    public func setActiveAndEntryKeyStates(version: Int, context: EvolvContext, allocations: Allocation,  config: Configuration, configKeyStates: [String: Any]) {
        // TODO: - Add functionality 242-287
    }
    
    
    
    
    
    
}
