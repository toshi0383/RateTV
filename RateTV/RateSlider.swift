//
//  RateSlider.swift
//  RateTV
//
//  Created by toshi0383 on 2016/12/22.
//  Copyright © 2016 toshi0383. All rights reserved.
//

import GameController
import UIKit

enum FocusStyle {
    case `default`, custom
}
class RateSlider: UIView {

    // MARK: Properties
    public var value: Float = 0.0 {
        didSet {
            update()
        }
    }

    @IBInspectable public var initialValue: Float = 0.0
    @IBInspectable public var zeroImage: UIImage?
    @IBInspectable public var halfImage: UIImage?
    @IBInspectable public var fullImage: UIImage?
    @IBInspectable public var highlightedColor: UIColor = .lightGray
    @IBInspectable public var originalColor: UIColor = .clear
    @IBInspectable public var spacing: CGFloat = 0
    @IBInspectable public var cornerRadius: CGFloat = 5
    @IBInspectable public var maxRate: Int = 5
    @IBInspectable public var focusStyle: FocusStyle = .default

    private var stackview: RateStackView?
    private var invisibleStackview: InvisibleFocusStackView?
    private var config: Config?

    // MARK: Lifecycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        layer.cornerRadius = cornerRadius
        update()
    }

    private func update() {
        if config == nil {
            self.config = Config(
                zero: zeroImage, half: halfImage, full: fullImage,
                spacing: spacing, maxRate: maxRate
            )
        }
        updateVisible()
        updateInvisible()
    }
    private func updateVisible() {
        if stackview == nil {
            let stackview = RateStackView.create(
                config: config!
            )
            addSubview(stackview)
            self.stackview = stackview
            stackview.value = initialValue
        } else {
            stackview?.value = value
        }
    }
    private func updateInvisible() {
        guard let full = fullImage else {
            fatalError("fullImage must not be nil.")
        }
        if invisibleStackview == nil {
            let v: InvisibleFocusStackView = InvisibleFocusStackView
                .create(maxRateDoubled: config!.maxRateDoubled,
                        imageSize: full.size
                ) {
                    [weak self] index in
                    self?.stackview?.value = Float(index)/2
                }
            addSubview(v)
            self.invisibleStackview = v
        } else {
            invisibleStackview?.focusedIndex = Int(value)*2
        }
    }
    func isRateSliderContext(_ context: UIFocusUpdateContext) -> Bool {
        guard let v = context.nextFocusedView else {
            return false
        }
        return v.isDescendant(of: self) && v is InvisibleFocusView
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            [weak self] in
            if let b = self?.isRateSliderContext(context), b {
                self?.focus()
            } else {
                self?.unfocus()
            }
        }, completion: nil)
    }
    private func focus() {
        backgroundColor = highlightedColor
    }
    private func unfocus() {
        backgroundColor = originalColor
    }
    
}

// MARK: - Config
struct Config {
    let zero: UIImage?
    let half: UIImage?
    let full: UIImage?
    let spacing: CGFloat
    /// Note that this is multiplied.
    let maxRate: Int
    var maxRateDoubled: Int {
        return maxRate * 2
    }
}

// MARK: - Visible
class RateStackView: UIStackView {
    private var config: Config?
    static func create(config: Config) -> RateStackView {
        let items: [Item] = (0..<config.maxRate).map{
            _ in
            let v = Item()
            return v
        }
        let v = RateStackView(arrangedSubviews: items)
        v.axis = .horizontal
        v.spacing = config.spacing
        v.config = config
        return v
    }
    var value: Float {
        set(newValue) {
            assert(newValue <= Float(config!.maxRate))
            let items = arrangedSubviews.flatMap{$0 as? Item}
            let compare = Int(round(newValue*10)) // 0-50
            for (i, v) in items.enumerated() {
                let expectedZero: Int = i*10+3
                let expectedFull: Int = (i+1)*10-3
                if compare < expectedZero {
                    v.value = 0.0
                    if let image = config?.zero {
                        v.image = image
                    }
                } else if expectedZero <= compare && compare <= expectedFull {
                    if let image = config?.half {
                        v.value = 0.5
                        v.image = image
                    }
                } else {
                    v.value = 1.0
                    if let image = config?.full {
                        v.image = image
                    }
                }
                v.sizeToFit()
            }
        }
        get {
            return arrangedSubviews.flatMap{$0 as? Item}
                .map{$0.value}
                .reduce(0.0, +)
        }
    }
    override func updateConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        if let parent = superview {
            centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        }
        super.updateConstraints()
    }
}

class Item: UIImageView {
    var value: Float = 0.0
    override func updateConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        super.updateConstraints()
    }
}

// MARK: - Invisible
class InvisibleFocusStackView: UIStackView {
    private var maxRateDoubled: Int = 0
    var focusedIndex: Int = 0
    var focusedIndexDidChange: ((Int)->())?
    private var imageSize: CGSize = .zero
    static func create
        (maxRateDoubled: Int, imageSize: CGSize, focusedIndexDidChange: ((Int)->())?)
        -> InvisibleFocusStackView
    {
        let views: [InvisibleFocusView] = (0...maxRateDoubled).map{_ in
            let v = InvisibleFocusView()
            v.size = imageSize
            return v
        }
        let v =  InvisibleFocusStackView(arrangedSubviews: views)
        v.maxRateDoubled = maxRateDoubled
        v.axis = .horizontal
        v.spacing = 0
        v.focusedIndexDidChange = focusedIndexDidChange
        return v
    }
    override var preferredFocusedView: UIView? {
        return arrangedSubviews[focusedIndex]
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let next = context.nextFocusedView else {
            return
        }
        if let index = arrangedSubviews.index(of: next) {
            focusedIndex = index
            focusedIndexDidChange?(index)
        }
    }
    override func updateConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        if let parent = superview {
            centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        }
        super.updateConstraints()
    }
}

class InvisibleFocusView: UIView {
    var size: CGSize = .zero
    override var canBecomeFocused: Bool {
        return true
    }
    override func updateConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
        super.updateConstraints()
    }
}
