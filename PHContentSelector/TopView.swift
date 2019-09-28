//
//  TopView.swift
//  PHContentSelector
//
//  Created by Mike Ogawa on 2019/09/28.
//  Copyright © 2019 TechMO. All rights reserved.
//

import UIKit

class TopView: UIView {
    
    let playImage = UIImageView(image: UIImage(named: "playButton"))
    
    func load(){
        
    }
    
    func prepare(){
        pause()
    }
    
    func play(){
        playImage.removeFromSuperview()
    }
    
    func pause(){
        set()
        addSubview(playImage)
    }
    
    func set(){
        playImage.frame.size = CGSize(width: 100, height: 100)
        playImage.center = CGPoint(x: frame.width/2, y: frame.height/2)
        playImage.contentMode = .scaleAspectFit
    }
    
    func orient(){
        set()
    }

}
