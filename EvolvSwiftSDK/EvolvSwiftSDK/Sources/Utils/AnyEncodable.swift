//
//  AnyEncodable.swift
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

struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void
    #if DEBUG
    let _object: Any
    #endif
    
    init<T: Encodable>(_ wrapped: T) {
        encode = wrapped.encode
        #if DEBUG
        _object = wrapped
        #endif
    }
    
    init(_ wrapped: Encodable) {
        encode = wrapped.encode
        #if DEBUG
        _object = wrapped
        #endif
    }

    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
