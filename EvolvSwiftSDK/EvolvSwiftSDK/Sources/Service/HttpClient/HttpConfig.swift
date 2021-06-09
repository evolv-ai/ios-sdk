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
    static let domain: String = "participants.evolv.ai"
    static let apiVersion: String = "v1"
    static let participantID: String = "C51EEAFC-724D-47F7-B99A-F3494357F164"
    static let environmentID: String = "8b50696b6c"
    static let configurationEndpoint: String = "configurations.json"
    static let allocationsEndpoint: String = "allocations"
    static let eventsEndpoint: String = "events"
    static let dataEndpoint: String = "data"
    
    public static func allocationsURL() -> URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = HttpConfig.domain
        components.path = "/\(HttpConfig.apiVersion)/\(HttpConfig.environmentID)/\(HttpConfig.participantID)/\(HttpConfig.allocationsEndpoint)"
        let url = components.url!
        return url
    }
    
    public static func configurationURL() -> URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = HttpConfig.domain
        components.path = "/\(HttpConfig.apiVersion)/\(HttpConfig.environmentID)/\(HttpConfig.participantID)/\(HttpConfig.configurationEndpoint)"
        let url = components.url!
        return url
    }
    
    public static func eventsURL() -> URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = HttpConfig.domain
        components.path = "/\(HttpConfig.apiVersion)/\(HttpConfig.environmentID)/\(HttpConfig.eventsEndpoint)"
        let url = components.url!
        return url
    }
    
    public static func dataURL() -> URL {
        var components = URLComponents()
        components.scheme = HttpConfig.httpScheme
        components.host = HttpConfig.domain
        components.path = "/\(HttpConfig.apiVersion)/\(HttpConfig.environmentID)/\(HttpConfig.dataEndpoint)"
        let url = components.url!
        return url
    }
    
    
}
