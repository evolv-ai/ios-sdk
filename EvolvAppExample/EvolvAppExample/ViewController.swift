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
    
    @IBOutlet var switches: [UISwitch]!
    @IBOutlet weak var dynamicLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Initialise options for the EvolvClient.
        // Provide your credentials for the Evolv API
        // and any other desired options, such as initial context, autoconfirm etc.
        let options = EvolvClientOptions(evolvDomain: "participants.evolv.ai", participantID: "EXAMPLE_USER_ID", environmentId: "fa881bd6cc", autoConfirm: false, analytics: true)
        
        // MARK: - Initialise EvolvClient.
        // Populate it with desired options.
        // Store the received object to work with it later.
        EvolvClientImpl.initialize(options: options)
            .sink(receiveCompletion: { publisherResult in
                switch publisherResult {
                case .finished:
                    print("Evolv client initialization is finished successfully.")
                    self.evolvClientDidInitialize()
                case .failure(let error):
                    print("Evolv client initialization is finished with error: \(error.localizedDescription)")
                }
            }, receiveValue: { evolvClient in
                self.evolvClient = evolvClient
            })
            .store(in: &cancellables)
    }
    
    // MARK: - EvolvClient is initialized.
    func evolvClientDidInitialize() {
        self.switches.forEach { $0.isEnabled = true }
        
        self.subscribeToKeys()
    }
    
    func subscribeToKeys() {
        // Subscribe to "app_entry.example_text" key value.
        // If key is not active, i.e. received value is nil,
        // replace it with default value ("Some text" in this case).
        self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "app_entry.example_text", type: String.self)
            .compactMap { $0 ?? "Alternative text" }
            .sink { [weak self] label in
                self?.dynamicLabel.text = label
            }.store(in: &cancellables)
        
        // Subscribe to "button_active" key value.
        self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "app_entry.button_choice", type: ButtonActive.self)
            .compactMap { $0 ?? .button2 }
            .sink { [weak self] buttonActive in
                guard let self = self else { return }
                
                switch buttonActive {
                case .button1:
                    self.button1.isHidden = false
                    self.button2.isHidden = true
                case .button2:
                    self.button1.isHidden = true
                    self.button2.isHidden = false
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Switches for context values.
    @IBAction func loggedInSwitchToggled(_ sender: UISwitch) {
        // Set local or remote context value "yes" for key "logged_in".
        let isLoggedIn = sender.isOn ? "yes" : "no"
        
        evolvClient.set(key: "logged_in", value: isLoggedIn, local: false)
        
        // MARK: - Confirm into experiment.
        if sender.isOn {
            // Call confirm.
            evolvClient.confirm()
        }
    }
    
    @IBAction func ageIs25Toggled(_ sender: UISwitch) {
        if sender.isOn {
            evolvClient.set(key: "age", value: "25", local: false)
        } else {
            evolvClient.remove(key: "age")
        }
    }
    
    @IBAction func nameIsAlexToggled(_ sender: UISwitch) {
        if sender.isOn {
            evolvClient.set(key: "name", value: "Alex", local: false)
        } else {
            evolvClient.remove(key: "name")
        }
    }
    
    // MARK: - Bottom buttons tap
    @IBAction func bottomButtonTouchUpInside(_ sender: UIButton) {
        // Emit custom event "goal_achieved" on button tap.
        evolvClient.emit(eventType: "goal_achieved", flush: false)
    }
}
