//
//  CustomAVPlayer.swift
//  PHContentSelector
//
//  Created by Mike Ogawa on 2019/09/27.
//  Copyright © 2019 TechMO. All rights reserved.
//

import UIKit
import AVFoundation

class MoviePlayer {
    private var player:AVPlayer?
    private var preview:UIView!
    
    var delegate:MoviePlayerDelegate?
    
    var isPlaying = true
    var isEnding = false
    
    var min:Double = 0
    var max:Double = 10
    var lower:Double = 0
    var upper:Double = 10
    
    var isMuted:Bool{
        get{
            return player!.isMuted
        }set{
            player!.isMuted = newValue
        }
    }
    
    required init(){
        
    }
    
    convenience init(_ url:URL, preview:UIView) {
        self.init()
        set(url, preview:preview)
    }
    
    func set(_ url:URL, preview:UIView){
        player = AVPlayer(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.preview = preview
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame.size = self.preview.frame.size
        playerLayer.frame.origin = CGPoint(x: 0, y: 0)
        preview.layer.insertSublayer(playerLayer, at: 0)
        
        
        let duration = Double(CMTimeGetSeconds(player!.currentItem!.asset.duration))
        print("duration",CMTimeGetSeconds(player!.currentItem!.asset.duration))
//        print("duration",duration)
        min = 0
        lower = 0
        upper = duration
        max = duration
        isPlaying = false
        isEnding = false
    }
    
    func seek(to:Double, is_low:Bool, is_high:Bool){
        if player == nil{return}
        player?.seek(to: CMTimeMakeWithSeconds(to, preferredTimescale: Int32(NSEC_PER_SEC)))
        isEnding = true
        if is_low {
            lower = to
        }
        if is_high {
            upper = to
            pause()
        }
    }
    
    func play(){
        if player == nil{return}
        if isEnding {
            player?.seek(to: CMTimeMakeWithSeconds(lower, preferredTimescale: Int32(NSEC_PER_SEC)))
            player?.currentItem?.forwardPlaybackEndTime = CMTimeMakeWithSeconds(upper, preferredTimescale: Int32(NSEC_PER_SEC))
            isEnding = false
        }
        player?.play()
        isPlaying = true
    }
    
    func pause(){
        if player == nil{return}
        player?.pause()
        isPlaying = false
    }
    
    @objc
    func didPlayToEndTime() {
        isPlaying = false
        isEnding = true
        delegate?.moviePlayer(ends_at:max)
    }
    
    func return_values() -> [Double]{
        return [min,lower,upper,max]
    }
}


protocol MoviePlayerDelegate{
    func moviePlayer(ends_at:Double)
}
