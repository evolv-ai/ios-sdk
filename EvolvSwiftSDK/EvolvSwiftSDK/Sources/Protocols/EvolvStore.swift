//
//  EvolvStore.swift
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

/// A type that can store and retrieve participant's allocations.
protocol EvolvStore {
    var activeKeys: CurrentValueSubject<Set<String>, Never> { get }
    
    var activeVariantKeys: CurrentValueSubject<Set<String>, Never> { get }
    
    var evolvAllocations: [Allocation] { get }
    var evolvConfiguration: Configuration { get }
    var evolvContext: EvolvContextContainer { get set }
    
    func isActive(key: String) -> Bool
    
    func getActiveKeys() -> Set<String>
    
    func reevaluateContext()
    
    @discardableResult
    func set(key: String, value: Any, local: Bool) -> Bool
}
