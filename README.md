[![Build Status](https://travis-ci.org/toshi0383/RateTV.svg?branch=travis)](https://travis-ci.org/toshi0383/RateTV)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform](https://img.shields.io/badge/Platform-tvOS%209%2B-blue.svg)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/Carthage/Carthage/master/LICENSE.md) 

RateTV
---
An awesome Rating view for tvOS.

![](./images/screenshot.gif)

Fully configurable from InterfaceBuilder.
![](./images/ib-config.png)

Focused view is invisible and separeted from visible UI.
![](./images/debug-mode.png)

# Requirements
tvOS 9.0+

# RateSlider
RateSlider can be used for user interaction.

## Usage
### Steps
Available Rate steps 
- half step: 0.0, 0.5, 1.0, 1.5...
- full step: 0.0, 1.0, 2.0 ...

If you prefer half step, set `Half Image` property.   
If you prefer full step, clear out `Half Image` property.

### Rate value observing
To observe rate value change, use `RateSlider.rateValueDidChange` callback closure.
```
    @IBOutlet weak var input: RateSlider! {
        didSet {
            input.rateValueDidChange = {
                [weak self] value in
                print("value: \(value)")
            }
        }
    }
```

### Size
RateSlider's size is inferred from image's size using AutoLayout.  
Make sure that every image is in the same size as you expect it to be.

# RateCoreGraphicView
RateCoreGraphicView can display any float values like `0.1`.  
You set full and zero image, then RateCoreGraphicView will draw and clip the image for you.  
Stars are drawn with CoreGraphic API, inside `draw(rect:)`.  
Make sure you set RateCoreGraphicView's size correctly.  
Star's size is inferred from image's size as well as RateSlider.

![rate-core-graphic-view](./images/rate-core-graphic-view.png)

# Install
Use Carthage

# LICENSE
MIT
