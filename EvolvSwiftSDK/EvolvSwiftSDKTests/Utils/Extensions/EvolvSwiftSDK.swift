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
