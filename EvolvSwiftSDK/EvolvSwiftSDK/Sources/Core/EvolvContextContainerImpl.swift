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
    var confirmations = [EvolvConfirmation]()
    var contaminations = [EvolvContamination]()
    var events = [EvolvCustomEvent]()
    
    private let scope: AnyHashable
    
    private(set) var activeKeys = CurrentValueSubject<Set<String>, Never>([])
    private(set) var activeEntryKeys = CurrentValueSubject<Set<String>, Never>([])
    private(set) var activeVariants = CurrentValueSubject<Set<String>, Never>([])
    
    private(set) var remoteContext: [String : Any]
    private(set) var localContext: [String : Any]
    private(set) var effectiveGenome = [String : GenomeObject]()
    
    var mergedContextUserInfo: [String : Any] {
        remoteContext.merging(localContext, uniquingKeysWith: { (l, r) in l })
    }
    
    public init(remoteContextUserInfo: [String : Any], localContextUserInfo: [String : Any], scope: AnyHashable) {
        self.localContext = localContextUserInfo
        self.remoteContext = remoteContextUserInfo
        self.scope = scope
    }
    
    func emitInitialValues() {
        remoteContext.forEach { (key, value) in
            guard let encodable = value as? Encodable else { return }
            contextChanged(key: key, value: AnyEncodable(encodable), before: nil)
        }
    }
    
    public func resolve() -> [String: Any] {
        return mergedContextUserInfo
    }
    
    @discardableResult
    public mutating func set(key: String, value: Any, local: Bool) -> Bool {
        guard ((local ? localContext[key] : remoteContext[key]) as? String) != (value as? String) else { return false }
        
        let valueBefore: Any?
        if local {
            valueBefore = localContext[key]
            localContext[key] = value
        } else {
            valueBefore = remoteContext[key]
            remoteContext[key] = value
        }
        
        let updated = self.resolve()
        if let valueBefore = valueBefore {
            WaitForIt.shared.emit(scope: scope, it: CONTEXT_VALUE_CHANGED, ["key" : key,
                                                                            "value" : value,
                                                                            "before" : valueBefore,
                                                                            "local" : local,
                                                                            "updated" : updated])
        } else {
            WaitForIt.shared.emit(scope: scope, it: CONTEXT_VALUE_CHANGED, ["key" : key,
                                                                            "value" : value,
                                                                            "local" : local,
                                                                            "updated" : updated])
        }
        WaitForIt.shared.emit(scope: scope, it: CONTEXT_CHANGED, updated)
        
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
        let activeKeysBefore = self.activeKeys.value
        
        // All active keys
        let activeKeysKeypathSet = Set(activeKeys
                                        .map { $0.keyPath.keyPathString })
        self.activeKeys.send(activeKeysKeypathSet)
        self.contextChanged(key: "keys.active", value: activeKeysKeypathSet, before: activeKeysBefore)
        
        // Active entry keys
        let activeEntryKeysKeyPathSet = filterActiveKeysForEntryKeys(activeKeys: activeKeys)
            .map { $0.keyPath.keyPathString }
            .set()
        self.activeEntryKeys.send(activeEntryKeysKeyPathSet)
        
        // Effective genome
        effectiveGenome = generateEffectiveGenome(activeKeys: activeKeysKeypathSet, configuration: configuration, allocations: allocations)
        
        // Active variants
        let activeVariantsBefore = self.activeVariants.value
        self.activeVariants.send(evaluateActiveVariantKeys(from: effectiveGenome))
        self.contextChanged(key: "variants.active", value: self.activeVariants.value, before: activeVariantsBefore)
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

extension EvolvContextContainerImpl: Hashable, Equatable {
    public static func == (lhs: EvolvContextContainerImpl, rhs: EvolvContextContainerImpl) -> Bool {
        lhs.confirmations == rhs.confirmations &&
        lhs.contaminations == rhs.contaminations &&
        lhs.events == rhs.events &&
        lhs.activeKeys.value == rhs.activeKeys.value &&
        lhs.activeEntryKeys.value == rhs.activeEntryKeys.value &&
        lhs.activeVariants.value == rhs.activeVariants.value &&
        lhs.localContext as? [String : String] == rhs.localContext as? [String : String] &&
        lhs.remoteContext as? [String : String] == rhs.remoteContext as? [String : String] &&
        lhs.effectiveGenome == rhs.effectiveGenome
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(activeKeys.value)
        hasher.combine(activeEntryKeys.value)
        hasher.combine(activeVariants.value)
    }
}

extension EvolvContextContainerImpl {
    func contextChanged<T: Encodable>(key: String, value: Set<T>, before: Set<T>, userInfo: [AnyHashable : Any] = [:], local: Bool = false) {
        contextChanged(key: key, value: Array(value), before: Array(before), userInfo: userInfo, local: local)
    }
    
    func contextChanged<T: Encodable>(key: String, value: [T], before: [T], userInfo: [AnyHashable : Any] = [:], local: Bool = false) {
        if (value.isEmpty && before.isEmpty) { return }
        
        let updated = self.resolve()
        if !before.isEmpty {
            WaitForIt.shared.emit(scope: scope, it: CONTEXT_VALUE_CHANGED, ["key" : key,
                                                                            "value" : value,
                                                                            "before" : before,
                                                                            "local" : local,
                                                                            "updated" : updated])
        } else {
            WaitForIt.shared.emit(scope: scope, it: CONTEXT_VALUE_ADDED, ["key" : key,
                                                                          "value" : value,
                                                                          "local" : local,
                                                                          "updated" : updated])
        }
        WaitForIt.shared.emit(scope: scope, it: CONTEXT_CHANGED, updated)
    }
    
    func contextChanged<T: Encodable>(key: String, value: T, before: T?, userInfo: [AnyHashable : Any] = [:], local: Bool = false) {
        let updated = self.resolve()
        if let before = before {
            WaitForIt.shared.emit(scope: scope, it: CONTEXT_VALUE_CHANGED, ["key" : key,
                                                                            "value" : value,
                                                                            "before" : before,
                                                                            "local" : local,
                                                                            "updated" : updated])
        } else {
            WaitForIt.shared.emit(scope: scope, it: CONTEXT_VALUE_ADDED, ["key" : key,
                                                                          "value" : value,
                                                                          "local" : local,
                                                                          "updated" : updated])
        }
        WaitForIt.shared.emit(scope: scope, it: CONTEXT_CHANGED, updated)
    }
}
