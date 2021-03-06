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
    var scope: AnyHashable!
    
    override func setUpWithError() throws {
        jsonDecoder = JSONDecoder()
        cancellables = Set()
        
        evolvConfiguration = try getConfig()
        evolvAllocations = try getAllocations()
        
        evolvAPIMock = EvolvAPIMock(evolvConfiguration: evolvConfiguration, evolvAllocations: evolvAllocations)
        scope = UUID()
    }
    
    override func tearDownWithError() throws {
        jsonDecoder = nil
        cancellables = nil
        evolvConfiguration = nil
        evolvAllocations = nil
        evolvAPIMock = nil
        scope = nil
    }
    
    func initializeEvolvStore(with context: EvolvContextContainerImpl) -> EvolvStore {
        var evolvStore: EvolvStore!
        
        EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPIMock, scope: scope)
            .sink(receiveCompletion: { publisherCompletion in
                XCTAssertNotNil(evolvStore)
                XCTAssertTrue(publisherCompletion.isFinished)
            }, receiveValue: { store in
                evolvStore = store
            }).store(in: &self.cancellables)
        
        return evolvStore
    }
    
    func testConfigurationIsLoadedCorrectly() throws {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:], scope: scope)
        
        let evolvStore = initializeEvolvStore(with: context)
        
        XCTAssertEqual(self.evolvConfiguration, evolvStore.evolvConfiguration)
    }
    
    func testAllocationsAreLoadedCorrectly() throws {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:], scope: scope)
        
        let evolvStore = initializeEvolvStore(with: context)
        
        XCTAssertEqual(self.evolvAllocations, evolvStore.evolvAllocations)
    }
    
    func testGetActiveKeysHomeKeyIsActive() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "next",
                                                                        "signedin" : "false"],
                                                localContextUserInfo: [:], scope: scope)
        
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
                                                localContextUserInfo: [:], scope: scope)

        let evolvStore = initializeEvolvStore(with: context)
        let activeKeys = evolvStore.getActiveKeys()
        
        XCTAssertEqual(activeKeys, ["home", "home.cta_text", "home.background", "button_color", "cta_text"])
    }
    
    func testActiveKeysAreReevaluatedOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:], scope: scope)
        
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
                                                localContextUserInfo: [:], scope: scope)
        
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
                                                localContextUserInfo: [:], scope: scope)
        
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
                                                localContextUserInfo: [:], scope: scope)
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
                                                localContextUserInfo: [:], scope: scope)
        let evolvStore = initializeEvolvStore(with: context)
        
        let firstActiveKeys = evolvStore.getActiveKeys()
        evolvStore.reevaluateContext()
        let secondActiveKeys = evolvStore.getActiveKeys()
        
        XCTAssertEqual(firstActiveKeys, secondActiveKeys)
    }
}

// MARK: - Entry keys
extension EvolvStoreNewTests {
    func testEntryKeysAreEvaluated() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:], scope: scope)
        
        let evolvStore = initializeEvolvStore(with: context)
        
        let expectedActiveVariantKeys: Set = ["home:-829368886", "button_color:1512228", "cta_text:-1214071718", "home.cta_text:1603301368"]
        let actualActiveVariantKeys = evolvStore.activeVariantKeys.value
        
        XCTAssertEqual(expectedActiveVariantKeys, actualActiveVariantKeys)
    }
    
    func testEntryKeysAreReevaluated() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:], scope: scope)
        
        let evolvStore = initializeEvolvStore(with: context)
        
        evolvStore.set(key: "view", value: "next", local: false)
        
        let expectedActiveVariantKeys: Set = ["next.layout:-1978477897", "cta_text:-1214071718", "button_color:1512228", "next:-1201134915"]
        let actualActiveVariantKeys = evolvStore.activeVariantKeys.value
        
        XCTAssertEqual(expectedActiveVariantKeys, actualActiveVariantKeys)
    }
    
    func testEntryKeysAreReevaluatedToEmptySet() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:], scope: scope)
        
        evolvAPIMock = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_single"))
        
        let evolvStore = initializeEvolvStore(with: context)
        
        evolvStore.set(key: "view", value: "none", local: false)
        evolvStore.set(key: "signedin", value: "failed", local: false)
        
        let expectedActiveVariantKeys: Set<String> = []
        let actualActiveVariantKeys = evolvStore.activeVariantKeys.value
        
        XCTAssertEqual(expectedActiveVariantKeys, actualActiveVariantKeys)
    }
    
    func testHashCodeIsEvaluatedWithoutRuntimeOverflowError() {
        // This line will throw an uncatchable runtime error
        // if integer overflow is not allowed.
        _ = "{\"cta_text\":\"Click Here\"}".evolvHashCode()
    }
    
    func testHashCodeIsEvaluatedCorrectlyForString() {
        func eval(payload: String, expectedHash: Int) {
            let actualHash = payload.evolvHashCode()
            
            XCTAssertEqual(actualHash, expectedHash)
        }
        
        eval(payload: "view_home", expectedHash: -1573367239)
        eval(payload: "exmaple_hash-code&1112", expectedHash: -1538179976)
        eval(payload: "location:US,view:next,age:50", expectedHash: 928736387)
    }
    
    func testHashCodeIsEvaluatedCorrectlyForObject() {
        func eval(payload: GenomeObject, expectedHash: Int) {
            let actualHash = payload.jsonStringify.evolvHashCode()
            
            XCTAssertEqual(actualHash, expectedHash)
        }
        
        let genomes: GenomeObject = [["b" : "2", "a" : "1", "arr" : [ "b": 2, "a": 3 ]],
                                     ["view" : "memory", "location" : "1", "known" : ["see": "", "look": "abc" ]]]
        
        eval(payload: genomes[0]!, expectedHash: 618626147)
        eval(payload: genomes[1]!, expectedHash: -347414157)
    }
}
