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
public struct Configuration: Decodable, EvolvConfig, Equatable {
    let published: Double
    let client: Client
    let experiments: [ExperimentCollection]
    private let _genomeExperiments: [GenomeObject]
    
    enum CodingKeys: String, CodingKey {
        case published = "_published"
        case client = "_client"
        case _genomeExperiments = "_experiments"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        published = try container.decode(Double.self, forKey: .published)
        client = try container.decode(Client.self, forKey: .client)
        _genomeExperiments = try container.decode([GenomeObject].self, forKey: ._genomeExperiments)
        experiments = _genomeExperiments.compactMap { ExperimentCollection(keyValues: $0.value as? [String : Any] ?? [:]) }
    }
}

// MARK: - Client
// TODO: is it really needed for mobile version
public struct Client: Codable, Equatable {
    let browser, device, location, platform: String
}

// MARK: - Experiment
public struct ExperimentCollection: Equatable {
    let predicate: CompoundRule?
    let id: String
    let paused: Bool
    let experiments: [Experiment]
    
    enum CodingKeys: String, CodingKey {
        case predicate = "_predicate"
        case id
        case paused = "_paused"
        case web = "web"
    }
    
    init?(keyValues: [String : Any]) {
        guard let predicateKV = keyValues[CodingKeys.predicate.rawValue] as? [String : Any],
              let id = keyValues[CodingKeys.id.rawValue] as? String,
              let paused = keyValues[CodingKeys.paused.rawValue] as? Bool
        else { return nil }
        
        self.id = id
        self.paused = paused
        
        self.predicate = try? JSONDecoder().decode(CompoundRule.self, fromJSONObject: predicateKV)
        
        self.experiments = keyValues.withoutValues(withKeys: [CodingKeys.predicate, .id, .paused, .web].map { $0.rawValue })
            .map { ($0.key, $0.value) }
            .compactMap { (name, value) in
                let result: Experiment?
                
                do {
                    let experimentData = try JSONSerialization.data(withJSONObject: value, options: [])
                    var experiment = try JSONDecoder().decode(Experiment.self, from: experimentData)
                    
                    experiment.name = name
                    result = experiment
                } catch {
                    print("Evolv: error while deserializing Configuration.json. Error: \(error)")
                    result = nil
                }
                
                return result
            }
    }
    
    init(predicate: CompoundRule, id: String, paused: Bool, experiments: [Experiment]) {
        self.predicate = predicate
        self.id = id
        self.paused = paused
        self.experiments = experiments
    }
}

public struct Experiment: Decodable, Equatable {
    var name: String = ""
    let isEntryPoint: Bool
    let predicate: CompoundRule?
    let values: Bool?
    let initializers: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isEntryPoint = "_is_entry_point"
        case predicate = "_predicate"
        case values = "_values"
        case initializers = "_initializers"
    }
}

// MARK: - Rule
public struct Rule: Codable, Equatable {
    let field: String
    let ruleOperator: RuleOperator
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case field
        case ruleOperator = "operator"
        case value
    }
    
    enum RuleOperator: String, Codable, Equatable {
        case equal = "equal"
        case notEqual = "not_equal"
        case contains = "contains"
        case notContains = "not_contains"
        case exists
        case regexMatch = "regex_match"
        case notRegexMatch = "not_regex_match"
    }
    
    func evaluateRule(value userValue: String?) -> Bool {
        switch self.ruleOperator {
        case .equal:
            return self.value == userValue
        case .notEqual:
            return self.value != userValue
        case .contains:
            return userValue?.contains(self.value) == true
        case .notContains:
            return userValue?.contains(self.value) == false
        case .exists:
            return userValue != nil
        case .regexMatch:
            return userValue?.regexMatch(regex: self.value) == true
        case .notRegexMatch:
            return userValue?.regexMatch(regex: self.value) == false
        }
    }
}


public struct CompoundRule: Decodable, Equatable {
    enum Combinator: String, Decodable {
        case and
        case or
    }
    
    let id: Int?
    let combinator: Combinator
    let rules: [EvolvQuery]
    
    func isActive(in context: [String : Any]) -> Bool {
        switch combinator {
        case .and:
            return rules.allSatisfy { query in
                EvolvQuery.evaluate(query, context: context as? [String : String] ?? [:])
            }
        case .or:
            return rules.contains { query in
                EvolvQuery.evaluate(query, context: context as? [String : String] ?? [:])
            }
        }
    }
}

public enum EvolvQuery: Decodable, Equatable {
    
    case rule(Rule)
    case compoundRule(CompoundRule)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let rule = try? container.decode(Rule.self) {
            self = .rule(rule)
        } else if let compoundRule = try? container.decode(CompoundRule.self) {
            self = .compoundRule(compoundRule)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Mismatched Types")
        }
    }
    
    static func evaluate(_ expression: EvolvQuery, context: [String: String]) -> Bool {
        switch expression {
        case .rule(let rule):
            return rule.evaluateRule(value: context[rule.field])
        case .compoundRule(let compoundRule):
            guard compoundRule.rules.isEmpty == false else { return true }
            
            let results = compoundRule.rules.map({ evaluate($0, context: context) })
            
            switch compoundRule.combinator {
            case .and:
                return !results.contains(false)
            case .or:
                return results.contains(true)
            }
        }
    }
    
}

// MARK: - ExperimentPredicate
public struct ExperimentPredicate: Codable, Equatable {
    let id: Int?
    let combinator: EvolvPredicateCombinator
    let rules: [Rule]?
    
    enum EvolvPredicateCombinator: String, Codable {
        case and = "and"
        case or = "or"
    }
    
    func isActive(in context: [String : Any]) -> Bool {
        switch combinator {
        case .and:
            return rules?.allSatisfy { rule in
                rule.evaluateRule(value: context[rule.field] as? String ?? "")
            } == true
        case .or:
            return rules?.contains { rule in
                rule.evaluateRule(value: context[rule.field] as? String ?? "")
            } == true
        }
    }
}
