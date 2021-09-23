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
    
    // MARK: - Confirm
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
    
    // MARK: - Contaminate
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
    
    // MARK: - Emit
    func testEventIsEmited() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        struct Metadata: Encodable, Equatable {
            let first: String
            let second: Int
        }
        
        let metadata = Metadata(first: "test", second: 123)
        client.emit(eventType: "testEventIsEmited()", metadata: metadata, flush: true)
        
        let actualSubmittedEvent = evolvAPI.submittedEvents[0] as! EvolvCustomEventForSubmission<Metadata>
        let expectedSubmittedEvent = EvolvCustomEventForSubmission(type: "testEventIsEmited()", uid: options.participantID, metadata: metadata)
        
        XCTAssertEqual(evolvAPI.submittedEvents.count, 1)
        XCTAssertEqual(actualSubmittedEvent.uid, expectedSubmittedEvent.uid)
        XCTAssertEqual(actualSubmittedEvent.type, expectedSubmittedEvent.type)
        XCTAssertEqual(actualSubmittedEvent.metadata, expectedSubmittedEvent.metadata)
    }
    
    func testEventIsAddedToContext() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        struct Metadata: Encodable, Equatable {
            let first: String
            let second: Int
        }
        
        let metadata = Metadata(first: "abcd", second: 555000)
        client.emit(eventType: "testEventIsSavedToContext()", metadata: metadata, flush: true)
        
        let actualSavedEvent = store.evolvContext.events[0]
        let expectedSavedEvent = EvolvCustomEvent(type: "testEventIsSavedToContext()", timestamp: Date())
        
        XCTAssertEqual(store.evolvContext.events.count, 1)
        XCTAssertEqual(actualSavedEvent.type, expectedSavedEvent.type)
    }
    
    // MARK: - Get value for key
    func testGetsDictionaryValueForActiveKey() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        let expectedHomeKey = ["cta_text": "Click Here"]
        let actualHomeKey = client.get(valueForKey: "home") as? [String : String]
        
        XCTAssertEqual(expectedHomeKey, actualHomeKey)
    }
    
    func testGetsNilValueForNonActiveKey() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:])
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_single"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        let actualHomeKey = client.get(valueForKey: "home")
        
        XCTAssert(actualHomeKey == nil)
    }
    
    func testGetsNativePrimitiveValuesForActiveKeys() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        let actualHomeKey = client.get(valueForKey: "home.cta_text") as? String
        
        XCTAssert(actualHomeKey == "Click Here")
    }
    
    func testGetsPrimitiveValuesForActiveKeys() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        let actualHomeKey = client.get(valueForKey: "button_color") as? Int
        
        XCTAssert(actualHomeKey == 1500)
    }
    
    func testGetsDecodableStructureForActiveKeys() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex",
                                                                        "authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:])
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_single"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        struct ButtonColorKey: Decodable, Equatable {
            struct SingleButton: Decodable, Equatable {
                let color: String
            }
            
            let first_button: SingleButton
            let second_button: SingleButton
        }
        
        let actualButtonGenome: ButtonColorKey? = client.get(decodableValueForKey: "button_color")
        let expectedButtonGenome = ButtonColorKey(first_button: .init(color: "blue"), second_button: .init(color: "red"))
        
        XCTAssertEqual(expectedButtonGenome, actualButtonGenome)
    }
    
    func testGetsNullifiesOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        let firstActualValue = client.get(valueForKey: "button_color") as? Int
        _ = client.set(key: "device", value: "unknown", local: false)
        let secondActualValue = client.get(valueForKey: "button_color") as? Int
        
        XCTAssertEqual([firstActualValue, secondActualValue], [1500, nil])
    }
    
    func testGetsValueAfterNilOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"unknown",
                                                                        "text":"cancel"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        let firstActualValue = client.get(valueForKey: "button_color") as? Int
        _ = client.set(key: "device", value: "mobile", local: false)
        let secondActualValue = client.get(valueForKey: "button_color") as? Int
        
        XCTAssertEqual([firstActualValue, secondActualValue], [nil, 1500])
    }
    
    // MARK: - Get value subscription
    func testSubscribeGetSingleValue() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        var actualValue: Int?
        _ = client.get(subscriptionOnValueForKey: "button_color")
            .sink(receiveValue: { actualValue = $0 as? Int })
        
        XCTAssertEqual(actualValue, 1500)
    }
    
    func testSubscribeNullifiesOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        var actualValues = [Int?]()
        client.get(subscriptionOnValueForKey: "button_color")
            .sink(receiveValue: { actualValues.append($0 as? Int) })
            .store(in: &cancellables)
        
        _ = client.set(key: "device", value: "unknown", local: false)
        
        XCTAssertEqual(actualValues, [1500, nil])
    }
    
    func testSubscribeGetValueAfterNilOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"unknown",
                                                                        "text":"cancel"], localContextUserInfo: [:])
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        var actualValues = [Int?]()
        client.get(subscriptionOnValueForKey: "button_color")
            .sink(receiveValue: { actualValues.append($0 as? Int) })
            .store(in: &cancellables)
        
        _ = client.set(key: "device", value: "mobile", local: false)
        
        XCTAssertEqual(actualValues, [nil, 1500])
    }
    
    func testGetsDecodableValues() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex",
                                                                        "authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:])
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_single"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI)
        
        struct ButtonColorKey: Decodable, Equatable {
            struct SingleButton: Decodable, Equatable {
                let color: String
            }
            
            let first_button: SingleButton
            let second_button: SingleButton
        }
        
        var actualValues = [ButtonColorKey?]()
        
        let buttonColorKey: AnyPublisher<ButtonColorKey?, Never> = client.get(subscriptionDecodableOnValueForKey: "button_color")
        buttonColorKey.sink(receiveValue: { genome in
            actualValues.append(genome)
        }).store(in: &cancellables)
        _ = client.set(key: "device", value: "none", local: false)
        
        let expectedValues = [ButtonColorKey(first_button: .init(color: "blue"), second_button: .init(color: "red")), nil]
        
        XCTAssertEqual(expectedValues, actualValues)
    }
}
