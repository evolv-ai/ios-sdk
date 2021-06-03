//
//  EvolvAPI.swift
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


import Foundation
import Combine

enum EvolvAPI {
    static let agent = Agent()
    static let base = URL(string: "https://participants.evolv.ai/v1")!
}

extension EvolvAPI {
      
//    TODO: change Issue to other object from Models
    static func configuration(eid: String, participantID: String) -> AnyPublisher<[Issue], Error> {
        return run(URLRequest(url: base.appendingPathComponent("/\(eid)/\(participantID)/configuration.json")))
    }
    
//    TODO: change Issue to other object from Models
    static func allocations(eid: String) -> AnyPublisher<[Issue], Error> {
        return run(URLRequest(url: base.appendingPathComponent("/\(eid)/allocations")))
    }
    
    static func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
