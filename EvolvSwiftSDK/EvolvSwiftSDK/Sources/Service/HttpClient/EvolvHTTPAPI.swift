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

import Combine

struct EvolvHTTPAPI {
    let httpClient = EvolvHttpClient()
    let httpConfig: HttpConfig
    let session = URLSession.shared
    
    init(options: EvolvClientOptions) {
        self.httpConfig = HttpConfig(options: options)
    }
    
    /// Fetches data from a URL
    /// - Parameter url: URL from where to fetch data.
    /// - Returns: publisher for the data task.
    func fetchData(for url: URL) -> AnyPublisher<Data?, HTTPError> {
        return session.dataTaskPublisher(for: url)
            .mapError { HTTPError.networkingError($0) }
            .print()
            .tryMap {
                guard let httpResponse = $0.response as? HTTPURLResponse else {
                    print("Evolv: Request failed \($0.response)")
                    throw HTTPError.nonHTTPResponse
                }
                guard httpResponse.statusCode == 200 else {
                    print("Evolv: Request failed \(httpResponse.statusCode) for \(httpResponse)")
                    throw HTTPError.requestFailed(httpResponse.statusCode)
                }
                return $0.data
            }
            .mapError { $0 as! HTTPError }
            .eraseToAnyPublisher()
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
    
    func allocations() -> AnyPublisher<[Allocation], Error> {
        return run(URLRequest(url: httpConfig.allocationsURL))
    }
}
