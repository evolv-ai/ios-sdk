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
    let experiments: [Experiment]
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        published = try container.decode(Double.self, forKey: .init(stringValue: "_published"))
        client = try container.decode(Client.self, forKey: .init(stringValue: "_client"))
        experiments = try container.decode([Experiment].self, forKey: .init(stringValue: "_experiments"))
    }
}

// MARK: - Client
// TODO: is it really needed for mobile version
public struct Client: Codable, Equatable {
    let browser, device, location, platform: String
}

// MARK: - Experiment
public struct Experiment: Decodable, Equatable {
    let predicate: CompoundRule?
    let id: String
    let paused: Bool
    let experimentKeys: [ExperimentKey]
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        predicate = try? container.decode(CompoundRule.self, forKey: .init(stringValue: "_predicate"))
        id = try container.decode(String.self, forKey: .init(stringValue: "id"))
        paused = try container.decode(Bool.self, forKey: .init(stringValue: "_paused"))

        experimentKeys = container.allKeys
            .compactMap { try? container.decode(ExperimentKey.self, forKey: $0) }
            .sorted { $0.keyPath.keyPathString < $1.keyPath.keyPathString }
    }
    
    init(predicate: CompoundRule?, id: String, paused: Bool, experimentKeys: [ExperimentKey]) {
        self.predicate = predicate
        self.id = id
        self.paused = paused
        self.experimentKeys = experimentKeys
    }
    
    func isActive(in context: [String : Any]) -> Bool {
        predicate?.isActive(in: context) ?? true
    }
}

public struct ExperimentKey: Decodable, Equatable, Hashable {
    let keyPath: ExperimentKeyPath
    let isEntryPoint: Bool
    let predicate: CompoundRule?
    let values: Bool?
    let initializers: Bool
    let subKeys: [ExperimentKey]
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isEntryPoint = try container.decode(Bool.self, forKey: .init(stringValue: "_is_entry_point"))
        predicate = try? container.decode(CompoundRule.self, forKey: .init(stringValue: "_predicate"))
        values = try? container.decode(Bool.self, forKey: .init(stringValue: "_values"))
        initializers = try container.decode(Bool.self, forKey: .init(stringValue: "_initializers"))
        
        let keyPath = container.codingPath
            .dropFirst(2)
            .map { $0.stringValue }
        self.keyPath = ExperimentKeyPath(keyPath: keyPath)
        
        subKeys = container.allKeys
            .compactMap { try? container.decode(ExperimentKey.self, forKey: $0) }
            .sorted { $0.keyPath.keyPathString < $1.keyPath.keyPathString }
    }
    
    init(keyPath: ExperimentKey.ExperimentKeyPath, isEntryPoint: Bool, predicate: CompoundRule?, values: Bool?, initializers: Bool, subKeys: [ExperimentKey]) {
        self.keyPath = keyPath
        self.isEntryPoint = isEntryPoint
        self.predicate = predicate
        self.values = values
        self.initializers = initializers
        self.subKeys = subKeys
    }
    
    func isActive(in context: [String : Any]) -> Bool {
        predicate?.isActive(in: context) ?? true
    }
    
    struct ExperimentKeyPath: Equatable, Hashable {
        let keyPath: [String]
        
        var name: String { keyPath.last ?? "" }
        var keyPathString: String { String(keyPath.reduce("") { $0 + "." + $1 }.dropFirst()) }
    }
}

// MARK: - Rule
public struct Rule: Codable, Equatable, Hashable {
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


public struct CompoundRule: Decodable, Equatable, Hashable {
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

public enum EvolvQuery: Decodable, Equatable, Hashable {
    
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

extension Configuration {
    func evaluateActiveKeys(in context: [String : Any]) -> Set<ExperimentKey> {
        let activeKeys = experiments.flatMap {
            evaluateActiveKeys(from: $0, in: context)
        }
        
        return Set(activeKeys)
    }
    
    private func evaluateActiveKeys(from experiment: Experiment, in context: [String : Any]) -> [ExperimentKey] {
        guard experiment.isActive(in: context) else { return [] }
        
        return experiment.experimentKeys.flatMap {
            evaluateActiveKeys(from: $0, in: context)
        }
    }
    
    private func evaluateActiveKeys(from experimentKey: ExperimentKey, in context: [String : Any]) -> [ExperimentKey] {
        var keys = [ExperimentKey]()
        
        guard experimentKey.isActive(in: context) else { return keys }
        
        keys.append(experimentKey)
        
        return experimentKey.subKeys.flatMap {
            evaluateActiveKeys(from: $0, in: context)
        } + keys
    }
}
