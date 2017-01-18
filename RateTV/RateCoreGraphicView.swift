//
//  RateCoreGraphicView.swift
//  RateTV
//
//  Created by toshi0383 on 2017/01/18.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit

public class RateCoreGraphicView: UIView {
    private var _value: RatePoint = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var fullImage: UIImage?
    @IBInspectable public var zeroImage: UIImage?
    @IBInspectable public var spacing: CGFloat = 0
    @IBInspectable public var maxRate: Int = 0
    @IBInspectable public var value: CGFloat = 0 {
        didSet {
            self._value = RatePoint(cgfloat: value)
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 5
    static func create(config: Config) -> RateCoreGraphicView {
        let v = RateCoreGraphicView()
        v.fullImage = config.full
        v.zeroImage = config.zero
        v.maxRate = config.maxRate
        v._value = config.initialValue
        assert(v.maxRate > 0)
        return v
    }

    // MARK: Lifecycle
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let fullImage = fullImage else {
            fatalError("fullImage must not be nil.")
        }
        guard let zeroImage = zeroImage else {
            fatalError("zeroImage must not be nil.")
        }

        // Configurations
        let starSize = CGSize(
            width: floor(fullImage.size.width),
            height: floor(fullImage.size.height)
        )
        let fmaxRate = CGFloat(maxRate)
        let allWidth = (starSize.width*fmaxRate) + (spacing*fmaxRate)
        let allStarWidth = starSize.width*fmaxRate
        let allSize = CGSize(
            width: allWidth,
            height: starSize.height
        )
        let needsClip = _value.point != 0
        let numberOfSpacing: CGFloat = _value.number == 0 ? 0 : CGFloat(_value.number) - 1
        let _boundaryX: CGFloat = (allStarWidth*_value.cgfloatValue/fmaxRate) + spacing*numberOfSpacing
        let boundaryX: CGFloat
        if !needsClip {
            boundaryX = _boundaryX
        } else {
            if _value.point == 5 {
                boundaryX = _boundaryX
            } else {
                // Consider borderWidth
                boundaryX = _value.point > 5 ? _boundaryX - borderWidth : _boundaryX + borderWidth
            }
        }
        let boundaryIndex = Int(ceil(_value.cgfloatValue)) - 1

        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)

        // Draw fullImage
        if _value > 0 {
            if (needsClip) {
                context.saveGState();
                context.clip(to: CGRect(x: 0, y: 0, width: boundaryX+0.1, height: starSize.height))
            }
            for i in (0...boundaryIndex) {
                fullImage.draw(at: CGPoint(x: xOrigin(atIndex: i), y: 0))
            }
            if (needsClip) {
                context.restoreGState();
            }
        }

        // Draw zeroImage
        if _value < maxRate {
            if (needsClip) {
                context.saveGState();
                context.clip(to: CGRect(x: boundaryX, y: 0, width: allSize.width - spacing - boundaryX, height: starSize.height))
            }
            for i in (boundaryIndex..<maxRate) {
                zeroImage.draw(at: CGPoint(x: xOrigin(atIndex: i), y: 0))
            }
            if (needsClip) {
                context.restoreGState();
            }
        }
    }

    public override func updateConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: fullImage!.size.width).isActive = true
        heightAnchor.constraint(equalToConstant: fullImage!.size.height).isActive = true
        super.updateConstraints()
    }

    // MARK: Utilities
    private func xOrigin(atIndex index: Int) -> CGFloat {
        let starsWidth = fullImage!.size.width*CGFloat(index)
        let spaceWidth = spacing*CGFloat(index)
        return starsWidth + spaceWidth
    }
}
