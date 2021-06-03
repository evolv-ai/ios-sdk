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
struct Allocation: Codable {
    let uid, sid, eid, cid: String
    let genome: Genome
    let audienceQuery: AudienceQuery
    let ordinal: Int
    let groupID: String
    let excluded: Bool

    enum CodingKeys: String, CodingKey {
        case uid, sid, eid, cid, genome
        case audienceQuery = "audience_query"
        case ordinal
        case groupID = "group_id"
        case excluded
    }
}

// MARK: - AudienceQuery
struct AudienceQuery: Codable {
}

// MARK: - Genome
struct Genome: Codable {
    let home: Home
    let next: Next
}

// MARK: - Home
struct Home: Codable {
    let ctaText: String

    enum CodingKeys: String, CodingKey {
        case ctaText = "cta_text"
    }
}

// MARK: - Next
struct Next: Codable {
    let layout: String
}

typealias Allocations = [Allocation]
