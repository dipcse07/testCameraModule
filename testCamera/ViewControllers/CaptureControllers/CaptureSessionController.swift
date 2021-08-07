//
//  CaptureSessionController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 3/8/21.
//

import Foundation
import AVFoundation

class CaptureSessionController: NSObject {
    private lazy var captureSession = AVCaptureSession()
    
    override init() {
        super.init()
        
        if  let captureDevice = AVCaptureDevice.default(for: .video){
            if let deviceInput = try? AVCaptureDeviceInput(device: captureDevice){
                captureSession.addInput(deviceInput)
            }
            captureSession.startRunning()
        }else {
            print("Failded to capture device input")
        }
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
}
