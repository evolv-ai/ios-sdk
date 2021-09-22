//
//  EvolvContamination.swift
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

struct EvolvContamination: EvolvEvent, Equatable {
    let cid: String
    let uid: String
    let eid: String
    let timeStamp: Date
    let contaminationReason: EvolvContaminationReason?
    var type: String = "contamination"
    
    private enum CodingKeys: String, CodingKey {
        case cid
        case uid
        case eid
        case timeStamp = "timestamp"
        case type
        case contaminationReason
    }
}
