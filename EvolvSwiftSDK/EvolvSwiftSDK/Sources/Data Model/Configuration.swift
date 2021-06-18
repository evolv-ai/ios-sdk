//
//  Configuration.swift
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

// MARK: - Configuration
public struct Configuration: Codable {
    let published: Double
    let client: Client
    let experiments: [Experiment]

    enum CodingKeys: String, CodingKey {
        case published = "_published"
        case client = "_client"
        case experiments = "_experiments"
    }
}

// MARK: - Client
// TODO: is it really needed for mobile version
public struct Client: Codable {
    let browser, device, location, platform: String
}

// MARK: - Experiment
public struct Experiment: Codable {
    let web: Web
    let predicate: ExperimentPredicate
    let id: String
    let paused: Bool

    enum CodingKeys: String, CodingKey {
        case web
        case predicate = "_predicate"
        case id
        case paused = "_paused"
    }
}

// MARK: - Rule
public struct Rule: Codable {
    let field, ruleOperator, value: String

    enum CodingKeys: String, CodingKey {
        case field
        case ruleOperator = "operator"
        case value
    }
}

// MARK: - Web
public struct Web: Codable {

}


// MARK: - ExperimentPredicate
public struct ExperimentPredicate: Codable {
    let id: Int?
    let combinator: String?
    let rules: [Rule]?
}


