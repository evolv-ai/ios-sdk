//
//  EvolvError.swift
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

public enum EvolvError: Error {
    case generic

    // MARK: - general Errors
    
    case eidIsInvalid(_ key: String)
    case apiVersionIsInvalid(_ key: String)
    case storeIsInitialized
    case contextIsNotInitialized
    case contextIsInitialized
    case environmentIsNotSpecified(_ options: Any)
    case contaminationWithoutReason
    case clientIsInitialized
    case uidIsNotSpecified(_ key: String)
    case variantKeyIsInvalid(_ key: String)

}

// MARK: - CustomStringConvertible

extension EvolvError: CustomStringConvertible {
    public var description: String {
        return "[Evolv:Error] " + self.reason
    }
        
    public var localizedDescription: String {
        return description
    }

    var reason: String {
        var message: String
        
        switch self {
        case .generic:
            message = "Unknown reason."
            
        // MARK: - Evolve Store Error
            
        case .storeIsInitialized:
            message = "The store has already been initialized."
            
        case .apiVersionIsInvalid(let version):
            message = "Unsupported API version \"\(version)\"."
            
            
        // MARK: - Context Error
        
        case .contextIsNotInitialized:
            message = "The evolv context is not initialized."
            
        case .contextIsInitialized:
            message = "The context is already initialized."
            
        // MARK: - Environment Error
            
        case .eidIsInvalid(let key):
            message = "No eid was found for key \"\(key)\"."
            
        case .environmentIsNotSpecified(let options):
            message = "Environment must be specified with \"\(options)\"."
            
        case .contaminationWithoutReason:
            message = "Contamination details must include a reason."
            
        // MARK: - EvolvClient Error
        
        case .clientIsInitialized:
            message = "Client is already initialized."
            
        case .uidIsNotSpecified(let key):
            message = "Uid \"\(key)\" must be specified ."
        
        // MARK: - Predicates Error
        
        case .variantKeyIsInvalid(let key):
            message = "Invalid variant key: \"\(key)\"."
        
        }
        return message
    }
}

// MARK: - LocalizedError

extension EvolvError: LocalizedError {
    public var errorDescription: String? {
        return self.reason
    }
}
