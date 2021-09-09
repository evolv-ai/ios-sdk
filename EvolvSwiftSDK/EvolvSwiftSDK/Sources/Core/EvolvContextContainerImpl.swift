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
    private(set) var activeEntryKeys = CurrentValueSubject<Set<String>, Never>([])
    private(set) var activeVariants = CurrentValueSubject<Set<String>, Never>([])
    
    private(set) var remoteContext: EvolvContext
    private(set) var localContext: EvolvContext
    private(set) var effectiveGenome = [String : GenomeObject]()
    
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
    
    mutating func reevaluateContext(with configuration: Configuration, allocations: [Allocation]) {
        let activeKeys = configuration.evaluateActiveKeys(in: mergedContextUserInfo)
        
        // All active keys
        let activeKeysKeypathSet = Set(activeKeys
                                            .map { $0.keyPath.keyPathString })
        self.activeKeys.send(activeKeysKeypathSet)
        
        // Active entry keys
        let activeEntryKeysKeyPathSet = filterActiveKeysForEntryKeys(activeKeys: activeKeys)
            .map { $0.keyPath.keyPathString }
            .set()
        self.activeEntryKeys.send(activeEntryKeysKeyPathSet)
        
        // Effective genome
        effectiveGenome = generateEffectiveGenome(activeKeys: activeKeysKeypathSet, configuration: configuration, allocations: allocations)
        
        // Active variant keys
        self.activeVariants.send(evaluateActiveVariantKeys(from: effectiveGenome))
    }
    
    private func generateEffectiveGenome(activeKeys: Set<String>, configuration: Configuration, allocations: [Allocation]) -> [String : GenomeObject] {
        let expAllocations = mapExperimentsToAllocations(experiments: configuration.experiments, allocations: allocations)
        
        return expAllocations.map { generateEffectiveGenome(activeKeys: activeKeys, experiment: $0, allocation: $1) }
            .flatMap { $0 }
            .reduce([String : GenomeObject](), { (dict, tuple) in
                var nextDict = dict
                nextDict.updateValue(tuple.1, forKey: tuple.0)
                return nextDict
            })
    }
    
    private func mapExperimentsToAllocations(experiments: [Experiment], allocations: [Allocation]) -> [(Experiment, Allocation)] {
        return experiments.compactMap { experiment in
            guard let allocation = allocations.first(where: { $0.experimentId == experiment.id }) else { return nil }
            return (experiment, allocation)
        }
    }
    
    private func generateEffectiveGenome(activeKeys: Set<String>, experiment: Experiment, allocation: Allocation) -> [String : GenomeObject] {
        var dict = [String : GenomeObject]()
        
        activeKeys.forEach { key in
            guard let genomeForKey = try? allocation.genome.parse(forKey: key) else { return }
            
            dict[key] = genomeForKey
        }
        
        return dict
    }
    
    private func evaluateActiveVariantKeys(from effectiveGenome: [String : GenomeObject]) -> Set<String> {
        effectiveGenome.map { key, genome in
            let valueHashCode = genome.jsonStringify.evolvHashCode()
            return "\(key):\(valueHashCode)"
        }.set()
    }
    
    private func filterActiveKeysForEntryKeys(activeKeys: Set<ExperimentKey>) -> Set<ExperimentKey> {
        func findEntryKey(key: ExperimentKey) -> ExperimentKey? {
            if key.isEntryPoint {
                return key
            } else {
                return key.subKeys.first { findEntryKey(key: $0) != nil }
            }
        }
        
        return activeKeys
            .compactMap { findEntryKey(key: $0) }
            .flatMap { $0.subKeys.appended(with: $0) }
            .set()
            .intersection(activeKeys)
    }
}
