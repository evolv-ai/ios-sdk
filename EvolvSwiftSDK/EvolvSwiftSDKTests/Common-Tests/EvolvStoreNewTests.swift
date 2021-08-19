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

    func testConfigurationIsLoadedCorrectly() throws {
        let context = EvolvContextImpl(remoteContext: [:], localContext: [:])
        
        var evolvStore: EvolvStore!
        
        EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPIMock)
            .sink(receiveCompletion: { publisherCompletion in
                XCTAssertNotNil(evolvStore)
                
                if case .finished = publisherCompletion {
                    XCTAssertEqual(self.evolvConfiguration, evolvStore.evolvConfiguration)
                }
            }, receiveValue: { store in
                evolvStore = store
            })
            .store(in: &cancellables)
    }
    
    func testAllocationsAreLoadedCorrectly() throws {
        let context = EvolvContextImpl(remoteContext: [:], localContext: [:])
        
        var evolvStore: EvolvStore!
        
        EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPIMock)
            .sink(receiveCompletion: { publisherCompletion in
                XCTAssertNotNil(evolvStore)
                XCTAssertTrue(publisherCompletion.isFinished)
                
                if case .finished = publisherCompletion {
                    XCTAssertEqual(self.evolvConfiguration, evolvStore.evolvConfiguration)
                }
            }, receiveValue: { store in
                evolvStore = store
            })
            .store(in: &cancellables)
    }
}
