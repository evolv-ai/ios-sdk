//
//  EvolvHTTPAPI.swift
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

struct EvolvHTTPAPI {
    let httpClient = EvolvHttpClient()
    let httpConfig: HttpConfig
    let session = URLSession.shared
    
    init(options: EvolvClientOptions) {
        self.httpConfig = HttpConfig(options: options)
    }
    
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return httpClient.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}

extension EvolvHTTPAPI: EvolvAPI {
    func configuration() -> AnyPublisher<Configuration, Error> {
        return run(URLRequest(url: httpConfig.configurationURL))
    }
    
    func allocations() -> AnyPublisher<([Allocation], [ExcludedAllocation]), Error> {
        let publisher: AnyPublisher<[AllocationContainer], Error> = run(URLRequest(url: httpConfig.allocationsURL))
        
        return publisher.map { arrayOfContainers -> ([Allocation], [ExcludedAllocation]) in
            var allocations = [Allocation]()
            var excludedAllocations = [ExcludedAllocation]()
            arrayOfContainers.forEach {
                switch $0 {
                case .allocation(let allocation):
                    allocations.append(allocation)
                case .excludedAllocation(let exclduedAllocation):
                    excludedAllocations.append(exclduedAllocation)
                }
            }
            return (allocations, excludedAllocations)
        }.eraseToAnyPublisher()
    }

    func submit<T: EvolvEvent>(events: [T]) {
    }

    func submit(data: EvolvBeaconMessage) {
        try? httpClient.post(to: httpConfig.dataURL, with: data)
    }
}
