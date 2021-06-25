//
//  AudienceQueryDataTest.swift
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

class AudienceQueryDataTest: XCTestCase {
    
    typealias EvolvAudienceQuery = GenomeObject
    
    static var sampleData = """
                  {
                    "id": 174,
                    "name": "Test_Audiences",
                    "combinator": "and",
                    "rules": [
                        {
                            "field": "Age",
                            "operator": "equal",
                            "value": "26"
                        },
                        {
                            "combinator": "or",
                            "rules": [
                                {
                                    "field": "Sex",
                                    "operator": "equal",
                                    "value": "female"
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
        """
    
    var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        jsonDecoder = JSONDecoder()
    }

    override func tearDown() {
        super.tearDown()
        
        jsonDecoder = nil
    }
}
        
// MARK: - Decode

extension AudienceQueryDataTest {
    
    func testDecodeSuccessWithJSONValid() {
        let jsonData = AudienceQueryDataTest.sampleData
        var audienceQuery: EvolvAudienceQuery?
        
        do {
            let data = jsonData.data(using: .utf8)!
            audienceQuery = try jsonDecoder.decode(EvolvAudienceQuery.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(audienceQuery)
        XCTAssertEqual(audienceQuery?.type, .dictionary)
    }
    
    func testDecodeKeysSuccessWithJSON() {
        
        let jsonData = """
            {
                "uid": "C51EEAFC-724D-47F7-B99A-F3494357F164",
                "eid": "47d857cd5e",
                "cid": "5fa0fd38aae6:47d857cd5e",
                "genome": {
                    "home": {
                        "cta_text": "Click Here"
                    },
                    "next": {
                        "layout": "Default Layout"
                    }
                },
                "audience_query": {
                    "id": 174,
                    "name": "Test_Audiences",
                    "combinator": "and",
                    "rules": [
                        {
                            "field": "Age",
                            "operator": "equal",
                            "value": "26"
                        },
                        {
                            "combinator": "or",
                            "rules": [
                                {
                                    "field": "Sex",
                                    "operator": "equal",
                                    "value": "female"
                                },
                                {
                                    "field": "Student",
                                    "operator": "contains",
                                    "value": "High_school"
                                }
                            ]
                        }
                    ]
                },
                "ordinal": 0,
                "group_id": "511ce252-92b5-4611-a00c-0e4120369c96",
                "excluded": false
            }
            """
        var audienceQuery: EvolvAudienceQuery?
        
        do {
            let data = jsonData.data(using: .utf8)!
            audienceQuery = try jsonDecoder.decode(EvolvAudienceQuery.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(audienceQuery)
        XCTAssertEqual(audienceQuery?.type, .dictionary)
        XCTAssertEqual(try? audienceQuery?.parse(forKey: "audience_query")?.type, .dictionary)
        XCTAssertEqual(try? audienceQuery?.parse(forKey: "audience_query.id")?.type, .number)
        XCTAssertEqual(try? audienceQuery?.parse(forKey: "audience_query.rules")?.type, .array)
        XCTAssertEqual(try? audienceQuery?.parse(forKey: "audience_query.id"), 174)
        XCTAssertEqual(try? audienceQuery?.parse(forKey: "audience_query.name"), "Test_Audiences")
        XCTAssertEqual(try? audienceQuery?.parse(forKey: "audience_query.combinator"), "and")
        
    }
    
}

