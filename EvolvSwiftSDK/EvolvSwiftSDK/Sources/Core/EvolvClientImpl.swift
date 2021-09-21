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

import Combine

public final class EvolvClientImpl: EvolvClient {
    public var activeKeys: CurrentValueSubject<Set<String>, Never> { evolvStore.activeKeys }
    public var activeVariantKeys: CurrentValueSubject<Set<String>, Never> { evolvStore.activeVariantKeys }
    
    private var initialEvolvContext: EvolvContextContainerImpl
    private let options: EvolvClientOptions
    private let evolvAPI: EvolvAPI
    private var evolvStore: EvolvStore!
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    public static func initialize(options: EvolvClientOptions) -> AnyPublisher<EvolvClient, Error> {
        EvolvClientImpl(options: options, evolvAPI: EvolvHTTPAPI(options: options))
            .initialize()
            .map { $0 as EvolvClient }
            .eraseToAnyPublisher()
    }
    
    /// - Warning: For testing only.
    internal convenience init(options: EvolvClientOptions, evolvStore: EvolvStore, evolvAPI: EvolvAPI) {
        self.init(options: options, evolvAPI: evolvAPI)
        self.evolvStore = evolvStore
    }
    
    private init(options: EvolvClientOptions, evolvAPI: EvolvAPI) {
        self.options = options
        self.evolvAPI = evolvAPI
        self.initialEvolvContext = EvolvContextContainerImpl(remoteContextUserInfo: options.remoteContext, localContextUserInfo: options.localContext)
    }
    
    private func initialize() -> Future<EvolvClientImpl, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            EvolvStoreImpl.initialize(evolvContext: self.initialEvolvContext, evolvAPI: self.evolvAPI)
                .sink(receiveCompletion: { publisherCompletion in
                    promise(publisherCompletion.resultRepresentation(withSuccessCase: self))
                }, receiveValue: { evolvStore in
                    self.evolvStore = evolvStore
                })
                .store(in: &self.cancellables)
        }
    }
    
    public func getActiveKeys() -> Set<String> {
        evolvStore.getActiveKeys()
    }
    
    public func reevaluateContext() {
        evolvStore.reevaluateContext()
    }
    
    public func set(key: String, value: Any, local: Bool) -> Bool {
        evolvStore.set(key: key, value: value, local: local)
    }
    
    public func confirm() {
        let activeEntryKeys = evolvStore.evolvContext.activeEntryKeys.value
        
        let oldConfirmations = evolvStore.evolvContext.confirmations
        let oldConfirmationCids = evolvStore.evolvContext.confirmations.map { $0.cid }
        
        let contaminationCids = evolvStore.evolvContext.contaminations.map { $0.cid }
        
        let activeEids = evolvStore.evolvConfiguration.experiments
            .filter { key in
                activeEntryKeys.contains(where: { key.getKey(at: .init(stringLiteral: $0)) != nil })
            }
            .map { $0.id }
        
        // Filter allocations
        let confirmableAllocations = evolvStore.evolvAllocations.filter { allocation in
            !oldConfirmationCids.contains(allocation.candidateId) &&
            !contaminationCids.contains(allocation.candidateId) &&
            activeEids.contains(allocation.experimentId)
        }
        
        guard !confirmableAllocations.isEmpty else { return }
        
        // Map confirmable allocations to confirmations and update context
        let timestamp = Date()
        let newConfirmationsToSubmit = confirmableAllocations
            .map { EvolvConfirmation(cid: $0.candidateId, uid: $0.userId, eid: $0.experimentId, timeStamp: timestamp)}
        
        evolvStore.evolvContext.confirmations = newConfirmationsToSubmit.appended(with: oldConfirmations)
        
        // Submit events to EvolvAPI
        evolvAPI.submit(events: newConfirmationsToSubmit)
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
        
        evolvStore.evolvContext.contaminations = newContaminationsToSubmit + oldContaminations
        
        // Submit events to EvolvAPI
        evolvAPI.submit(events: newContaminationsToSubmit)
    }
    
    public func get(valueForKey key: String) -> Any? {
        evolvStore.get(valueForKey: key)
    }
    
    public func get<T: Decodable>(decodableValueForKey key: String) -> T? {
        guard let anyValue = self.get(valueForKey: key) as? [AnyHashable : Any],
              let data = try? JSONSerialization.data(withJSONObject: anyValue)
        else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    public func get(subscriptionOnValueForKey key: String) -> AnyPublisher<Any?, Never> {
        evolvStore.get(subscriptionOnValueForKey: key)
            .eraseToAnyPublisher()
    }
    
    public func get<T: Decodable>(subscriptionDecodableOnValueForKey key: String) -> AnyPublisher<T?, Never> {
        evolvStore.get(subscriptionOnValueForKey: key)
            .map { value -> T? in
                guard let anyValue = value as? [AnyHashable : Any],
                      let data = try? JSONSerialization.data(withJSONObject: anyValue)
                else { return nil }
                
                return try? JSONDecoder().decode(T.self, from: data)
            }
            .eraseToAnyPublisher()
    }
}

public struct EvolvClientOptions {
    public let apiVersion: Int
    public let evolvDomain: String
    public let participantID: String
    public let environmentId: String
    public let autoConfirm: Bool
    public let analytics: String
    public let beacon: EvolvBeacon?
    public let bufferEvents: [String : Any]
    public let remoteContext: [String : Any]
    public let localContext: [String : Any]
    
    public init(apiVersion: Int = 1, evolvDomain: String = "participants-stg.evolv.ai", participantID: String = "80658403_1629111253538", environmentId: String = "4a64e0b2ab", autoConfirm: Bool = true, analytics: String = "", beacon: EvolvBeacon? = nil, bufferEvents: [String : Any] = [:], remoteContext: [String : Any] = [:], localContext: [String : Any] = [:]) {
        self.apiVersion = apiVersion
        self.evolvDomain = evolvDomain
        self.participantID = participantID
        self.environmentId = environmentId
        self.autoConfirm = autoConfirm
        self.analytics = analytics
        self.beacon = beacon
        self.bufferEvents = bufferEvents
        self.remoteContext = remoteContext
        self.localContext = localContext
    }
    
}
