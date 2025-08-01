//
//  ViewController.swift
//  EvolvAppExample
//
//

import UIKit
import Combine // publish/subscribe framework
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
        let options = EvolvClientOptions(evolvDomain: "participants.evolv.ai", participantID: "EXAMPLE_USER_ID", environmentId: "fa881bd6cc")
        
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
        
        // 1 | Headline Copy
        // Subscribe to "evolv_test.headline" key value.
        self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "evolv_test.headline", type: String.self)
//                .compactMap { $0 ?? "control" } // remove an nil values
                .sink { [weak self] variantCode in
                    guard let self = self else { return }
                    
                    switch variantCode {
                        case "variant_1-1":
                            print("Evolv Variant: variant_1-1")
                            self.dynamicLabel.text = "Variant Text 1"
                        case "variant_1-2":
                            print("Evolv Variant: variant_1-2")
                            self.dynamicLabel.text = "Variant Text 2"
                         default: // show control experience
                            print("Evolv Variant: variant_1-control")
                            self.dynamicLabel.text = "Control text"
                            break;
                    }
                }
                .store(in: &cancellables)

        
        // 2 | Button Location
        // Subscribe to "evolv_test.button_location" key value.
        self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "evolv_test.button_location", type: String.self)
//                .compactMap { $0 ?? "control" }
                .sink { [weak self] variantCode in
                    guard let self = self else { return }

                    switch variantCode {
                        case "variant_2-1":
                            print("Evolv Variant: variant_2-1")
                            self.leftButton.isHidden = false  // show left button
                            self.rightButton.isHidden = true   // hide right button
                        default: // show control experience
                            print("Evolv Variant: variant_2-control")
                            self.leftButton.isHidden = true   // hide left button
                            self.rightButton.isHidden = false  // show right button
                    }
                }
                .store(in: &cancellables)

        
        
          // 3 | Button Color
          // Subscribe to "evolv_test.button_color" key value.
          self.evolvClient
            .get(subscriptionDecodableOnValueForKey: "evolv_test.button_color", type: String.self)
//                .compactMap { $0 ?? "control"}
                .sink { [weak self] variantCode in
                    guard let self = self else { return }
                    
                    switch variantCode {
                        case "variant_3-1":
                            print("Evolv Variant: variant_3-1")
                            self.leftButton.backgroundColor = UIColor.systemGreen
                            self.rightButton.backgroundColor = UIColor.systemGreen
                        case "variant_3-2":
                        print("Evolv Variant: variant_3-2")
                            self.leftButton.backgroundColor = UIColor.systemRed
                            self.rightButton.backgroundColor = UIColor.systemRed
                        default:  // show control experience
                            print("Evolv Variant: variant_3-control")
                            break;
                    }
                }
                .store(in: &cancellables)
    }
    
    // MARK: - Switches for context values.
    @IBAction func loggedInSwitchToggled(_ sender: UISwitch) {
        // Set local or remote context value "yes" for key "logged_in".
        let isLoggedIn = sender.isOn ? "yes" : "no"
        
        evolvClient.set(key: "logged_in", value: isLoggedIn, local: false)
        print("Evolv isLoggedIn:", isLoggedIn)
        // MARK: - Confirm into experiment.
        if sender.isOn {
            // Call confirm.
            evolvClient.confirm()
            print("Evolv user confirmed into experiment")
        } else {
            evolvClient.reevaluateContext()
        }
    }
    
    // MARK: - Bottom buttons tap
    @IBAction func bottomButtonTouchUpInside(_ sender: UIButton) {
        // Emit custom event "goal_achieved" on button tap.
        evolvClient.emit(eventType: "button_click", flush: false)
        print("Evolv button click event triggered")
    }
}
