//
//  Extension.swift
//  PHContentSelector
//
//  Created by Mike Ogawa on 2019/09/26.
//  Copyright © 2019 TechMO. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension UIView {
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    func addBorder(toSide side: ViewSide, withColor color: UIColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        let c = color.cgColor
        border.backgroundColor = c
        
        switch side {
        case .Right: border.frame = CGRect(x: frame.width, y: 0, width: thickness, height: frame.height)
        case .Top: border.frame = CGRect(x: 0, y: -thickness, width: frame.width, height: thickness)
        case .Bottom: border.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: thickness)
        default:
            border.frame = CGRect(x: -thickness, y: 0, width: thickness, height: frame.height)
        }
        layer.addSublayer(border)
    }
}




extension UIViewController{
    var view_ratio:CGFloat{
        let orient = UIApplication.shared.statusBarOrientation
        switch orient {
        case .landscapeLeft,.landscapeRight :
            return UIScreen.main.bounds.width / 812.0
        default:
            return UIScreen.main.bounds.height / 812.0
        }
        
    }
    var orient:UIInterfaceOrientation{
        let orient = UIApplication.shared.statusBarOrientation
        return orient
    }
    
    var longer_length:CGFloat{
        return view_ratio * 812
    }
    
    var shorter_length:CGFloat{
        let orient = UIApplication.shared.statusBarOrientation
        switch orient {
        case .landscapeLeft,.landscapeRight :
            return UIScreen.main.bounds.height
        default:
            return UIScreen.main.bounds.width
        }
    }
}


extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}


extension UIImage {
    public convenience init(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}

extension AVPlayer{
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension UIImage {

    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
