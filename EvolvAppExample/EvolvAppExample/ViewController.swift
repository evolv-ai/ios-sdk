//
//  ViewController.swift
//  EvolvAppExample
//
//  Created by Aliaksandr Dvoineu on 31.05.21.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cancellable = fetchData()
            .catch {(error: HTTPError) -> Just<String?> in
                print("\(error.localizedDescription)")
                return Just(nil)
            }
            .sink {
                if let body = $0 {
                    print(body)
                }
            }      
    }
}

