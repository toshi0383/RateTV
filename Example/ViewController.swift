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
                self?.outputCoreGraphicView2.value = CGFloat(value)
            }
        }
    }
    @IBOutlet weak var outputCoreGraphicView2: RateCoreGraphicView!
    @IBOutlet weak var output: RateSlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        input.value = 5.0
        input2.value = 2.0
    }

    @IBAction func enableDebug() {
        RateSlider.isDebug = true
    }
}
