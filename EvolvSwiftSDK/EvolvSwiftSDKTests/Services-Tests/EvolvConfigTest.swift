//
//  EvolvConfigTest.swift
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

class EvolvConfigImplTest: XCTestCase {
    
    
    private let httpScheme: String = "https"
    private let domain: String = "participants.evolv.ai"
    private let version: String = "1"
    private let environmentId: String = "test_12345"
    
    private let store: EvolvStore?
    private let httpClient: EvolvHttpClient?
    
    override func setUp() {
        super.setUp()
        
//        TODO: create mock HttpClient
        
    }
    
    override func tearDown() {
        super.tearDown()
    
    }
    
    func testBuildDefaultConfig() {
        let config = EvolvConfigImpl(httpScheme: httpScheme, domain: domain, version: version, environmentId: environmentId, store: store, httpClient: httpClient)
        
        XCTAssertEqual(environmentId, config.environmentId)
        XCTAssertEqual(EvolvConfigImpl.Default.httpScheme, config.httpScheme)
        XCTAssertEqual(EvolvConfigImpl.Default.domain, config.domain)
        XCTAssertEqual(EvolvConfigImpl.Default.version, config.version)
        XCTAssertNotNil(config.httpClient)
        XCTAssertNotNil(config.store)
    }
   
}
