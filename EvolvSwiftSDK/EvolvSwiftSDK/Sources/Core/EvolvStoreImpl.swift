//
//  EvolvStoreImpl.swift
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
    private(set) var activeKeys = CurrentValueSubject<Set<String>, Never>([])
    
    private var _evolvConfiguration: Configuration!
    private var evolvContext: EvolvContextContainer
    private var keyStates: KeyStates
    private var configKeyStates = KeyStates();
    private var genomeKeyStates = KeyStates();
    private let evolvAPI: EvolvAPI
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    static func initialize(evolvContext: EvolvContextContainer, evolvAPI: EvolvAPI, keyStates: EvolvStoreImpl.KeyStates = .init()) -> AnyPublisher<EvolvStore, Error> {
        EvolvStoreImpl(evolvContext: evolvContext, evolvAPI: evolvAPI, keyStates: keyStates)
            .initialize()
            .map { $0 as EvolvStore }
            .eraseToAnyPublisher()
    }
    
    private init(evolvContext: EvolvContextContainer, evolvAPI: EvolvAPI, keyStates: EvolvStoreImpl.KeyStates = .init()) {
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
                    self?.reevaluateContext()
                })
                .store(in: &self.cancellables)
        }
    }
    
    struct KeyStates {
        var needed = Set<String>()
        var requested = Set<String>()
        var experiments = Array<String>()
    }
    
    func isActive(key: String) -> Bool {
        getActiveKeys().contains(key)
    }
    
    func getActiveKeys() -> Set<String> {
        activeKeys.value
    }
    
    func reevaluateContext() {
        activeKeys.send(evolvConfiguration.evaluateActiveKeys(in: evolvContext.mergedContextUserInfo))
    }
    
    func set(key: String, value: Any, local: Bool) -> Bool {
        let isContextChanged = evolvContext.set(key: key, value: value, local: local)
        
        guard isContextChanged else { return false }
        
        reevaluateContext()
        
        return true
    }
    
    private func update(configRequest: Bool, requestedKeys: [String], value: Any) {
        keyStates = configRequest ? configKeyStates : genomeKeyStates
        
        reevaluateContext()
    }
    
    private func evaluatePredicates(context: EvolvContextContainer, configuration: Configuration) {
        
    }
    
    private func isActive(experimentCollection: Experiment) -> Bool {
        experimentCollection.predicate?.isActive(in: evolvContext.mergedContextUserInfo) ?? true
    }
    
    private func isActive(experiment: ExperimentKey) -> Bool {
        experiment.predicate?.isActive(in: evolvContext.mergedContextUserInfo) ?? true
    }
    
    private func evaluateFilter(userValue: String, against rule: Rule) {
        
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
        return []
    }
    
    func evaluatePredicates(version: Int, context: EvolvContextContainer, config: Configuration) -> [String: Any]{
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
    
    func setActiveAndEntryKeyStates(version: Int, context: EvolvContextContainer, allocations: Allocation,  config: Configuration, configKeyStates: [String: Any]) {
        // TODO: - Add functionality 242-287
    }
}
