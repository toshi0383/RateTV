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

    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var input: RateSlider! {
        didSet {
            input.rateValueDidChange = {
                [weak self] value in
                print("value: \(value)")
                self?.output.value = value
                self?.outputLabel.text = "\(value)"
            }
        }
    }
    @IBOutlet weak var outputLabel2: UILabel!
    @IBOutlet weak var input2: RateSlider! {
        didSet {
            input2.rateValueDidChange = {
                [weak self] value in
                print("value: \(value)")
                self?.outputLabel2.text = "\(value)"
            }
        }
    }
    @IBOutlet weak var output: RateSlider!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func enableDebug() {
        RateSlider.isDebug = true
    }
}

