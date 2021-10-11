//
//  EvolvClientFactory.swift
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

/// Factory for creating an `EvolvClient` instance.
public final class EvolvClientFactory {
    /// Provided client options.
    public let options: EvolvClientOptions
    
    /// Initializes factory with provided options.
    /// Stores configuration options for EvolvClient ready for initialization.
    /// - Parameter options: Provide desired options for the EvolvClient.
    public init(with options: EvolvClientOptions) {
        self.options = options
    }
    
    /// Initializes EvolvClient with provided options.
    /// - Returns: Publisher for the EvolvClient object.
    public func initializeClient() -> AnyPublisher<EvolvClient, Error> {
        return EvolvClientImpl.initialize(options: options)
    }
}
