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
import Combine

final class EvolvClientImpl: EvolvClient {
    private let scope: AnyHashable
    
    public var activeKeys: AnyPublisher<Set<String>, Never> { evolvStore.activeKeys.eraseToAnyPublisher() }
    public var activeVariantKeys: AnyPublisher<Set<String>, Never> { evolvStore.activeVariantKeys.eraseToAnyPublisher() }
    
    private var initialEvolvContext: EvolvContextContainerImpl
    private let options: EvolvClientOptions
    private let evolvAPI: EvolvAPI
    private var evolvStore: EvolvStore!
    private var contextBeacon: EvolvBeacon
    
    private var cancellables = Set<AnyCancellable>()
    
    public static func initialize(options: EvolvClientOptions) -> AnyPublisher<EvolvClient, Error> {
        EvolvClientImpl(options: options, evolvAPI: EvolvHTTPAPI(options: options), scope: UUID())
            .initialize()
            .map { $0 as EvolvClient }
            .eraseToAnyPublisher()
    }
    
    /// - Warning: For testing only.
    internal convenience init(options: EvolvClientOptions, evolvStore: EvolvStore, evolvAPI: EvolvAPI, scope: AnyHashable) {
        self.init(options: options, evolvAPI: evolvAPI, scope: scope)
        self.evolvStore = evolvStore
    }
    
    init(options: EvolvClientOptions, evolvAPI: EvolvAPI, scope: AnyHashable) {
        self.options = options
        self.evolvAPI = evolvAPI
        self.scope = scope
        self.initialEvolvContext = EvolvContextContainerImpl(remoteContextUserInfo: options.remoteContext, localContextUserInfo: options.localContext, scope: scope)
        self.contextBeacon = options.beacon ?? EvolvBeacon(endPoint: evolvAPI.submit(data:), uid: options.participantID, blockTransmit: options.blockTransmit)
        WaitForIt.shared.emit(scope: scope, it: CONTEXT_INITIALIZED, ["options" : self.options])
    }
    
    func initialize() -> Future<EvolvClientImpl, Error> {
        Future { promise in
            self.waitForOnInitialization()
            
            EvolvStoreImpl.initialize(evolvContext: self.initialEvolvContext, evolvAPI: self.evolvAPI, scope: self.scope)
                .sink(receiveCompletion: { publisherCompletion in
                    promise(publisherCompletion.resultRepresentation(withSuccessCase: self))
                }, receiveValue: { evolvStore in
                    self.evolvStore = evolvStore
                    self.waitForAfterInitialization()
                })
                .store(in: &self.cancellables)
        }
    }
    
    private func waitForOnInitialization() {
        WaitForIt.shared.waitFor(scope: scope, it: CONTEXT_INITIALIZED) { [weak self] payload in
            guard let self = self,
                  let type = payload["it"] as? String
            else { return }
            
            struct Empty: Encodable {}
            self.contextBeacon.emit(type: type, payload: Empty())
        }
        
        WaitForIt.shared.waitFor(scope: scope, it: CONTEXT_VALUE_ADDED) { [weak self] payload in
            guard let self = self,
                  payload["local"] as? Bool == false,
                  let type = payload["it"] as? String,
                  let key = payload["key"] as? String,
                  let value = payload["value"] as? Encodable
            else { return }
            
            self.contextBeacon.emit(type: type, key: key, value: value)
        }
        
        WaitForIt.shared.waitFor(scope: scope, it: CONTEXT_VALUE_CHANGED) { [weak self] payload in
            guard let self = self,
                  payload["local"] as? Bool == false,
                  let type = payload["it"] as? String,
                  let key = payload["key"] as? String,
                  let value = payload["value"] as? Encodable
            else { return }
            
            self.contextBeacon.emit(type: type, key: key, value: value)
        }
        
        WaitForIt.shared.waitFor(scope: scope, it: CONTEXT_VALUE_REMOVED) { [weak self] payload in
            guard let self = self,
                  payload["remote"] as? Bool == true,
                  let type = payload["it"] as? String,
                  let key = payload["key"] as? String
            else { return }
            
            self.contextBeacon.emit(type: type, key: key, value: nil)
        }
    }
    
    private func waitForAfterInitialization() {
        self.confirm()
        WaitForIt.shared.waitFor(scope: scope, it: REQUEST_FAILED) { payload in
            // self?.contaminate(details: , allExperiments: )
        }
        
        WaitForIt.shared.emit(scope: scope, it: EvolvClient_INITIALIZED, ["options":options])
    }
    
    public func getActiveKeys() -> Set<String> {
        evolvStore.getActiveKeys()
    }
    
    public func reevaluateContext() {
        evolvStore.reevaluateContext()
    }
    
    public func set(key: String, value: String, local: Bool) -> Bool {
        evolvStore.set(key: key, value: value, local: local)
    }
    
    public func remove(key: String) -> Bool {
        evolvStore.remove(key: key)
    }
    
    public func confirm() {
        WaitForIt.shared.waitFor(scope: scope, it: EFFECTIVE_GENOME_UPDATED) { [weak self] _ in
            guard let self = self else { return }
            
            let activeEntryKeys = self.evolvStore.evolvContext.activeEntryKeys.value
            
            let oldConfirmations = self.evolvStore.evolvContext.confirmations
            let oldConfirmationCids = self.evolvStore.evolvContext.confirmations.map { $0.cid }
            
            let contaminationCids = self.evolvStore.evolvContext.contaminations.map { $0.cid }
            
            let activeEids = self.evolvStore.evolvConfiguration.experiments
                .filter { key in
                    activeEntryKeys.contains(where: { key.getKey(at: .init(stringLiteral: $0)) != nil })
                }
                .map { $0.id }
            
            // Filter allocations
            let confirmableAllocations = self.evolvStore.evolvAllocations.filter { allocation in
                !oldConfirmationCids.contains(allocation.candidateId) &&
                !contaminationCids.contains(allocation.candidateId) &&
                activeEids.contains(allocation.experimentId)
            }
            
            guard !confirmableAllocations.isEmpty else { return }
            
            // Map confirmable allocations to confirmations and update context
            let timestamp = Date()
            let newConfirmationsToSubmit = confirmableAllocations
                .map { EvolvConfirmation(cid: $0.candidateId, uid: $0.userId, eid: $0.experimentId, timeStamp: timestamp)}
            
            let newContextConfirmations = newConfirmationsToSubmit.appended(with: oldConfirmations)
            self.evolvStore.evolvContext.confirmations = newContextConfirmations
            self.evolvStore.evolvContext.contextChanged(key: "experiments.confirmations", value: newContextConfirmations, before: oldConfirmations)
            
            // Submit events to EvolvAPI
            self.evolvAPI.submit(events: newConfirmationsToSubmit)
            
            WaitForIt.shared.emit(scope: self.scope, it: EvolvClient_CONFIRMED)
        }
    }
    
    public func contaminate(details: EvolvContaminationReason?, allExperiments: Bool) {
        let allocations = evolvStore.evolvAllocations
        guard !allocations.isEmpty else { return }
        
        let oldContaminations = evolvStore.evolvContext.contaminations
        let oldContaminatedCids = oldContaminations.map { $0.cid }
        
        let activeEids = evolvStore.evolvConfiguration.experiments
            .filter { $0.isActive(in: evolvStore.evolvContext.mergedContextUserInfo) }
            .map { $0.id }
        
        // Filter allocations
        let contaminatableAllocations = evolvStore.evolvAllocations.filter { allocation in
            !oldContaminatedCids.contains(allocation.candidateId) &&
            (allExperiments || activeEids.contains(allocation.experimentId))
        }
        guard !contaminatableAllocations.isEmpty else { return }
        
        // Map confirmable allocations to confirmations and update context
        let timeStamp = Date()
        let newContaminationsToSubmit = contaminatableAllocations.map {
            EvolvContamination(cid: $0.candidateId, uid: $0.userId, eid: $0.experimentId, timeStamp: timeStamp, contaminationReason: details)
        }
        
        let newContextContaminations = newContaminationsToSubmit + oldContaminations
        evolvStore.evolvContext.contaminations = newContextContaminations
        evolvStore.evolvContext.contextChanged(key: "experiments.contaminations", value: newContextContaminations, before: oldContaminations)
        
        // Submit events to EvolvAPI
        evolvAPI.submit(events: newContaminationsToSubmit)
        
        WaitForIt.shared.emit(scope: self.scope, it: EvolvClient_CONTAMINATED)
    }
    
    public func get(valueForKey key: String) -> Any? {
        evolvStore.get(valueForKey: key)
    }
    
    public func get<T: Decodable>(decodableValueForKey key: String, type: T.Type) throws -> T? {
        guard let anyValue = self.get(valueForKey: key),
              let data = try? JSONSerialization.data(withJSONObject: anyValue, options: .fragmentsAllowed)
        else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    public func get(subscriptionOnValueForKey key: String) -> AnyPublisher<Any?, Never> {
        evolvStore.get(subscriptionOnValueForKey: key)
            .eraseToAnyPublisher()
    }
    
    public func get<T: Decodable>(subscriptionDecodableOnValueForKey key: String, type: T.Type) -> AnyPublisher<T?, Never> {
        evolvStore.get(subscriptionOnValueForKey: key)
            .map { value -> T? in
                guard let anyValue = value,
                      let data = try? JSONSerialization.data(withJSONObject: anyValue, options: .fragmentsAllowed)
                else { return nil }
                
                return try? JSONDecoder().decode(T.self, from: data)
            }
            .eraseToAnyPublisher()
    }
    
    public func emit<T: Encodable>(eventType: String, metadata: T?, flush: Bool) {
        let event = EvolvCustomEventForSubmission(type: eventType, uid: options.participantID, metadata: metadata)
        
        let oldEvents = evolvStore.evolvContext.events;
        evolvStore.evolvContext.events.append(.init(type: eventType, timestamp: Date()))
        self.evolvStore.evolvContext.contextChanged(key: "events", value: evolvStore.evolvContext.events, before: oldEvents)
        evolvAPI.submit(events: [event])
        
        var userInfo: [String : Any] = ["type" : eventType]
        if let metadata = metadata {
            userInfo["metadata"] = metadata
        }
        WaitForIt.shared.emit(scope: scope, it: EvolvClient_EVENT_EMITTED, userInfo)
    }
    
    public func emit(eventType: String, flush: Bool) {
        emit(eventType: eventType, metadata: nil as String?, flush: flush)
    }
    
    public func on(topic: String, listener: @escaping (([String : Any?]) -> Void)) {
        WaitForIt.shared.waitFor(scope: scope, it: topic, handler: listener)
    }
    
    public func once(topic: String, listener: @escaping (([String : Any?]) -> Void)) {
        WaitForIt.shared.waitOnceFor(scope: scope, it: topic, handler: listener)
    }
}
