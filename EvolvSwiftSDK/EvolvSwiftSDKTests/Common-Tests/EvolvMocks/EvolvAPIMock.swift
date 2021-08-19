//
//  EvolvAPIMock.swift
//  EvolvSwiftSDKTests
//
//  Created by Alim Yuzbashev on 19.08.2021.
//

import Combine
@testable import EvolvSwiftSDK

struct EvolvAPIMock: EvolvAPI {
    let evolvConfiguration: Configuration
    let evolvAllocations: [Allocation]
    
    func configuration() -> AnyPublisher<Configuration, Error> {
        Just(evolvConfiguration)
            .eraseToAnyPublisherWithError()
    }
    
    func allocations() -> AnyPublisher<[Allocation], Error> {
        Just(evolvAllocations)
            .eraseToAnyPublisherWithError()
    }
}
