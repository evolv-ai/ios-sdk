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
    var scope: AnyHashable!
    var evolvBeacon: EvolvBeacon!
    
    override func setUpWithError() throws {
        cancellables = Set()
        
        allocations = try getAllocations()
        configuration = try getConfig()
        scope = UUID()
        
        evolvAPI = EvolvAPIMock(evolvConfiguration: configuration, evolvAllocations: allocations)
        evolvBeacon = EvolvBeaconMock(endPoint: evolvAPI.submit(data:), uid: "80658403_1629111253538", blockTransmit: false)
        
        options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, beacon: evolvBeacon)
    }

    override func tearDownWithError() throws {
        configuration = nil
        allocations = []
        evolvAPI = nil
        cancellables = nil
        options = nil
        scope = nil
        evolvBeacon = nil
    }
    
    // MARK: - Confirm
    func testEvolvClientConfirm() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location" : "UA",
                                                                        "view" : "home",
                                                                        "signedin" : "yes"],
                                                localContextUserInfo: [:], scope: scope)
        
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        client.confirm()
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvConfirmation]
        let expectedSubmittedEvents = [EvolvConfirmation(cid: "5fa0fd38aae6:47d857cd5e", uid: "C51EEAFC-724D-47F7-B99A-F3494357F164", eid: "ff01d1516c", timeStamp: actualSubmittedEvents[0].timeStamp)]
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    func testEvolvClientNoConfirmation() {
        let scope = UUID()
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        client.confirm()
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvConfirmation]
        let expectedSubmittedEvents = [EvolvConfirmation]()
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    // MARK: - Contaminate
    func testEvolvClientContaminationAllExperimentsTrue() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
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
                                                                        "name":"Alex"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        let contaminationReason = EvolvContaminationReason(reason: "Test reason.", details: "Test detauls")
        
        client.contaminate(details: contaminationReason, allExperiments: false)
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvContamination]
        let expectedSubmittedEvents: [EvolvContamination] = [
            .init(cid: "5fa0fd38aae6:47d857cd5e", uid: "C51EEAFC-724D-47F7-B99A-F3494357F164", eid: "ff01d1516c", timeStamp: actualSubmittedEvents[0].timeStamp, contaminationReason: contaminationReason)
        ]
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    func testEvolvClientContaminationNoneSubmitted() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        let contaminationReason = EvolvContaminationReason(reason: "Test reason.", details: "Test detauls")

        client.contaminate(details: contaminationReason, allExperiments: false)

        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvContamination]
        let expectedSubmittedEvents = [EvolvContamination]()

        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    // MARK: - Emit
    func testEventIsEmited() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
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
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
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
                                                                        "name":"Alex"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        let expectedHomeKey = ["cta_text": "Click Here"]
        let actualHomeKey = client.get(valueForKey: "home") as? [String : String]
        
        XCTAssertEqual(expectedHomeKey, actualHomeKey)
    }
    
    func testGetsNilValueForNonActiveKey() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: [:], localContextUserInfo: [:], scope: scope)
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_single"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        let actualHomeKey = client.get(valueForKey: "home")
        
        XCTAssert(actualHomeKey == nil)
    }
    
    func testGetsNativePrimitiveValuesForActiveKeys() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        let actualHomeKey = client.get(valueForKey: "home.cta_text") as? String
        
        XCTAssert(actualHomeKey == "Click Here")
    }
    
    func testGetsPrimitiveValuesForActiveKeys() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"mobile",
                                                                        "signedin":"yes"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        let actualHomeKey = client.get(valueForKey: "button_color") as? Int
        
        XCTAssert(actualHomeKey == 1500)
    }
    
    func testGetsDecodableStructureForActiveKeys() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex",
                                                                        "authenticated":"false",
                                                                        "device":"mobile",
                                                                        "signedin":"yes"], localContextUserInfo: [:], scope: scope)
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_single"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        struct ButtonColorKey: Decodable, Equatable {
            struct SingleButton: Decodable, Equatable {
                let color: String
            }
            
            let first_button: SingleButton
            let second_button: SingleButton
        }
        
        let actualButtonGenome = try? client.get(decodableValueForKey: "button_color", type: ButtonColorKey.self)
        let expectedButtonGenome = ButtonColorKey(first_button: .init(color: "blue"), second_button: .init(color: "red"))
        
        XCTAssertEqual(expectedButtonGenome, actualButtonGenome)
    }
    
    func testGetsNullifiesOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"mobile",
                                                                        "signedin":"yes"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        let firstActualValue = client.get(valueForKey: "button_color") as? Int
        _ = client.set(key: "signedin", value: "no", local: false)
        let secondActualValue = client.get(valueForKey: "button_color") as? Int
        
        XCTAssertEqual([firstActualValue, secondActualValue], [1500, nil])
    }
    
    func testGetsValueAfterNilOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"unknown",
                                                                        "text":"cancel"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        let firstActualValue = client.get(valueForKey: "button_color") as? Int
        _ = client.set(key: "signedin", value: "yes", local: false)
        let secondActualValue = client.get(valueForKey: "button_color") as? Int
        
        XCTAssertEqual([firstActualValue, secondActualValue], [nil, 1500])
    }
    
    // MARK: - Get value subscription
    func testSubscribeGetSingleValue() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"mobile",
                                                                        "signedin":"yes"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        var actualValue: Int?
        _ = client.get(subscriptionOnValueForKey: "button_color")
            .sink(receiveValue: { actualValue = $0 as? Int })
        
        XCTAssertEqual(actualValue, 1500)
    }
    
    func testSubscribeNullifiesOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"mobile",
                                                                        "signedin":"yes"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        var actualValues = [Int?]()
        client.get(subscriptionOnValueForKey: "button_color")
            .sink(receiveValue: { actualValues.append($0 as? Int) })
            .store(in: &cancellables)
        
        _ = client.set(key: "signedin", value: "no", local: false)
        
        XCTAssertEqual(actualValues, [1500, nil])
    }
    
    func testSubscribeGetValueAfterNilOnContextChange() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["authenticated":"false",
                                                                        "device":"unknown",
                                                                        "text":"cancel"], localContextUserInfo: [:], scope: scope)
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        var actualValues = [Int?]()
        client.get(subscriptionOnValueForKey: "button_color")
            .sink(receiveValue: { actualValues.append($0 as? Int) })
            .store(in: &cancellables)
        
        _ = client.set(key: "signedin", value: "yes", local: false)
        
        XCTAssertEqual(actualValues, [nil, 1500])
    }
    
    func testGetsDecodableValues() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex",
                                                                        "authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel",
                                                                        "signedin":"yes"], localContextUserInfo: [:], scope: scope)
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_single"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        struct ButtonColorKey: Decodable, Equatable {
            struct SingleButton: Decodable, Equatable {
                let color: String
            }
            
            let first_button: SingleButton
            let second_button: SingleButton
        }
        
        var actualValues = [ButtonColorKey?]()
        
        client.get(subscriptionDecodableOnValueForKey: "button_color", type: ButtonColorKey.self)
            .sink(receiveValue: { genome in
                actualValues.append(genome)
            }).store(in: &cancellables)
        
        _ = client.set(key: "signedin", value: "no", local: false)
        
        let expectedValues = [ButtonColorKey(first_button: .init(color: "blue"), second_button: .init(color: "red")), nil]
        
        XCTAssertEqual(expectedValues, actualValues)
    }
}

// MARK: - Data call analtics
extension EvolvClientTests {
    func testDataCallContextIsInitialized() {
        let _ = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        struct Empty: Encodable {}
        let actualSubmittedData = evolvAPI.submittedData.first
        let expectedSubmittedDatta = EvolvBeaconMessage(uid: options.participantID, messages: [.init(type: CONTEXT_INITIALIZED, payload: AnyEncodable(Empty()))])
        
        XCTAssertEqual(actualSubmittedData, expectedSubmittedDatta)
    }
    
    func testDataCallAllocationsAreAdded() {
        let _ = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        let actualSubmittedData = evolvAPI.submittedData.set()
        let expectedSubmittedData = [EvolvBeaconMessage(uid: options.participantID,
                                                        messages: [.init(type: CONTEXT_VALUE_ADDED,
                                                                         payload: .init(SimpleKVStorage(key: "experiments.allocations", value: .init(allocations))))])].set()
        
        XCTAssertTrue(expectedSubmittedData.isSubset(of: actualSubmittedData))
    }
    
    func testDataCallUserInfoIsAdded() {
        let remoteContext = ["device" : "mobile",
                             "location" : "UA"]
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, remoteContext: remoteContext, beacon: evolvBeacon)
        let _ = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        let actualSubmittedData = evolvAPI.submittedData.set()
        let expectedSubmittedData = [EvolvBeaconMessage(uid: "80658403_1629111253538",
                                                        messages: [.init(type: "context.value.added", payload: .init(SimpleKVStorage(key: "device", value: AnyEncodable(AnyEncodable("mobile")))))]),
                                     EvolvBeaconMessage(uid: "80658403_1629111253538",
                                                        messages: [.init(type: "context.value.added", payload: .init(SimpleKVStorage(key: "location", value: AnyEncodable(AnyEncodable("UA")))))])].set()
        
        XCTAssertTrue(expectedSubmittedData.isSubset(of: actualSubmittedData))
    }
    
    func testDataCallUserInfoIsChanged() {
        let remoteContext = ["location" : "UA"]
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, remoteContext: remoteContext, beacon: evolvBeacon)
        let client = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        _ = client.set(key: "location", value: "US", local: false)
        
        let actualSubmittedData = evolvAPI.submittedData.set()
        let expectedSubmittedData = [EvolvBeaconMessage(uid: "80658403_1629111253538",
                                                        messages: [.init(type: "context.value.added", payload: .init(SimpleKVStorage(key: "location", value: AnyEncodable(AnyEncodable("UA")))))]),
                                     EvolvBeaconMessage(uid: "80658403_1629111253538",
                                                        messages: [.init(type: "context.value.changed", payload: .init(SimpleKVStorage(key: "location", value: AnyEncodable("US"))))])].set()
        
        XCTAssertTrue(expectedSubmittedData.isSubset(of: actualSubmittedData))
    }
    
    func testDataCallActiveKeysAreAddedAndChanged() {
        let remoteContext = ["location":"UA",
                             "view":"home",
                             "name":"Alex"]
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, remoteContext: remoteContext, beacon: evolvBeacon)
        let client = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        _ = client.set(key: "view", value: "next", local: false)
        
        let actualSubmittedData = evolvAPI.submittedData.set()
        let expectedSubmittedData = [EvolvBeaconMessage(uid: "80658403_1629111253538",
                                                        messages: [.init(type: "context.value.added", payload: AnyEncodable(SimpleKVStorage(key: "keys.active", value: AnyEncodable(["home.background", "home.cta_text", "home"]))))]),
                                     EvolvBeaconMessage(uid: "80658403_1629111253538",
                                                        messages: [.init(type: "context.value.changed", payload: AnyEncodable(SimpleKVStorage(key: "keys.active", value: AnyEncodable(["next", "next.layout"]))))])].set()
        
        XCTAssertTrue(expectedSubmittedData.isSubset(of: actualSubmittedData))
    }
}

// MARK: - On listeners
extension EvolvClientTests {
    func testOnContextValueAdded() {
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, remoteContext: [:], beacon: evolvBeacon)
        let client = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        struct Value: Equatable, Hashable {
            let key: String!
            let value: String!
        }
        
        var actualValuesAdded = Set<Value>()
        client.on(topic: CONTEXT_VALUE_ADDED) { value in
            actualValuesAdded.insert(Value(key: value["key"] as? String, value: value["value"] as? String))
        }
        _ = client.set(key: "location", value: "US", local: false)
        _ = client.set(key: "view", value: "home", local: true)
        
        let expectedValuesAdded: Set<Value> = [.init(key: "location", value: "US"), .init(key: "view", value: "home")]
        
        XCTAssert(expectedValuesAdded.isSubset(of: actualValuesAdded))
    }
    
    func testOnSameContextValueChangedForRemoteAndLocal() {
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, remoteContext: [:], beacon: evolvBeacon)
        let client = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        struct Value: Equatable, Hashable {
            let key: String!
            let value: String!
        }
        
        var actualValuesAdded = [Value]()
        var actualValuesChanged = [Value]()
        client.on(topic: CONTEXT_VALUE_ADDED) { value in
            actualValuesAdded.append(Value(key: value["key"] as? String, value: value["value"] as? String))
        }
        client.on(topic: CONTEXT_VALUE_CHANGED) { value in
            actualValuesChanged.append(Value(key: value["key"] as? String, value: value["value"] as? String))
        }
        _ = client.set(key: "location", value: "US", local: false)
        _ = client.set(key: "location", value: "DE", local: true)
        
        let expectedValuesAdded: Set<Value> = [.init(key: "location", value: "US"), .init(key: "location", value: "DE")]
        
        XCTAssert(expectedValuesAdded.isSubset(of: actualValuesAdded))
        XCTAssertEqual(expectedValuesAdded.intersection(actualValuesChanged).count, 0)
    }
    
    func testOnContextValueRemoved() {
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, remoteContext: [:], beacon: evolvBeacon)
        let client = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        struct Value: Equatable, Hashable {
            let key: String!
            let value: String?
        }
        
        var actualValuesAdded = [Value]()
        var actualValuesRemoved = [Value]()
        client.on(topic: CONTEXT_VALUE_ADDED) { value in
            actualValuesAdded.append(Value(key: value["key"] as? String, value: value["value"] as? String))
        }
        client.on(topic: CONTEXT_VALUE_REMOVED) { value in
            actualValuesRemoved.append(Value(key: value["key"] as? String, value: value["value"] as? String))
        }
        _ = client.set(key: "location", value: "US", local: false)
        _ = client.remove(key: "location")
        
        let expectedValuesAdded: Set<Value> = [.init(key: "location", value: "US")]
        let expectedValuesRemoved: [Value] = [.init(key: "location", value: nil)]
        
        XCTAssert(expectedValuesAdded.isSubset(of: actualValuesAdded))
        XCTAssertEqual(expectedValuesRemoved, actualValuesRemoved)
        XCTAssertEqual(expectedValuesRemoved.count, 1)
    }
    
    func testOnceContextValueChanged() {
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, remoteContext: [:], beacon: evolvBeacon)
        let client = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        struct Value: Equatable, Hashable {
            let key: String!
            let value: String?
        }
        
        var actualValuesChanged = Set<Value>()
        client.on(topic: CONTEXT_VALUE_CHANGED) { value in
            actualValuesChanged.insert(Value(key: value["key"] as? String, value: value["value"] as? String))
        }
        _ = client.set(key: "location", value: "US", local: false)
        _ = client.set(key: "location", value: "DE", local: false)
        _ = client.set(key: "location", value: "UA", local: false)
        _ = client.set(key: "location", value: "UK", local: false)
        
        let expectedValuesChanged: Set<Value> = [.init(key: "location", value: "DE"),
                                               .init(key: "location", value: "UA"),
                                               .init(key: "location", value: "UK")]
        
        XCTAssert(expectedValuesChanged.isSubset(of: actualValuesChanged))
    }
    
    func testOnEmitEventWithMetadata() {
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab", analytics: true, remoteContext: [:], beacon: evolvBeacon)
        let client = EvolvClientImpl(options: options, evolvAPI: evolvAPI, scope: scope).initialize().wait()
        
        struct Metadata: Encodable, Equatable {
            let number: Int
        }
        
        let expectedMetadata = Metadata(number: 1050)
        let topic = "custom.event"
        
        var actualEventReceived = [String : Any]()
        client.on(topic: EvolvClient_EVENT_EMITTED) { payload in
            actualEventReceived = payload as [String : Any]
        }
        
        client.emit(eventType: topic, metadata: expectedMetadata, flush: true)
        
        XCTAssertEqual(actualEventReceived["metadata"] as? Metadata, expectedMetadata)
        XCTAssertEqual(actualEventReceived["type"] as? String, topic)
    }
}

// MARK: - Excluded experiments
extension EvolvClientTests {
    func testExcludedExperimentsKeysAreNotActive() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex",
                                                                        "authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:], scope: scope)
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_excluded"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        let expectedActiveKeys: Set<String> = ["home", "home.background", "home.cta_text"]
        let actualActiveKeys = client.getActiveKeys()
        
        XCTAssertEqual(expectedActiveKeys, actualActiveKeys)
    }
    
    func testExcludedExperimentsValuesForKeysAreNil() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex",
                                                                        "authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:], scope: scope)
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_excluded"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        let actualValuesForKeys = [client.get(valueForKey: "cta_text"),
                                   client.get(valueForKey: "button_height")]
        
        XCTAssert(!actualValuesForKeys.contains { $0 != nil })
    }
    
    func testExcludedExperimentsConfirmationEventNotFired() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex",
                                                                        "authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:], scope: scope)
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_excluded"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        client.confirm()
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvConfirmation]
        let expectedSubmittedEvents = [EvolvConfirmation(cid: "5fa0fd38aae6:47d857cd5e", uid: "C51EEAFC-724D-47F7-B99A-F3494357F164", eid: "ff01d1516c", timeStamp: actualSubmittedEvents[0].timeStamp)]
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
    
    func testExcludedExperimentsContaminationEventNotFired() {
        let context = EvolvContextContainerImpl(remoteContextUserInfo: ["location":"UA",
                                                                        "view":"home",
                                                                        "name":"Alex",
                                                                        "authenticated":"false",
                                                                        "device":"mobile",
                                                                        "text":"cancel"], localContextUserInfo: [:], scope: scope)
        let evolvAPI = EvolvAPIMock(evolvConfiguration: try! getConfig(), evolvAllocations: try! getAllocations(fileName: "allocations_excluded"))
        let store = EvolvStoreImpl.initialize(evolvContext: context, evolvAPI: evolvAPI, scope: scope).wait()
        let client = EvolvClientImpl(options: options, evolvStore: store, evolvAPI: evolvAPI, scope: scope)
        
        client.contaminate(details: nil, allExperiments: true)
        
        let actualSubmittedEvents = evolvAPI.submittedEvents as! [EvolvContamination]
        let expectedSubmittedEvents = [EvolvContamination(cid: "5fa0fd38aae6:47d857cd5e", uid: "C51EEAFC-724D-47F7-B99A-F3494357F164", eid: "ff01d1516c", timeStamp: actualSubmittedEvents[0].timeStamp, contaminationReason: nil)]
        
        XCTAssertEqual(expectedSubmittedEvents, actualSubmittedEvents)
    }
}
