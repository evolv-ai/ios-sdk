//
//  EvolvStoreNewTests.swift
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
import Combine
@testable import EvolvSwiftSDK

class EvolvStoreNewTests: XCTestCase {
    var jsonDecoder: JSONDecoder!
    var cancellables: Set<AnyCancellable>!
    
    var evolvAPIMock: EvolvAPI!
    var evolvConfiguration: Configuration!
    var evolvAllocations: [Allocation]!
    
    override func setUpWithError() throws {
        jsonDecoder = JSONDecoder()
        cancellables = Set()
        
        evolvConfiguration = try getConfig()
        evolvAllocations = try getAllocations()
        
        evolvAPIMock = EvolvAPIMock(evolvConfiguration: evolvConfiguration, evolvAllocations: evolvAllocations)
    }
    
    override func tearDownWithError() throws {
        jsonDecoder = nil
        cancellables = nil
        evolvConfiguration = nil
        evolvAllocations = nil
        evolvAPIMock = nil
    }
    
    func getConfig() throws -> Configuration {
        let pathString = Bundle(for: type(of: self)).path(forResource: "configuration.json", ofType: nil)
        let json = try String(contentsOfFile: pathString!, encoding: .utf8)
        let jsonData = json.data(using: .utf8)!
        
        return try jsonDecoder.decode(Configuration.self, from: jsonData)
    }
    
    func getAllocations() throws -> [Allocation] {
        let pathString = Bundle(for: type(of: self)).path(forResource: "allocations", ofType: "json")
        let json = try String(contentsOfFile: pathString!, encoding: .utf8)
        let jsonData = json.data(using: .utf8)!
        
        return try jsonDecoder.decode([Allocation].self, from: jsonData)
    }
    
    func initializeEvolvStore(with context: EvolvContextImpl) -> EvolvStore {
        var evolvStore: EvolvStore!
        
        EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPIMock)
            .sink(receiveCompletion: { publisherCompletion in
                XCTAssertNotNil(evolvStore)
                XCTAssertTrue(publisherCompletion.isFinished)
            }, receiveValue: { store in
                evolvStore = store
            }).store(in: &self.cancellables)
        
        return evolvStore
    }
    
    func testConfigurationIsLoadedCorrectly() throws {
        let context = EvolvContextImpl(remoteContext: [:], localContext: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        
        XCTAssertEqual(self.evolvConfiguration, evolvStore.evolvConfiguration)
    }
    
    func testAllocationsAreLoadedCorrectly() throws {
        let context = EvolvContextImpl(remoteContext: [:], localContext: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        
        XCTAssertEqual(self.evolvAllocations, evolvStore.evolvAllocations)
    }
    
    func testGetActiveKeysHomeKeyIsActive() {
        let context = EvolvContextImpl(remoteContext: ["location" : "UA",
                                                       "view" : "next",
                                                       "signedin" : "false"],
                                       localContext: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        let activeKeys = evolvStore.getActiveKeys()
        
        XCTAssert(activeKeys.contains("next.layout"))
        XCTAssertEqual(activeKeys.count, 2)
    }
    
    func testGetActiveKeysSubKeysAreActive() {
        let context = EvolvContextImpl(remoteContext: ["location" : "UA",
                                                       "view" : "home",
                                                       "signedin" : "yes"],
                                       localContext: [:])

        let evolvStore = initializeEvolvStore(with: context)
        let activeKeys = evolvStore.getActiveKeys()
        
        XCTAssertEqual(activeKeys.count, 5)
    }
    
    func testActiveKeysAreReevaluatedOnContextChange() {
        let context = EvolvContextImpl(remoteContext: ["location" : "UA",
                                                       "view" : "home",
                                                       "signedin" : "yes"],
                                       localContext: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        let firstActiveKeys = evolvStore.getActiveKeys()
        
        evolvStore.set(key: "signedin", value: "no", local: false)
        
        let secondActiveKeys = evolvStore.getActiveKeys()
        
        XCTAssertNotEqual(firstActiveKeys, secondActiveKeys)
        XCTAssertEqual(firstActiveKeys, ["home.cta_text", "home.background", "home", "button_color", "cta_text"])
        XCTAssertEqual(secondActiveKeys, ["home.cta_text", "home.background", "home"])
    }
    
    func testActiveKeysNotifyOfChangeOnContextChange() {
        let context = EvolvContextImpl(remoteContext: ["location" : "UA",
                                                       "view" : "home",
                                                       "signedin" : "yes"],
                                       localContext: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        
        var receivedActiveKeys = [Set<String>]()
        
        let expectation = self.expectation(description: "Awaiting active keys to sink expectation.")
        
        evolvStore.activeKeys.sink { activeKeys in
            receivedActiveKeys.append(activeKeys)
            
            if receivedActiveKeys.count == 2 {
                XCTAssertNotEqual(receivedActiveKeys[0], receivedActiveKeys[1])
                XCTAssertEqual(receivedActiveKeys[0], ["home.cta_text", "home.background", "home", "button_color", "cta_text"])
                XCTAssertEqual(receivedActiveKeys[1], ["home.cta_text", "home.background", "home"])
                
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        evolvStore.set(key: "signedin", value: "no", local: false)
        
        waitForExpectations(timeout: 2)
    }
}
