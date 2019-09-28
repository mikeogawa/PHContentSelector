//
//  DoubleSliderView.swift
//  PHContentSelector
//
//  Created by Mike Ogawa on 2019/09/26.
//  Copyright © 2019 TechMO. All rights reserved.
//

import WARangeSlider
import UIKit

class DoubleSliderView: UIView {
    
    let rangeSlider: RangeSlider = RangeSlider(frame: CGRect.zero)
    var delegate:RangeDelegate?
    
    func load(){
        backgroundColor = .clear
        let w = frame.width * 0.8
        let h = frame.height * 0.5
        let x = (frame.width - w)/2
        let y = (frame.height - h)/2
        rangeSlider.frame = CGRect(x: x, y: y, width: w, height: h)
        addSubview(rangeSlider)
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)),for: .valueChanged)
    }
    
    func setValue(min:Double,lower:Double,upper:Double,max:Double){
        print("setvalue",min,lower,upper,max)
        rangeSlider.minimumValue = min
        rangeSlider.maximumValue = max
        rangeSlider.lowerValue = lower
        rangeSlider.upperValue = upper
        rangeSlider.updatePreviousValues()
    }
    
    func setValue(array:[Double]){
        setValue(min: array[0], lower:array[1], upper: array[2], max: array[3])
//        rangeSlider.updatePreviousValues()
    }
    
    
    @objc
    func rangeSliderValueChanged(_ rangeSlider: RangeSlider) -> Void {
        if let value = rangeSlider.changedValue {
            print("rangeSlider.lowerValueChanged",rangeSlider.lowerValueChanged)
            delegate?.rangeSlider(didChangeTo: value,
                                  lowerValue: rangeSlider.lowerValueChanged,
                                  higherValue:rangeSlider.upperValueChanged)
        }
        rangeSlider.updatePreviousValues()
    }
}

protocol RangeDelegate {
    func rangeSlider(didChangeTo:Double, lowerValue:Bool, higherValue:Bool)
}

var _previousLowerValue: Double = 0
var _previousUpperValue: Double = 0
var _changedValue: Double? = nil

extension RangeSlider {
    var previousLowerValue: Double {
        get {
            return (objc_getAssociatedObject(self, &_previousLowerValue) ?? 0) as! Double
        }
        set {
            objc_setAssociatedObject(self, &_previousLowerValue, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var previousUpperValue: Double {
        get {
            return (objc_getAssociatedObject(self, &_previousUpperValue) ?? 0) as! Double
        }
        set {
            objc_setAssociatedObject(self, &_previousUpperValue, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var lowerValueChanged: Bool {
        get {
            return self.previousLowerValue != self.lowerValue
        }
    }
    
    var upperValueChanged: Bool {
        get {
            return self.previousUpperValue != self.upperValue
        }
    }
    
    var changedValue: Double? {
        get {
            if self.lowerValueChanged {
                objc_setAssociatedObject(self, &_changedValue, self.lowerValue, .OBJC_ASSOCIATION_RETAIN)
                return self.lowerValue
            } else if self.upperValueChanged {
                objc_setAssociatedObject(self, &_changedValue, self.upperValue, .OBJC_ASSOCIATION_RETAIN)
                return self.upperValue
            } else {
                return (objc_getAssociatedObject(self, &_changedValue)) as! Double?
            }
        }
    }
    
    func updatePreviousValues() -> Void {
        self.previousLowerValue = self.lowerValue
        self.previousUpperValue = self.upperValue
    }
}
