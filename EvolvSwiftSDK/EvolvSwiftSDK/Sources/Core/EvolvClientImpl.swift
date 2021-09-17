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
    
    private var evolvContext: EvolvContextContainerImpl
    private let options: EvolvClientOptions
    private let evolvAPI: EvolvAPI
    private var evolvStore: EvolvStore!
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    public static func initialize(options: EvolvClientOptions) -> AnyPublisher<EvolvClient, Error> {
        EvolvClientImpl(options: options)
            .initialize()
            .map { $0 as EvolvClient }
            .eraseToAnyPublisher()
    }
    
    private init(options: EvolvClientOptions) {
        self.options = options
        self.evolvAPI = EvolvHTTPAPI(options: options)
        self.evolvContext = EvolvContextContainerImpl(remoteContextUserInfo: options.remoteContext, localContextUserInfo: options.localContext)
    }
    
    private func initialize() -> Future<EvolvClientImpl, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            EvolvStoreImpl.initialize(evolvContext: self.evolvContext, evolvAPI: self.evolvAPI)
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
        return
    }
    
    public func contaminate() {
        return
    }
    
    public func get(value forKey: String) {
        return
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
