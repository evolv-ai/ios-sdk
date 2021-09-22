//
//  EvolvClientTests.swift
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
    var allocations: [Allocation]!
    var configuration: Configuration!
    var evolvAPI: EvolvAPIMock!
    
    override func setUpWithError() throws {
        cancellables = Set()
        
        options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab")
        
        allocations = try getAllocations()
        configuration = try getConfig()
        
        evolvAPI = EvolvAPIMock(evolvConfiguration: configuration, evolvAllocations: allocations)
    }

    override func tearDownWithError() throws {
        cancellables = nil
        options = nil
    }
    
    func testEvolvClientConfirm() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:])
        
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        client.confirm()
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvConfirmation]
        let expectedSubmittedEvents = [EvolvConfirmation(cid: "5fa0fd38aae6:47d857cd5e", uid: "C51EEAFC-724D-47F7-B99A-F3494357F164", eid: "ff01d1516c", timeStamp: actualSubmittedEvents[0].timeStamp)]
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    func testEvolvClientNoConfirmation() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        client.confirm()
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvConfirmation]
        let expectedSubmittedEvents = [EvolvConfirmation]()
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    func testEvolvClientContaminationAllExperimentsTrue() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        let contaminationReason = EvolvContaminationReason(reason: "Test reason.", details: "Test detauls")
        
        client.contaminate(details: contaminationReason, allExperiments: true)
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvContamination]
        let expectedSubmittedEvents: [EvolvContamination] = [
            .init(cid: "5fa0fd38aae6:47d857cd5e", uid: "C51EEAFC-724D-47F7-B99A-F3494357F164", eid: "ff01d1516c", timeStamp: actualSubmittedEvents[0].timeStamp, contaminationReason: contaminationReason),
            .init(cid: "2fhi23sdsd6:47d2551pc1f", uid: "C51EEAFC-724D-47F7-B99A-F3494357F164", eid: "00436dee0b", timeStamp: actualSubmittedEvents[1].timeStamp, contaminationReason: contaminationReason)
        ]
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    func testEvolvClientContaminationAllExperimentsFalse() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        let contaminationReason = EvolvContaminationReason(reason: "Test reason.", details: "Test detauls")
        
        client.contaminate(details: contaminationReason, allExperiments: false)
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvContamination]
        let expectedSubmittedEvents: [EvolvContamination] = [
            .init(cid: "5fa0fd38aae6:47d857cd5e", uid: "C51EEAFC-724D-47F7-B99A-F3494357F164", eid: "ff01d1516c", timeStamp: actualSubmittedEvents[0].timeStamp, contaminationReason: contaminationReason)
        ]
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    func testEvolvClientContaminationNoneSubmitted() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        let contaminationReason = EvolvContaminationReason(reason: "Test reason.", details: "Test detauls")

        client.contaminate(details: contaminationReason, allExperiments: false)

        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvContamination]
        let expectedSubmittedEvents = [EvolvContamination]()

        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
}
