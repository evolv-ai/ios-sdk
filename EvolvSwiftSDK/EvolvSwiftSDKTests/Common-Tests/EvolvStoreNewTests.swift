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
    
    func initializeEvolvStore(with context: EvolvContextContainer) -> EvolvStore {
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
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        
        XCTAssertEqual(self.evolvConfiguration, evolvStore.evolvConfiguration)
    }
    
    func testAllocationsAreLoadedCorrectly() throws {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        
        XCTAssertEqual(self.evolvAllocations, evolvStore.evolvAllocations)
    }
    
    func testGetActiveKeysHomeKeyIsActive() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "next",
                                                                        "signedin" : "false"],
                                                localContextUserInfo: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        let activeKeys = evolvStore.getActiveKeys()
        
        XCTAssert(activeKeys.contains("next"))
        XCTAssert(activeKeys.contains("next.layout"))
        XCTAssertEqual(activeKeys.count, 2)
    }
    
    func testGetActiveKeysSubKeysAreActive() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:])

        let evolvStore = initializeEvolvStore(with: context)
        let activeKeys = evolvStore.getActiveKeys()
        
        XCTAssertEqual(activeKeys, ["home", "home.cta_text", "home.background", "button_color", "cta_text"])
    }
    
    func testActiveKeysAreReevaluatedOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        let firstActiveKeys = evolvStore.getActiveKeys()
        
        evolvStore.set(key: "signedin", value: "no", local: false)
        
        let secondActiveKeys = evolvStore.getActiveKeys()
        
        XCTAssertNotEqual(firstActiveKeys, secondActiveKeys)
        XCTAssertEqual(firstActiveKeys, ["home.cta_text", "home.background", "home", "button_color", "cta_text"])
        XCTAssertEqual(secondActiveKeys, ["home.cta_text", "home.background", "home"])
    }
    
    
    // MARK: - activeKeys sink
    func testActiveKeysAreAddedNotifyOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "no"],
                                                localContextUserInfo: [:])
        
        let evolvStore = initializeEvolvStore(with: context)
        
        var receivedActiveKeys = [Set<String>]()
        
        let expectation = self.expectation(description: "Awaiting active keys to sink expectation.")
        
        evolvStore.activeKeys.sink { activeKeys in
            receivedActiveKeys.append(activeKeys)
            
            if receivedActiveKeys.count == 2 {
                XCTAssertNotEqual(receivedActiveKeys[0], receivedActiveKeys[1])
                XCTAssertEqual(receivedActiveKeys[0], ["home.cta_text", "home.background", "home"])
                XCTAssertEqual(receivedActiveKeys[1], ["home.cta_text", "home.background", "home", "button_color", "cta_text"])
                
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        evolvStore.set(key: "signedin", value: "yes", local: false)
        
        waitForExpectations(timeout: 2)
    }
    
    func testActiveKeysAreRemovedNotifyOfOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:])
        
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
    
    func testActiveKeysDoNotNotifyIfNoContextChangeHappened() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:])
        let evolvStore = initializeEvolvStore(with: context)
        
        let expectation = self.expectation(description: "Active keys will not sink twice.")
        
        var sinkedTimes = 0
        evolvStore.activeKeys.sink { _ in
            sinkedTimes += 1
        }.store(in: &cancellables)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if sinkedTimes == 1 { expectation.fulfill() }
        }
        
        let isContextChanged = evolvStore.set(key: "signedin", value: "yes", local: false)
        
        waitForExpectations(timeout: 5)
        
        XCTAssert(!isContextChanged)
    }
    
    func testActiveKeysAreTheSameOnContextReevaluation() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:])
        let evolvStore = initializeEvolvStore(with: context)
        
        let firstActiveKeys = evolvStore.getActiveKeys()
        evolvStore.reevaluateContext()
        let secondActiveKeys = evolvStore.getActiveKeys()
        
        XCTAssertEqual(firstActiveKeys, secondActiveKeys)
    }
}
