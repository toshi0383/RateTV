//
//  ViewController.swift
//  Example
//
//  Created by toshi0383 on 2016/12/22.
//  Copyright © 2016 toshi0383. All rights reserved.
//

import RateTV
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func enableDebug() {
        RateSlider.isDebug = true
    }
}

