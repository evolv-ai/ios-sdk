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

class EvolvStoreImpl: EvolvStore {
    var activeKeys: CurrentValueSubject<Set<String>, Never> { evolvContext.activeKeys }
    var activeVariantKeys: CurrentValueSubject<Set<String>, Never> { evolvContext.activeVariants }
    
    var evolvConfiguration: Configuration { _evolvConfiguration }
    var evolvContext: EvolvContextContainerImpl
    
    private(set) var evolvAllocations = [Allocation]()
    
    private var scope: AnyHashable
    
    private var _evolvConfiguration: Configuration!
    private var keyStates: KeyStates
    private var configKeyStates = KeyStates();
    private var genomeKeyStates = KeyStates();
    private let evolvAPI: EvolvAPI
    
    private var genomeValueSubjects = [String : CurrentValueSubject<Any?, Never>]()
    
    private var cancellables = Set<AnyCancellable>()
    
    static func initialize(evolvContext: EvolvContextContainerImpl, evolvAPI: EvolvAPI, scope: AnyHashable, keyStates: EvolvStoreImpl.KeyStates = .init()) -> AnyPublisher<EvolvStore, Error> {
        EvolvStoreImpl(evolvContext: evolvContext, evolvAPI: evolvAPI, scope: scope, keyStates: keyStates)
            .initialize()
            .map { $0 as EvolvStore }
            .eraseToAnyPublisher()
    }
    
    private init(evolvContext: EvolvContextContainerImpl, evolvAPI: EvolvAPI, scope: AnyHashable, keyStates: EvolvStoreImpl.KeyStates = .init()) {
        self.evolvContext = evolvContext
        self.keyStates = keyStates
        self.evolvAPI = evolvAPI
        self.scope = scope
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
                    self?.evolvContext.contextChanged(key: "experiments.allocations", value: allocations, before: [])
                    self?.evolvContext.emitInitialValues()
                    self?.reevaluateContext()
                })
                .store(in: &self.cancellables)
        }
    }
    
    deinit {
        WaitForIt.shared.emit(scope: self.scope, it: STORE_DESTROYED)
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
        evolvContext.getActiveKeys()
    }
    
    func reevaluateContext() {
        evolvContext.reevaluateContext(with: evolvConfiguration, allocations: evolvAllocations)
        
        WaitForIt.shared.emit(scope: scope, it: EFFECTIVE_GENOME_UPDATED, evolvContext.effectiveGenome)
        
        updateGenomeValueSubjects()
    }
    
    func set(key: String, value: Any, local: Bool) -> Bool {
        let isContextChanged = evolvContext.set(key: key, value: value, local: local)
        
        guard isContextChanged else { return false }
        
        reevaluateContext()
        
        return true
    }
    
    func remove(key: String) -> Bool {
        let isContextChanged = evolvContext.remove(key: key)
        
        guard isContextChanged else { return false }
        
        reevaluateContext()
        
        return true
    }
    
    func get(valueForKey key: String) -> Any? {
        guard activeKeys.value.contains(key) else { return nil }
        
        if let subject = genomeValueSubjects[key] {
            return subject.value
        } else {
            genomeValueSubjects[key] = CurrentValueSubject(nil)
            
            updateGenomeValueSubjects()
            
            return genomeValueSubjects[key]?.value
        }
    }
    
    func get(subscriptionOnValueForKey key: String) -> CurrentValueSubject<Any?, Never> {
        if let subject = genomeValueSubjects[key] {
            return subject
        }
        
        let newSubject: CurrentValueSubject<Any?, Never> = CurrentValueSubject(nil)
        genomeValueSubjects[key] = newSubject
        
        updateGenomeValueSubjects()
        
        return newSubject
    }
    
    func saveEventToContext(name: String, timeStamp: Date) {
        evolvContext.events.append(.init(type: name, timestamp: timeStamp))
    }
    
    private func updateGenomeValueSubjects() {
        genomeValueSubjects.forEach { (key, subject) in
            var genome: GenomeObject?
            for allocation in evolvAllocations {
                genome = try? allocation.genome.parse(forKey: key)
                if genome != nil { break }
            }
            
            let newValue = activeKeys.value.contains(key) ? genome?.rawValue : nil
            
            subject.send(newValue)
        }
    }
}
