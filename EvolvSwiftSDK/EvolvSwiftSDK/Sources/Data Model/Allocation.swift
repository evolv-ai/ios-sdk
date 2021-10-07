//
//  Allocations.swift
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

// MARK: - Allocation
struct Allocation: Codable, Equatable {
    let userId: String
    let experimentId: String
    let candidateId: String
    let genome: GenomeObject?
    let audienceQuery: AudienceQuery?
    let ordinal: Int
    let groupID: String
    let excluded: Bool
    
    private enum CodingKeys: String, CodingKey {
        case userId = "uid"
        case experimentId = "eid"
        case candidateId = "cid"
        case genome
        case audienceQuery = "audience_query"
        case ordinal
        case groupID = "group_id"
        case excluded
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        experimentId = try container.decode(String.self, forKey: .experimentId)
        candidateId = try container.decode(String.self, forKey: .candidateId)
        genome = try container.decode(GenomeObject.self, forKey: .genome)
        audienceQuery = try container.decode(AudienceQuery.self, forKey: .audienceQuery)
        ordinal = try container.decode(Int.self, forKey: .ordinal)
        groupID = try container.decode(String.self, forKey: .groupID)
        excluded = try container.decode(Bool.self, forKey: .excluded)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(candidateId, forKey: .candidateId)
        try container.encode(experimentId, forKey: .experimentId)
        try container.encode(excluded, forKey: .excluded)
        try container.encode(groupID, forKey: .groupID)
        try container.encode(ordinal, forKey: .ordinal)
        try container.encode(userId, forKey: .userId)
    }
}

// MARK: - AudienceQuery
public struct AudienceQuery: Codable, Equatable {
    
}
