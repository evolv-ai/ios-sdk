//
//  EvolvContext.swift
//  Example
//
//  Created by Aliaksandr Dvoineu on 13.05.21.
//  Copyright © 2021 Evolv. All rights reserved.
//

import UIKit
import EvolvKit

class ViewController: UIViewController {
  
  @IBOutlet weak var textLabel: UILabel!
  
  @IBOutlet weak var button: UIButton!
  
  private let evolvClient = EvolvClientHelper.shared.client
  
  @IBAction func didPressButton(_ sender: Any) {
    evolvClient.emitEvent(forKey: "Conversion")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    button?.titleLabel?.font = .systemFont(ofSize: 24)
    textLabel?.font = .systemFont(ofSize: 24)
    view.backgroundColor = .systemGray
    
    // MARK: Evolv subscribe
    
    evolvClient.subscribe(forKey: "home.cta_text", defaultValue: __N("Default Text"), closure: changeDefaultButtonText)
    
    evolvClient.subscribe(forKey: "next.layout", defaultValue: __N("Initial Layout"), closure: setLayout)
    
//    get the context and update it
//    set the value for view
//    otherwise no confirmation
    
    evolvClient.confirm()
  }
  
  lazy var changeDefaultButtonText: (EvolvRawAllocationNode) -> Void = { buttonTextOption in
    DispatchQueue.main.async { [weak self] in
      self?.button.setTitle(buttonTextOption.stringValue, for: .normal)
    }
  }
  
  lazy var setLayout: (EvolvRawAllocationNode) -> Void = { layoutOption in
    DispatchQueue.main.async { [weak self] in
      
      switch (layoutOption) {
      case "Layout 1":
        self?.textLabel.text = layoutOption.stringValue
        self?.view.backgroundColor = .systemBlue
        self?.textLabel?.font = .systemFont(ofSize: 30)
      case "Default Layout":
        self?.textLabel.text = layoutOption.stringValue
        self?.view.backgroundColor = .systemGreen
        self?.textLabel?.font = .systemFont(ofSize: 26)
      default:
        self?.textLabel.text = "Initial View"
      }
    }
  }
}

extension ViewController {
  
  private func setDefaultButtonColor(_ color: EvolvRawAllocationNode) {
    DispatchQueue.main.async { [weak self] in
      let backgroundColor = UIColor(hexString: color.stringValue)
      
      self?.button.backgroundColor = backgroundColor
      
      if backgroundColor.isLight() ?? false {
        self?.button.setTitleColor(.black, for: .normal)
      } else {
        self?.button.setTitleColor(.white, for: .normal)
      }
    }
  }
}
