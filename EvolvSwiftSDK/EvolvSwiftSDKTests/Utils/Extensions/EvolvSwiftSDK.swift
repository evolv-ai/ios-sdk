//
//  EvolvSwiftSDK.swift
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
@testable import EvolvSwiftSDK

extension EvolvBeaconMessage: Equatable, Hashable {
    public static func == (lhs: EvolvBeaconMessage, rhs: EvolvBeaconMessage) -> Bool {
        lhs.uid == rhs.uid &&
        lhs.messages == rhs.messages
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}

extension EvolvBeaconMessagePayload: Equatable {
    public static func == (lhs: EvolvBeaconMessagePayload, rhs: EvolvBeaconMessagePayload) -> Bool {
        lhs.type == rhs.type &&
        lhs.payload == rhs.payload
    }
}

extension AnyEncodable: Equatable {
    public static func == (lhs: AnyEncodable, rhs: AnyEncodable) -> Bool {
        let lhs = lhs._object
        let rhs = rhs._object
        
        if let lhs = lhs as? AnyEncodable, let rhs = rhs as? AnyEncodable {
            return lhs == rhs
        } else if let lhs = lhs as? SimpleKVStorage, let rhs = rhs as? SimpleKVStorage {
            return lhs == rhs
        } else if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs == rhs
        } else if let lhs = lhs as? Data, let rhs = rhs as? Data {
            return lhs == rhs
        } else if let lhs = lhs as? [Allocation], let rhs = rhs as? [Allocation] {
            return lhs == rhs
        } else if let lhs = lhs as? [String], let rhs = rhs as? [String] {
            return lhs.set() == rhs.set()
        } else if let lhs = lhs as? Encodable, let rhs = rhs as? Encodable {
            let encoder = JSONEncoder()
            let lhs = try! encoder.encode(AnyEncodable(lhs))
            let rhs = try! encoder.encode(AnyEncodable(rhs))
            return lhs == rhs
        }
        
        return false
    }
}

extension SimpleKVStorage: Equatable {
    public static func == (lhs: SimpleKVStorage, rhs: SimpleKVStorage) -> Bool {
        lhs.key == rhs.key &&
        lhs.value == rhs.value
    }
}

extension EvolvClientOptions: Encodable {
    public func encode(to encoder: Encoder) throws {
        enum CodingKeys: String, CodingKey {
            case apiVersion
            case evolvDomain
            case participantID
            case environmentId
            case autoConfirm
            case analytics
            case blockTransmit
            case bufferEvents
            case remoteContext
            case localContext
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(apiVersion, forKey: .apiVersion)
        try container.encode(evolvDomain, forKey: .evolvDomain)
        try container.encode(participantID, forKey: .participantID)
        try container.encode(environmentId, forKey: .environmentId)
        try container.encode(autoConfirm, forKey: .autoConfirm)
        try container.encode(analytics, forKey: .analytics)
        try container.encode(blockTransmit, forKey: .blockTransmit)
        try container.encode(remoteContext, forKey: .remoteContext)
        try container.encode(localContext, forKey: .localContext)
    }
}
