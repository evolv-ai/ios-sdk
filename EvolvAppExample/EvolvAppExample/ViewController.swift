//
//  ViewController.swift
//  EvolvAppExample
//
//  Created by Aliaksandr Dvoineu on 31.05.21.
//

import UIKit
import Combine
import EvolvSwiftSDK

class ViewController: UIViewController {
    var evolvClient: EvolvClient!
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise options for the EvolvClient.
        // Provide your credentials for the Evolv API.
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab",
                                         localContext: ["location" : "UA",
                                                        "age" : "25",
                                                        "view" : "home"])
        
        // Initialise and populate EvolvClient with desired options.
        // Store this object to work with it later.
        EvolvClientImpl.initialize(options: options)
            .sink(receiveCompletion: { publisherResult in
                switch publisherResult {
                case .finished:
                    print("Evolv client initialization is finished successfully.")
                    self.showcaseEvolvClient()
                case .failure(let error):
                    print("Evolv client initialization is finished with error: \(error.localizedDescription)")
                }
            }, receiveValue: { evolvClient in
                self.evolvClient = evolvClient
            })
            .store(in: &cancellables)
    }
    
    func showcaseEvolvClient() {
        print("Active keys: \(evolvClient.getActiveKeys())")
        evolvClient.confirm()
    }
}
