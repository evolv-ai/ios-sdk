//
//  EvolvContext.swift
//  Example
//
//  Created by Aliaksandr Dvoineu on 14.05.21.
//  Copyright © 2021 Evolv. All rights reserved.
//

import EvolvKit

/// A custom in memory allocation store, this is a very basic example. One would likely use
/// sqlLite or an application storage implementation instead.
public class CustomAllocationStore: EvolvAllocationStore {
    
    private var allocations: [String: [EvolvRawAllocation]] = [:]
    
    public func get(_ participantId: String) -> [EvolvRawAllocation] {
        return allocations[participantId] ?? []
    }
    
    public func put(_ participantId: String, _ allocations: [EvolvRawAllocation]) {
        self.allocations.updateValue(allocations, forKey: participantId)
    }
    
}
