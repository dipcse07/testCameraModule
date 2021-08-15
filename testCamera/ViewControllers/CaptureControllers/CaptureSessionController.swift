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
    private var captureDevice:AVCaptureDevice?
    
    override init() {
        super.init()
        initializeCaptureSession()
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
}
private extension CaptureSessionController {
    func getVideoCaptureDevice() -> AVCaptureDevice? {
        
        if let tripleCamera = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back){
            return tripleCamera
        }
        if let dualWidthCamera = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back){
            return dualWidthCamera
        }
        if let dualCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back){
            return dualCamera
    }
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back){
            return wideAngleCamera
            
        }
        return nil
}
    
    func getCaptureDeviceInput(captureDevice: AVCaptureDevice) -> AVCaptureDeviceInput? {
        do {
        let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            return captureDeviceInput
        } catch let error {
            print("Failed To Get Capture device Input with error: \(error)")
        }
        return nil
    }
    
    func initializeCaptureSession() {
        guard let captureDevice = getVideoCaptureDevice() else {return}
        guard let captureDeviceInput = getCaptureDeviceInput(captureDevice: captureDevice) else {return}
        guard captureSession.canAddInput(captureDeviceInput) else {return}
        captureSession.startRunning()
    }
}
