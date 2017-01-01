//
//  RateSlider.swift
//  RateTV
//
//  Created by toshi0383 on 2016/12/22.
//  Copyright © 2016 toshi0383. All rights reserved.
//

import GameController
import UIKit

public enum FocusStyle {
    case `default`, custom
}
public class RateSlider: UIView {

    public static var isDebug: Bool = false
    public var rateValueDidChange: ((Float)->())?

    // MARK: Properties
    public var value: Float = 0.0 {
        didSet {
            update()
            rateValueDidChange?(value)
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
    @IBInspectable public var labelize: Bool = false

    private var isHalfStep: Bool {
        return halfImage == nil
    }
    private var stackview: RateStackView?
    private var invisibleStackview: InvisibleFocusStackView?
    private var config: Config?

    // MARK: Lifecycle
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
    }

    override public func didMoveToWindow() {
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
        if !labelize {
            updateInvisible()
        }
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
        if invisibleStackview == nil {
            let v: InvisibleFocusStackView = InvisibleFocusStackView
                .create(config: config!) {
                    [weak self] value in
                    self?.value = value
                }
            addSubview(v)
            self.invisibleStackview = v
        }
    }

    // MARK: UIFocusEnvironment
    func isRateSliderContext(_ context: UIFocusUpdateContext) -> Bool {
        guard let v = context.nextFocusedView else {
            return false
        }
        return v.isDescendant(of: self) && v is InvisibleFocusView
    }
    override public func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard focusStyle == .default else {
            return
        }
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
    let maxRate: Int
    var maxRateDoubled: Int {
        return maxRate * 2
    }
    var isHalfStep: Bool {
        return half != nil
    }
    var stepCount: Int {
        return isHalfStep ? maxRateDoubled : maxRate
    }
    var stepSpacing: CGFloat {
        return isHalfStep ? spacing/2 : spacing
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
    var focusedIndexDidChange: ((Float)->())?
    var config: Config?
    private var imageSize: CGSize = .zero
    static func create
        (config: Config, focusedIndexDidChange: ((Float)->())?)
        -> InvisibleFocusStackView
    {
        guard let full = config.full else {
            fatalError("config.full must not be nil.")
        }
        let size = config.isHalfStep ?
            CGSize(width: full.size.width/2, height: full.size.height) : full.size
        let views: [InvisibleFocusView] = (0...config.stepCount).map{_ in
            let v = InvisibleFocusView()
            v.size = size
            return v
        }
        let v =  InvisibleFocusStackView(arrangedSubviews: views)
        v.config = config
        v.maxRateDoubled = config.maxRateDoubled
        v.axis = .horizontal
        v.spacing = config.stepSpacing
        v.focusedIndexDidChange = focusedIndexDidChange
        return v
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let next = context.nextFocusedView, next.isDescendant(of: self) {
            for v in arrangedSubviews {
                v.isUserInteractionEnabled = true
            }
        } else if let previous = context.previouslyFocusedView, previous.isDescendant(of: self) {
            let disabled = arrangedSubviews.filter{$0 != previous}
            for v in disabled {
                v.isUserInteractionEnabled = false
            }
        }
        guard let next = context.nextFocusedView, next.isDescendant(of: self) else {
            return
        }
        if let index = arrangedSubviews.index(of: next) {
            focusedIndexDidChange?(config!.isHalfStep ? Float(index)/2 : Float(index))
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
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if RateSlider.isDebug {
            if context.nextFocusedView == self {
                backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            } else {
                backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2)
            }
        }
    }
    override func updateConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
        super.updateConstraints()
    }
}
