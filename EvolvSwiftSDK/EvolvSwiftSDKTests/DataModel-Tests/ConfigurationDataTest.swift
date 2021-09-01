//
//  ConfigurationDataTest.swift
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


import XCTest
@testable import EvolvSwiftSDK

class ConfigurationDataTest: XCTestCase {
    var configurationData: Configuration!
    
    override func setUpWithError() throws {
        let pathString = Bundle(for: type(of: self)).path(forResource: "configuration.json", ofType: nil)
        
        let json = try String(contentsOfFile: pathString!, encoding: .utf8)
        
        let jsonData = json.data(using: .utf8)!
        
        configurationData = try JSONDecoder().decode(Configuration.self, from: jsonData)
    }
    
    override func tearDownWithError() throws {
        configurationData = nil
    }
    
    func testCanParseConfigurationJSONFile() throws {
        XCTAssertEqual("desktop", configurationData.client.device)
        XCTAssertEqual("BY", configurationData.client.location)
        XCTAssertEqual(156, configurationData.experiments[1].predicate?.id)
        XCTAssertEqual("ff01d1516c", configurationData.experiments[0].id)
        XCTAssertEqual(false, configurationData.experiments[0].paused)
    }
    
    func testNestedRulesDecoded() throws {
        let predicate = """
        {
          "id": 156,
          "combinator": "and",
          "rules": [
            {
              "field": "location",
              "operator": "equal",
              "value": "UA"
            },
            {
              "combinator": "or",
              "rules": [
                {
                  "field": "location",
                  "operator": "equal",
                  "value": "UA"
                },
                {
                  "field": "Student",
                  "operator": "contains",
                  "value": "High_school"
                }
              ]
            }
          ]
        }
        """.data(using: .utf8)!
        let expectedDecodedPredicate = CompoundRule(id: 156, combinator: .and, rules: [
                                                        .rule(.init(field: "location", ruleOperator: .equal, value: "UA")),
                                                        .compoundRule(.init(id: nil, combinator: .or, rules: [
                                                                                .rule(.init(field: "location", ruleOperator: .equal, value: "UA")),
                                                                                .rule(.init(field: "Student", ruleOperator: .contains, value: "High_school"))]))])
        
        let decodedPredicate = try JSONDecoder().decode(CompoundRule.self, from: predicate)
        
        XCTAssertEqual(decodedPredicate, expectedDecodedPredicate)
    }
    
    func testCompoundRulesDecoded() throws {
        struct MockRulesContainer: Decodable, Equatable {
            let _predicate: CompoundRule
        }
        
        let predicateJSON = """
        {
            "_predicate": {
                "combinator": "or",
                "rules": [
                    {
                        "field": "device",
                        "operator": "equal",
                        "value": "mobile"
                    },
                    {
                        "combinator": "or",
                        "rules": [
                            {
                                "field": "location",
                                "operator": "equal",
                                "value": "UA"
                            },
                            {
                                "field": "Student",
                                "operator": "contains",
                                "value": "High_school"
                            }
                        ]
                    },
                    {
                        "field": "age",
                        "operator": "equal",
                        "value": "30"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let expectedPredicate = MockRulesContainer(_predicate: .init(id: nil,
                                                                     combinator: .or,
                                                                     rules: [
                                                                        .rule(.init(field: "device", ruleOperator: .equal, value: "mobile")),
                                                                        .compoundRule(.init(id: nil,
                                                                                            combinator: .or,
                                                                                            rules: [
                                                                                                .rule(.init(field: "location",
                                                                                                            ruleOperator: .equal,
                                                                                                            value: "UA")),
                                                                                                .rule(.init(field: "Student",
                                                                                                            ruleOperator: .contains,
                                                                                                            value: "High_school"))])),
                                                                        .rule(.init(field: "age",
                                                                                    ruleOperator: .equal,
                                                                                    value: "30"))]))
        
        let actualPredicate = try JSONDecoder().decode(MockRulesContainer.self, from: predicateJSON)
        
        XCTAssertEqual(expectedPredicate, actualPredicate)
    }
    
    func testExperimentWithSubkeysDecoded() throws {
        struct MockExperimentContainer: Decodable, Equatable {
            let _experiments: [Experiment]
        }
        
        let experimentJSON = """
        {
          "_experiments": [
            {
              "web": {},
              "_predicate": {
                "combinator": "and",
                "rules": [
                  {
                    "field": "color",
                    "operator": "equal",
                    "value": "blue"
                  }
                ]
              },
              "home": {
                "_is_entry_point": true,
                "_predicate": {
                  "combinator": "and",
                  "rules": [
                    {
                      "field": "view",
                      "operator": "equal",
                      "value": "home"
                    }
                  ]
                },
                "cta_text": {
                  "_is_entry_point": false,
                  "_predicate": {
                    "combinator": "and",
                    "rules": [
                      {
                        "field": "home",
                        "operator": "contains",
                        "value": "none"
                      }
                    ]
                  },
                  "font": {
                    "_is_entry_point": false,
                    "_initializers": true,
                    "_values": true,
                    "_predicate": {
                      "combinator": "or",
                      "rules": [
                        {
                          "field": "age",
                          "operator": "not_equal",
                          "value": "25"
                        },
                        {
                          "field": "location",
                          "operator": "not_equal",
                          "value": "UK"
                        }
                      ]
                    }
                  },
                  "_values": true,
                  "_initializers": true
                },
                "background": {
                  "_is_entry_point": false,
                  "_predicate": null,
                  "_values": true,
                  "_initializers": true
                },
                "_initializers": false
              },
              "id": "ff01d1516c",
              "_paused": false
            }
          ]
        }
        """.data(using: .utf8)!
        
        let experiment = Experiment(predicate: .init(id: nil, combinator: .and, rules: [
                                                        .rule(.init(field: "color", ruleOperator: .equal, value: "blue"))]),
                                    id: "ff01d1516c",
                                    paused: false,
                                    experimentKeys: [
                                        .init(keyPath: .init(keyPath: ["home"]),
                                              isEntryPoint: true,
                                              predicate: .init(id: nil, combinator: .and, rules: [.rule(.init(field: "view", ruleOperator: .equal, value: "home"))]),
                                              values: nil,
                                              initializers: false,
                                              subKeys: [
                                                .init(keyPath: .init(keyPath: ["home", "background"]),
                                                      isEntryPoint: false,
                                                      predicate: nil,
                                                      values: true,
                                                      initializers: true,
                                                      subKeys: []),
                                                .init(keyPath: .init(keyPath: ["home", "cta_text"]),
                                                      isEntryPoint: false,
                                                      predicate:
                                                        .init(id: nil,
                                                              combinator: .and,
                                                              rules: [.rule(.init(field: "home", ruleOperator: .contains, value: "none"))]),
                                                      values: true,
                                                      initializers: true,
                                                      subKeys: [
                                                        .init(keyPath: .init(keyPath: ["home", "cta_text", "font"]),
                                                              isEntryPoint: false,
                                                              predicate: .init(id: nil, combinator: .or,
                                                                               rules: [.rule(.init(field: "age", ruleOperator: .notEqual, value: "25")),
                                                                                       .rule(.init(field: "location", ruleOperator: .notEqual, value: "UK"))]),
                                                              values: true,
                                                              initializers: true,
                                                              subKeys: [])]),
                                              ])])
        let expectedDecodedExperiment = MockExperimentContainer(_experiments: [experiment])
        
        let actualDecodedExperiment = try JSONDecoder().decode(MockExperimentContainer.self, from: experimentJSON)

        XCTAssertEqual(actualDecodedExperiment, expectedDecodedExperiment)
    }
}
