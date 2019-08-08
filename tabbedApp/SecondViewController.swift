//
//  SecondViewController.swift
//  tabbedApp
//
//  Created by James rymer on 6/24/19.
//  Copyright © 2019 James rymer. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet var linkButton: UIButton!
    
    @IBAction func linkButtonClicked(_ sender: UIButton) {
        if let url = URL(string: "https://developers.google.com/calendar/quickstart/js") {
            UIApplication.shared.open(url)
        }
    }
}

