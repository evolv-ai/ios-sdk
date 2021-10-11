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
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Initialise options for the EvolvClient.
        // Provide your credentials for the Evolv API
        // and any other desired options, such as initial context, autoconfirm etc.
        let options = EvolvClientOptions(evolvDomain: "participants-stg.evolv.ai", participantID: "80658403_1609111251238", environmentId: "4a64e0b2ab", autoConfirm: false, analytics: true)
        
        // MARK: - Initialise EvolvClient.
        // Populate it with desired options.
        // Store the received object to work with it later.
        EvolvClientFactory(with: options).initializeClient()
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
        // Subscribe to "label" key value.
        // If key is not active, i.e. received value is nil,
        // replace it with default value ("Some text" in this case).
        self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "label", type: String.self)
            .map { $0 ?? "Some text" }
            .sink { [weak self] label in
                self?.dynamicLabel.text = label
            }.store(in: &cancellables)
        
        // Subscribe to "button_active" key value.
        self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "button_shown", type: ButtonActive.self)
            .map { $0 ?? .left }
            .sink { [weak self] buttonActive in
                guard let self = self else { return }
                
                switch buttonActive {
                case .left:
                    self.leftButton.isHidden = false
                    self.rightButton.isHidden = true
                case .right:
                    self.leftButton.isHidden = true
                    self.rightButton.isHidden = false
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Switches for context values.
    @IBAction func loggedInSwitchToggled(_ sender: UISwitch) {
        // MARK: - Confirm into experiment.
        guard sender.isOn else { return }
        
        // Set local or remote context value "yes" for key "loggedIn".
        evolvClient.set(key: "loggedIn", value: "yes", local: false)
        
        // Call confirm.
        evolvClient.confirm()
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
        // Emit custom event "success" on button tap.
        evolvClient.emit(eventType: "success", flush: false)
    }
}
