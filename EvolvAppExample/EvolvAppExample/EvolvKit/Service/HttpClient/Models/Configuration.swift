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
struct Configuration: Codable {
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
struct Client: Codable {
    let browser, device, location, platform: String
}

// MARK: - Experiment
struct Experiment: Codable {
    let web: Web
    let predicate: ExperimentPredicate
    let buttonColor, ctaText: ButtonColor?
    let id: String
    let paused: Bool
    let home, next: ButtonColor?

    enum CodingKeys: String, CodingKey {
        case web
        case predicate = "_predicate"
        case buttonColor = "button_color"
        case ctaText = "cta_text"
        case id
        case paused = "_paused"
        case home, next
    }
}

// MARK: - ButtonColor
class ButtonColor: Codable {
    let isEntryPoint: Bool
    let predicate: ButtonColorPredicate?
    let values: Bool?
    let initializers: Bool
    let ctaText, layout: ButtonColor?

    enum CodingKeys: String, CodingKey {
        case isEntryPoint = "_is_entry_point"
        case predicate = "_predicate"
        case values = "_values"
        case initializers = "_initializers"
        case ctaText = "cta_text"
        case layout
    }

    init(isEntryPoint: Bool, predicate: ButtonColorPredicate?, values: Bool?, initializers: Bool, ctaText: ButtonColor?, layout: ButtonColor?) {
        self.isEntryPoint = isEntryPoint
        self.predicate = predicate
        self.values = values
        self.initializers = initializers
        self.ctaText = ctaText
        self.layout = layout
    }
}

// MARK: - ButtonColorPredicate
struct ButtonColorPredicate: Codable {
    let combinator: String
    let rules: [Rule]
}

// MARK: - Rule
struct Rule: Codable {
    let field, ruleOperator, value: String

    enum CodingKeys: String, CodingKey {
        case field
        case ruleOperator = "operator"
        case value
    }
}

// MARK: - ExperimentPredicate
struct ExperimentPredicate: Codable {
    let id: Int?
    let combinator: String?
    let rules: [Rule]?
}

// MARK: - Web
struct Web: Codable {
}


// Mockup Model
struct Issue: Codable {
    let id: Int
}



