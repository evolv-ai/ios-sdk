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

public struct HttpConfig {
    static let httpScheme: String = "https"
    public static let devDomain: String = "participants.evolv.ai"
    public static let stagingDomain: String = "participants-stg.evolv.ai"
    static let apiVersion: String = {
        return "v\(version)"
    }()
    static let version: Int = 1
    static let participantID: String = "80658403_1629111253538"
    static let environmentId: String = "4a64e0b2ab"
    static let configurationEndpoint: String = "configuration.json"
    static let allocationsEndpoint: String = "allocations"
    static let eventsEndpoint: String = "events"
    static let dataEndpoint: String = "data"
    
    /// Creates URL for allocations endpoint.
    ///
    /// - Parameters:
    ///   - domain: production domain used by default
    /// - Returns: allocations URL
    public static func allocationsURL(domain: String = devDomain) -> URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = domain
        components.path = "/\(HttpConfig.apiVersion)/\(HttpConfig.environmentId)/\(HttpConfig.participantID)/\(HttpConfig.allocationsEndpoint)"
        let url = components.url!
        return url
    }
    
    /// Creates URL for configuration endpoint.
    ///
    /// - Parameters:
    ///   - domain: production domain used by default
    /// - Returns: configuration URL
    public static func configurationURL(domain: String = devDomain) -> URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = domain
        components.path = "/\(HttpConfig.apiVersion)/\(HttpConfig.environmentId)/\(HttpConfig.participantID)/\(HttpConfig.configurationEndpoint)"
        let url = components.url!
        return url
    }
    
    /// Creates URL for events endpoint.
    ///
    /// - Parameters:
    ///   - domain: production domain used by default
    /// - Returns: events URL
    public static func eventsURL(domain: String = devDomain) -> URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = domain
        components.path = "/\(HttpConfig.apiVersion)/\(HttpConfig.environmentId)/\(HttpConfig.eventsEndpoint)"
        let url = components.url!
        return url
    }
    
    /// Creates URL for data endpoint.
    ///
    /// - Parameters:
    ///   - domain: production domain used by default
    /// - Returns: data URL
    public static func dataURL(domain: String = devDomain) -> URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = domain
        components.path = "/\(HttpConfig.apiVersion)/\(HttpConfig.environmentId)/\(HttpConfig.dataEndpoint)"
        let url = components.url!
        return url
    }
}
