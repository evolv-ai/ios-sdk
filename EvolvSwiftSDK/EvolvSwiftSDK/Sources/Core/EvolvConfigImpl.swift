////
////  EvolvConfig.swift
////
////  Copyright (c) 2021 Evolv Technology Solutions
////
////  Licensed under the Apache License, Version 2.0 (the "License");
////  you may not use this file except in compliance with the License.
////  You may obtain a copy of the License at
////
////  http://www.apache.org/licenses/LICENSE-2.0
////
////  Unless required by applicable law or agreed to in writing, software
////  distributed under the License is distributed on an "AS IS" BASIS,
////  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
////  See the License for the specific language governing permissions and
////  limitations under the License.
////
//
//
//import Foundation
//
///// General configurations for the SDK.
struct EvolvConfigImpl: EvolvConfig {
    
    public enum Default {
        public static let httpScheme: String = HttpConfig.httpScheme
        public static let domain: String = HttpConfig.domain
        public static let version: String = HttpConfig.apiVersion
        public static let environmentId: String = HttpConfig.environmentID
    }

    let httpScheme: String
    let domain: String
    let version: String
    let environmentId: String
    let store: EvolvStore
    let httpClient: EvolvHttpClient
    
    
    
}
