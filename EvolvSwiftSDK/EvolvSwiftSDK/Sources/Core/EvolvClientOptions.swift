//
//  EvolvClientOptions.swift
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

public struct EvolvClientOptions {
    public let apiVersion: Int
    public let evolvDomain: String
    public let participantID: String
    public let environmentId: String
    public let autoConfirm: Bool
    public let analytics: Bool
    public let blockTransmit: Bool
    public let remoteContext: [String : String]
    public let localContext: [String : String]
    let beacon: EvolvBeacon?
    
    public init(apiVersion: Int = 1, evolvDomain: String = "participants-stg.evolv.ai", participantID: String, environmentId: String, autoConfirm: Bool, analytics: Bool, remoteContext: [String : String] = [:], localContext: [String : String] = [:], blockTransmit: Bool = false) {
        self.apiVersion = apiVersion
        self.evolvDomain = evolvDomain
        self.participantID = participantID
        self.environmentId = environmentId
        self.autoConfirm = autoConfirm
        self.analytics = analytics
        self.remoteContext = remoteContext
        self.localContext = localContext
        self.blockTransmit = blockTransmit
        self.beacon = nil
    }
    
    init(apiVersion: Int = 1, evolvDomain: String = "participants-stg.evolv.ai", participantID: String = "80658403_1629111253538", environmentId: String = "4a64e0b2ab", autoConfirm: Bool = true, analytics: Bool = false, remoteContext: [String : String] = [:], localContext: [String : String] = [:], blockTransmit: Bool = false, beacon: EvolvBeacon) {
        self.apiVersion = apiVersion
        self.evolvDomain = evolvDomain
        self.participantID = participantID
        self.environmentId = environmentId
        self.autoConfirm = autoConfirm
        self.analytics = analytics
        self.remoteContext = remoteContext
        self.localContext = localContext
        self.blockTransmit = blockTransmit
        self.beacon = beacon
    }
}
