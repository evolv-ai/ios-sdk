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

public class EvolvStoreImpl: EvolvStore {
    var evolvConfiguration: Configuration { _evolvConfiguration }
    
    private(set) var evolvAllocations = [Allocation]()
    
    private var _evolvConfiguration: Configuration!
    private var evolvContext: EvolvContext
    private var keyStates: KeyStates
    private var configKeyStates = KeyStates();
    private var genomeKeyStates = KeyStates();
    private var evolvPredicate = EvolvPredicateImpl()
    private let evolvAPI: EvolvAPI
    
    private var reevaluatingContext: Bool = false
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    static func initialize(evolvContext: EvolvContext, evolvAPI: EvolvAPI, keyStates: EvolvStoreImpl.KeyStates = .init()) -> AnyPublisher<EvolvStore, Error> {
        EvolvStoreImpl(evolvContext: evolvContext, evolvAPI: evolvAPI, keyStates: keyStates)
            .initialize()
            .map { $0 as EvolvStore }
            .eraseToAnyPublisher()
    }
    
    private init(evolvContext: EvolvContext, evolvAPI: EvolvAPI, keyStates: EvolvStoreImpl.KeyStates = .init()) {
        self.evolvContext = evolvContext
        self.keyStates = keyStates
        self.evolvAPI = evolvAPI
    }
    
    private func initialize() -> Future<EvolvStoreImpl, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            Publishers.Zip(self.evolvAPI.configuration(),
                           self.evolvAPI.allocations())
                .sink(receiveCompletion: { publishersCompletion in
                    promise(publishersCompletion.resultRepresentation(withSuccessCase: self))
                }, receiveValue: { [weak self] (configuration, allocations) in
                    self?._evolvConfiguration = configuration
                    self?.evolvAllocations = allocations
                })
                .store(in: &self.cancellables)
        }
    }
    
    struct KeyStates {
        var needed = Set<String>()
        var requested = Set<String>()
        var experiments = Array<String>()
    }
    
    private func update(configRequest: Bool, requestedKeys: [String], value: Any) {
        
        keyStates = configRequest ? configKeyStates : genomeKeyStates
        
        reevaluateContext()
    }
    
    private func reevaluateContext() {
        
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
