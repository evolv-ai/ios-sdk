//
//  EvolvAPIMock.swift
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

import Combine
@testable import EvolvSwiftSDK

class EvolvAPIMock: EvolvAPI {
    let evolvConfiguration: Configuration
    let evolvAllocations: [Allocation]
    
    var submittedEvents: [EvolvEvent]
    var submittedData = [EvolvBeaconMessage]()
    
    internal init(evolvConfiguration: Configuration, evolvAllocations: [Allocation], submittedEvents: [EvolvEvent] = []) {
        self.evolvConfiguration = evolvConfiguration
        self.evolvAllocations = evolvAllocations
        self.submittedEvents = submittedEvents
    }
    
    func configuration() -> AnyPublisher<Configuration, Error> {
        Just(evolvConfiguration)
            .eraseToAnyPublisherWithError()
    }
    
    func allocations() -> AnyPublisher<([Allocation], [ExcludedAllocation]), Error> {
        let allocations = evolvAllocations.filter { !$0.excluded }
        let excludedAllocation = evolvAllocations
            .filter { $0.excluded }
            .map { ExcludedAllocation(userId: $0.userId, experimentId: $0.experimentId, excluded: true) }
        
        return Just((allocations, excludedAllocation))
            .eraseToAnyPublisherWithError()
    }

    func submit<T>(events: [T]) where T : EvolvEvent {
        submittedEvents = events
    }
    
    func submit(data: EvolvBeaconMessage) {
        submittedData.append(data)
    }
}
