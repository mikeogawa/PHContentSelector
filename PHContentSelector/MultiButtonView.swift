//
//
//  Created by Mike Ogawa on 2019/08/25.
//  Copyright © 2019 TechMO. All rights reserved.
//

import UIKit

class MultiButtonsView: UIView {
    
    var buttons = Array<UIButton>()
    
    var previousButton:UIButton?
    
    var default_list = Array<String>()
    
    var current_idx:Int = 0
    
    var delegate:MultiButtonDelegate?
    
    convenience init(_ variable_list:Array<String>){
        self.init()
        set_variable(variable_list)
        load()
    }
    
    func set_variable(_ variable_list:Array<String>){
        default_list = variable_list
        var list = Array<UIButton>()
        for _ in 0..<variable_list.count{
            list.append(UIButton())
        }
        buttons = list
    }
    
    func load(){
        prepareSelf()
        prepareButtons()
        prepareInitset()
    }
    
    func orientLoad(){
        prepareButtons()
    }

    func prepareSelf(){
        backgroundColor = .clear
        addBorder(toSide: .Top, withColor: .gray, andThickness: 2)
        addBorder(toSide: .Bottom, withColor: .gray, andThickness: 2)
    }
    
    func prepareButtons(){
        let step = 1/CGFloat(default_list.count)
        let ratio:[CGFloat] = (1...default_list.count).map {CGFloat($0) * step}
        let frame_w = frame.width
        let frame_h = frame.height
        let center_xs = ratio.map {($0 - step/2) * frame_w}
        print("setting",ratio,center_xs)
        for (i,button) in buttons.enumerated(){
            button.frame.size = CGSize(width: frame_w * 0.2, height: frame.height*0.8)
            button.center.y = frame_h/2
            button.center.x = center_xs[i]
            button.setTitle(default_list[i], for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: frame_h * 0.5)
            button.layer.cornerRadius = button.frame.height/2
            
            if default_list.count > subviews.count {
                print("passed")
                button.tag = i
                button.addTarget(self, action: #selector(button_tapped(_:)), for: .touchUpInside)
                addSubview(button)
            }
            
        }
    }
    
    func orientButtons(){
        let step = 1/CGFloat(default_list.count)
        let ratio:[CGFloat] = (1...default_list.count).map {CGFloat($0) * step}
        let frame_w = frame.width
        let frame_h = frame.height
        let center_xs = ratio.map {($0 - step/2) * frame_w}
        for (i,button) in buttons.enumerated(){
            button.frame.size = CGSize(width: frame_w * 0.2, height: frame.height*0.8)
            button.center.y = frame_h/2
            button.center.x = center_xs[i]
        }
    }
    
    @objc
    func button_tapped(_ button:UIButton){
        inverseColor(previousButton!, state: .off)
        inverseColor(button, state: .on)
        previousButton = button
        print("previousButton.tag",previousButton!.tag)
        current_idx = button.tag
        delegate?.tapped(button,tag)
        
    }
    
    enum buttonswitch{
        case on, off
    }
    
    func inverseColor(_ button:UIButton, state:buttonswitch){
        if state == .on{
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .orange
        } else {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .clear
        }
    }
    
    func prepareInitset(){
        for button in buttons[0..<buttons.count]{
            inverseColor(button, state: .off)
        }
        inverseColor(buttons[current_idx], state: .on)
        previousButton = buttons[current_idx]
    }
    
    func addTargetToAll(_ selector:Selector){
        for button in buttons{
            button.addTarget(self, action: selector, for: .touchUpInside)
        }
    }
    
}


protocol MultiButtonDelegate {
    func tapped(_ button:UIButton, _ tag:Int)
}
