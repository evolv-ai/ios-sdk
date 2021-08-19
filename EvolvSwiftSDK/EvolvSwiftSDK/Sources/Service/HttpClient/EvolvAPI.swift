//
//  EvolvAPI.swift
//  EvolvSwiftSDK
//
//  Created by Alim Yuzbashev on 19.08.2021.
//

import Combine

protocol EvolvAPI {
    func configuration() -> AnyPublisher<Configuration, Error>
    
    func allocations() -> AnyPublisher<[Allocation], Error>
}
