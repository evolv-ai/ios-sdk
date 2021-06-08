//
//  HTTPError.swift
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

public enum HTTPError: Error {
    case nonHTTPResponse
    case requestFailed(Int)
    case serverError(Int)
    case networkingError(Error)
    case decodingError(DecodingError)
    
    public var isRetriable: Bool {
        switch self {
        case .decodingError:
            return false
            
        case .requestFailed(let status):
            let timeoutStatus = 408
            let rateLimitStatus = 429
            return [timeoutStatus, rateLimitStatus].contains(status)
            
        case .serverError, .networkingError, .nonHTTPResponse:
            return true
        }
    }
}

