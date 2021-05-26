//
//  EvolvContext.swift
//  Example
//
//  Created by Aliaksandr Dvoineu on 14.05.21.
//  Copyright © 2021 Evolv. All rights reserved.
//

import Foundation
import EvolvKit

final class EvolvClientHelper {
    
    static var shared: EvolvClientHelper = {
        let helper = EvolvClientHelper()
        _ = helper.client
        return helper
    }()
    
    lazy var client: EvolvClient = {
        /// When you receive the fetched json from the participants API, it will be as type String.
        /// If you use the DefaultEvolvHttpClient, the string will be parsed to EvolvRawAllocation array
        /// (required data type for EvolvAllocationStore).
        let store: EvolvAllocationStore = CustomAllocationStore()
        let httpClient: EvolvHttpClient = DefaultEvolvHttpClient()
        
        /// Build config with custom timeout and custom allocation store.
        /// Set client to any one of your environmentIds. sandbox is an example id.
        let config = EvolvConfig.builder(environmentId: "8b50696b6c", httpClient: httpClient)
            .set(allocationStore: store)
            .build()
        
        /// set error or debug logLevel for debugging
        config.set(logLevel: .error)
        
        /// Initialize the client with a stored user
        /// fetches allocations from Evolv, and stores them in a custom store
        let client = EvolvClientFactory.createClient(config: config,
                                                     participant: EvolvParticipant.builder().set(userId: "C51EEAFC-724D-47F7-B99A-F3494357F164").build(),
                                                     delegate: self)
//        
        /// Initialize the client with a new user
        /// Uncomment this line if you prefer this initialization.
//         let client = EvolvClientFactory.createClient(config: config)
        
        return client
    }()
    
    var didChangeClientStatus: ((_ clientStatus: EvolvClientStatus) -> Void)?
    
    private init() {}
    
}

extension EvolvClientHelper: EvolvClientDelegate {
    
    func didChangeClientStatus(_ status: EvolvClientStatus) {
        didChangeClientStatus?(status)
    }
    
}
