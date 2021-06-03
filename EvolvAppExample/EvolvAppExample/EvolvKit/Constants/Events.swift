//
//  Constants.swift
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

enum Events {
    static let initialized = "initialized"
    static let confirmed = "confirmed"
    static let contaminated = "contaminated"
    
    enum Context {
        static let initialized = "context.initialized"
        static let changed = "context.changed"
        static let destroyed = "context.destroyed"
        
        enum Value {
            static let removed = "context.value.removed"
            static let added = "context.value.added"
            static let changed = "context.value.changed"
        }
    }
    
    enum Genome {
        static let updated = "genome.updated"
        enum Request {
            static let sent = "genome.request.sent"
            static let received = "genome.request.received"
        }
    }
    
    enum Config {
        static let updated = "config.updated"
        enum Request {
            static let sent = "config.request.sent"
            static let received = "config.request.received"
        }
    }
    
    enum Request {
        static let failed = "request.failed"
    }
   
    enum EffectiveGenome {
        static let updated = "effective.genome.updated"
    }
    
    enum Store {
        static let destroyed = "store.destroyed"
    }
    
    enum Event {
        static let emitted = "event.emitted"
    }
}
