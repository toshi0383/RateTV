//
//  GenerateCodeDemoViewController.swift
//  RateTV
//
//  Created by toshi0383 on 2017/01/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import RateTV
import UIKit

class GenerateCodeDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRateCoreGraphicView()
        setupRateSlider()
        setupRateCoreGraphicViewInsideUIStackView()
    }
    private func setupRateSlider() {
        let slider = RateSlider()
        let origin = CGPoint(x: 0, y: 100)
        let size = CGSize(width: 60*5+5*4, height: 60)
        slider.frame = CGRect(origin: origin, size: size)
        slider.maxRate = 5
        slider.fullImage = UIImage(named: "full.png")
        slider.zeroImage = UIImage(named: "zero.png")
        view.addSubview(slider)
        slider.value = 3
    }
    private func setupRateCoreGraphicView() {
        let views = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]
            .map{self.create($0)}
        for (i, v) in views.enumerated() {
            let origin = CGPoint(x: i*(60+5), y: 300)
            let size = CGSize(width: 60, height: 60)
            v.frame = CGRect(origin: origin, size: size)
            view.addSubview(v)
            v.setNeedsDisplay()
        }
    }
    private func setupRateCoreGraphicViewInsideUIStackView() {
        let views = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]
            .map{self.create($0)}
        let stackview = UIStackView(arrangedSubviews: views)
        stackview.axis = .horizontal
        stackview.spacing = 5
        view.addSubview(stackview)
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    private func create(_ value: CGFloat) -> UIView {
        let rcgv = RateCoreGraphicView()
        rcgv.backgroundColor = .clear
        rcgv.borderWidth = 5
        rcgv.fullImage = UIImage(named: "full.png")
        rcgv.zeroImage = UIImage(named: "zero.png")
        rcgv.spacing = 5
        rcgv.maxRate = 1
        rcgv.value = value
        return rcgv
    }
}
