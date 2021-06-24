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

    func testCanParseConfigurationJSONFile() throws {
       
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "configuration", ofType: "json") else {
            fatalError("json not found") }
        
        guard let json = try? String(contentsOfFile: pathString, encoding: .utf8) else {
            fatalError("Unable to convert json to String")
        }
        
        let jsonData = json.data(using: .utf8)!
        let configurationData: Configuration = try! JSONDecoder().decode(Configuration.self, from: jsonData)
        
        XCTAssertEqual("desktop", configurationData.client.device)
        XCTAssertEqual("BY", configurationData.client.location)
        XCTAssertEqual(156, configurationData.experiments[1].predicate.id)
        XCTAssertEqual("ff01d1516c", configurationData.experiments[0].id)
        XCTAssertEqual(false, configurationData.experiments[0].paused)
    }
}
