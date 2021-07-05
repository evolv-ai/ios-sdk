//
//  EvolvPredicate.swift
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

struct EvolvPredicateImpl {
    
    
    
    struct FilterOperations {
        static func contains (a: String, b: String) -> Bool {
            return a.contains(b)
        }
        
        static func defined (a: String?) -> Bool {
            return a != nil
        }
        
        static func equal<T: Equatable> (a: T, b: T) -> Bool {
            return a == b
        }
        
        static func exists (a: String) -> Bool {
            return true
        }
        
        
    }
//    let filterOperations: [String: ()->()]?
    
    public func evaluatePredicate (context: EvolvContext, config: EvolvConfig) {
        
    }
}

enum EvaluationResult {
    
    static let passed = "passed"
    static let failed = "failed"
    static let rejected = "rejected"
    
}


