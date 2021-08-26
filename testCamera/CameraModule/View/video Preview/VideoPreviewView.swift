//
//  VideoPreviewView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 3/8/21.
//

import UIKit
import AVFoundation

class VideoPreviewView: UIView {

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = UIScreen.main.bounds
        videoPreviewLayer.videoGravity = .resizeAspect
        
    }
}
