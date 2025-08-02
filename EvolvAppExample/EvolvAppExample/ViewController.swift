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
        // Provide your Evolv environment ID
        let options = EvolvClientOptions(participantID: "EXAMPLE_USER_ID3", environmentId: "fa881bd6cc")
        
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
        // Subscribe to "app_entry.example_text" key value.
        // If key is not active, i.e. received value is nil,
        // replace it with default value ("Some text" in this case).
        self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "app_entry.example_text", type: String.self)
            .handleEvents(receiveOutput: { value in
                print("example_text from Evolv:", value ?? "nil")
            })
            .compactMap { $0 ?? "Some text" }
            .sink { [weak self] label in
                self?.dynamicLabel.text = label
            }.store(in: &cancellables)
        
        // Subscribe to "button_active" key value.
        self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "app_entry.button_choice", type: ButtonActive.self)
            .handleEvents(receiveOutput: { value in
                print("button_choice from Evolv:", value?.rawValue ?? "nil")
            })
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
