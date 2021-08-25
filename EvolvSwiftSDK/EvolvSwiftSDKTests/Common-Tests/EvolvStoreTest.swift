//
//  EvolvStoreTest.swift
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

class EvolvStoreTest: XCTestCase {
    
    var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        jsonDecoder = JSONDecoder()
    }

    override func tearDown() {
        super.tearDown()
        
        jsonDecoder = nil
    }

    func testSetKeysInContext() {
        
        let remoteContext: [String: Any] = ["test_key" : "test_value"]
        let localContext: [String: Any] = [:]
        
        var context = EvolvContextImpl(remoteContext: remoteContext, localContext: localContext)
        
        let evolvContext = context.set(key: "new_key", value: "new_value")
        
        XCTAssertNotNil(evolvContext)
        XCTAssertEqual(evolvContext["new_key"] as? String, "new_value")
        XCTAssertEqual(evolvContext["test_key"] as? String, "test_value")
    }
    
    func testContextIsNotEmpty() {
        let remoteContext: [String: Any] = ["test_key1" : "test_value1"]
        let localContext: [String: Any] = ["test_key2" : "test_value2"]
        
        let context = EvolvContextImpl(remoteContext: remoteContext, localContext: localContext)
        
        XCTAssertEqual(remoteContext.isEmpty, false)
        XCTAssertEqual(localContext.isEmpty, false)
    }
    
    func testMergeContext() {
        let remoteContext: [String: Any] = ["test_key1" : "test_value1"]
        let localContext: [String: Any] = ["test_key2" : "test_value2"]
        
        let context = EvolvContextImpl(remoteContext: remoteContext, localContext: localContext)
        
        let evolvContext = context.mergeContext(localContext: localContext, remoteContext: remoteContext)
        
        XCTAssertNotNil(evolvContext)
        XCTAssertEqual(evolvContext["test_key2"] as? String, "test_value2")
        XCTAssertEqual(evolvContext["test_key1"] as? String, "test_value1")
    }
    
    func testKeysInKeyStates() {
        
        typealias KeyStates = GenomeObject
        
        var keyStates: KeyStates?
        
        let rules = [Rule(field: "Age", ruleOperator: Rule.RuleOperator(rawValue: "equal")!, value: "26")]
        
        let experimentPredicate = ExperimentPredicate(id: 174, combinator: .and, rules: rules)
        
//        let experiments = ExperimentCollection(predicate: experimentPredicate, id: "47d857cd5e", paused: false, experiments: [])
        
//        let keyStates: [String: Any] = ["experiments":
//                                            [Array(["123":
//                                                        [Array(["loaded":
//                                                                    Set(arrayLiteral: "jim.horn", "bob.boe", "joe.tom")
//                                                              ])
//                                                        ]
//                                                 ])
//                                            ]
//                                        ]
        
        var jsonData = """
                    {
                        "web": {},
                        "_predicate": {},
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
                                "_predicate": null,
                                "_values": true,
                                "_initializers": true
                            },
                            "_initializers": true
                        },
                        "next": {
                            "_is_entry_point": false,
                            "_predicate": {
                                "combinator": "and",
                                "rules": [
                                    {
                                        "field": "view",
                                        "operator": "equal",
                                        "value": "next"
                                    }
                                ]
                            },
                            "layout": {
                                "_is_entry_point": false,
                                "_predicate": null,
                                "_values": true,
                                "_initializers": true
                            },
                            "_initializers": true
                        },
                        "id": "ff01d1516c",
                        "_paused": false
                    }
            
            """
                                                                
        do {
            let data = jsonData.data(using: .utf8)!
            keyStates = try jsonDecoder.decode(KeyStates.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(keyStates)
        XCTAssertEqual(keyStates?.type, .dictionary)
        XCTAssertEqual(try? keyStates?.parse(forKey: "web")?.type, .dictionary)
        XCTAssertEqual(try? keyStates?.parse(forKey: "web"), [:])
        XCTAssertEqual(try? keyStates?.parse(forKey: "home")?.type, .dictionary)
        XCTAssertEqual(try? keyStates?.parse(forKey: "home.cta_text")?.type, .dictionary)
        XCTAssertEqual(try? keyStates?.parse(forKey: "home._is_entry_point"), true)
        XCTAssertEqual(try? keyStates?.parse(forKey: "next")?.type, .dictionary)
        XCTAssertEqual(try? keyStates?.parse(forKey: "next.layout")?.type, .dictionary)
        XCTAssertEqual(try? keyStates?.parse(forKey: "next._predicate.rules")?.type, .array)
//        XCTAssertEqual(try? keyStates?.parse(forKey: "next._predicate.rules[0].field"), "view")
        XCTAssertEqual(try? keyStates?.parse(forKey: "next.layout._is_entry_point"), false)
        
        
        func testKeyNotInKeyState() {
            
        }
        
        func testPrefixInKeyState() {
            
        }
        
        func testPrefixNotInKeyState() {
            
        }
        
        func testRejectAllKeysIfContextFailsToMeetPredicate() {
            
        }
        
        func testActiveKeysInConfigButNotInGenome() {
            
        }
        
        
        func testCorrectActiveAndEntryKeysPerExperiment() {
            
        }
        
    }

   

}
