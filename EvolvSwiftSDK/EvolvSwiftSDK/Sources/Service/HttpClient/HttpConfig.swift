//
//  Config.swift
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

struct HttpConfig {
    public let options: EvolvClientOptions
    
    static let httpScheme: String = "https"
    static let configurationEndpoint: String = "configuration.json"
    static let allocationsEndpoint: String = "allocations"
    static let eventsEndpoint: String = "events"
    static let dataEndpoint: String = "data"
    
    /// Creates URL for allocations endpoint.
    ///
    /// - Parameters:
    /// - Returns: allocations URL
    var allocationsURL: URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = options.evolvDomain
        components.path = "/v\(options.apiVersion)/\(options.environmentId)/\(options.participantID)/\(HttpConfig.allocationsEndpoint)"
        let url = components.url!
        return url
    }
    
    /// Creates URL for configuration endpoint.
    ///
    /// - Parameters:
    /// - Returns: configuration URL
    public var configurationURL: URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = options.evolvDomain
        components.path = "/v\(options.apiVersion)/\(options.environmentId)/\(options.participantID)/\(HttpConfig.configurationEndpoint)"
        let url = components.url!
        return url
    }
    
    /// Creates URL for events endpoint.
    ///
    /// - Parameters:
    /// - Returns: events URL
    public var eventsURL: URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = options.evolvDomain
        components.path = "/v\(options.apiVersion)/\(options.environmentId)/\(HttpConfig.eventsEndpoint)"
        let url = components.url!
        return url
    }
    
    /// Creates URL for data endpoint.
    ///
    /// - Parameters:
    /// - Returns: data URL
    public var dataURL: URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = options.evolvDomain
        components.path = "/v\(options.apiVersion)/\(options.environmentId)/\(HttpConfig.dataEndpoint)"
        let url = components.url!
        return url
    }
}
