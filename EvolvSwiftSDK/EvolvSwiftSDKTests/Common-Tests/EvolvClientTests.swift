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
import Combine
@testable import EvolvSwiftSDK

class EvolvClientTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    var options: EvolvClientOptions!
    
    override func setUpWithError() throws {
        cancellables = Set()
        
        options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab")
    }

    override func tearDownWithError() throws {
        cancellables = nil
        options = nil
    }
    
    func testEvolvClientInitialisesWithStore() throws {
        var evolvClient: EvolvClient!
        
        EvolvClientImpl.initialize(options: options)
            .sink(receiveCompletion: { publisherCompletion in
                XCTAssertNotNil(evolvClient)
                XCTAssertTrue(publisherCompletion.isFinished)
            }, receiveValue: { client in
                evolvClient = client
            })
            .store(in: &cancellables)
    }
}
