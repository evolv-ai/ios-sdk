//
//  EvolvBeacon.swift
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

class EvolvBeacon {
    typealias EvolvBeaconEndpoint = ((EvolvBeaconMessage) -> Void)
    
    private let submitToEndpoint: EvolvBeaconEndpoint
    private let uid: String
    private let blockTransmit: Bool
    
    private var awaitingMessagesCancellable: AnyCancellable?
    private var awaitingMessages = CurrentValueSubject<[EvolvBeaconMessagePayload], Never>([])
    
    init(endPoint: @escaping EvolvBeaconEndpoint, uid: String, blockTransmit: Bool) {
        self.submitToEndpoint = endPoint
        self.uid = uid
        self.blockTransmit = blockTransmit
        
        sendAwaitingMessagesOnTimeout()
    }
    
    private func sendAwaitingMessagesOnTimeout() {
        awaitingMessagesCancellable = awaitingMessages
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .filter { !$0.isEmpty }
            .sink { [weak self] messages in
                self?.transmit(messages: messages)
            }
    }
    
    private func transmit(messages: [EvolvBeaconMessagePayload]) {
        defer {
            awaitingMessages.send([])
        }
        
        let body = EvolvBeaconMessage(uid: uid, messages: messages)
        
        submitToEndpoint(body)
    }
    
    func emit<T: Encodable>(type: String, payload: T, flush: Bool = false) {
        awaitingMessages.send(awaitingMessages.value
                                .appended(with: .init(type: type, payload: .init(payload))))
        
        if flush {
            transmit(messages: awaitingMessages.value)
        }
    }
}
