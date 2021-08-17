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
    var evolvClient: EvolvClient?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise options for the EvolvClient.
        // Provide your credentials for the Evolv API.
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1629111253538", environmentId: "4a64e0b2ab")
        
        // Initialise and populate EvolvClient with desired options.
        // Store this object to work with it later.
        // After the completionHandler is fired and the error is nil,
        // the EvolvClient is ready to be worked with.
        evolvClient = EvolvClientImpl(options: options, completionHandler: { error in
            print("Is Evolv client initialisation successfull? \(error == nil)")
        })
    }
}
