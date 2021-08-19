//
//  EvolvStoreNewTests.swift
//  EvolvSwiftSDKTests
//
//  Created by Alim Yuzbashev on 19.08.2021.
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
                
                if case .finished = publisherCompletion {
                    XCTAssertEqual(self.evolvConfiguration, evolvStore.evolvConfiguration)
                }
            }, receiveValue: { store in
                evolvStore = store
            })
            .store(in: &cancellables)
    }
}
