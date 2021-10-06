//
//  EvolvHttpClient.swift
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

struct EvolvHttpClient {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func postWithPublisher<T: Encodable>(to url: URL, with body: T, _ encoder: JSONEncoder = defaultEncoder()) throws -> AnyPublisher<HTTPURLResponse, URLError> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try encoder.encode(body)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .compactMap {
                print($0.response)
                return $0.response as? HTTPURLResponse
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func post<T: Encodable>(to url: URL, with body: T, _ encoder: JSONEncoder = defaultEncoder()) throws {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try encoder.encode(body)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Evolv: error sending POST request: \(error)")
            } else if let response = response as? HTTPURLResponse, !response.isSuccessStatusCode {
                print("Evolv: error sending POST request: HTTP \(response.statusCode), response: \(String(describing: String(data: data ?? Data(), encoding: .utf8)))")
            }
        }.resume()
    }
    
    private static func defaultEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }
}
