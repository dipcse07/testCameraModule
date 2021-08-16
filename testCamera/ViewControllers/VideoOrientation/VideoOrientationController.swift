//
//  VideoOrientationController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 16/8/21.
//

import Foundation
import UIKit
import AVFoundation
class VideoOrientationController {
    static func getVideoOrientation(interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        switch interfaceOrientation {
        
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
            
        default:
            return nil
        }
    }
}
