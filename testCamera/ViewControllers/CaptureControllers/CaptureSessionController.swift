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
    private var zoomState: ZoomState = .wide
    
    override init() {
        super.init()
        initializeCaptureSession()
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func setZoomState(zoomState: ZoomState){
        self.zoomState = zoomState
        setVideoZoomFactor()
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
        self.captureDevice = captureDevice
        guard let captureDeviceInput = getCaptureDeviceInput(captureDevice: captureDevice) else {return}
        guard captureSession.canAddInput(captureDeviceInput) else {
            print(" can not add input")
            return}
        captureSession.addInput(captureDeviceInput)
        captureSession.startRunning()
        setVideoZoomFactor()
    }
    
    func setVideoCaptureDeviceZoom(videoZoomFactor: CGFloat, animated: Bool = false, rate: Float = 0){
        
        guard let captureDevice = captureDevice else {
            return
        }
        do {
            try captureDevice.lockForConfiguration()
        } catch let error {
            print("Failed to get loc configuration on capture device error: \(error)")
        }
        if animated {
            captureDevice.ramp(toVideoZoomFactor: videoZoomFactor, withRate: rate)
        }else {
            captureDevice.videoZoomFactor = videoZoomFactor
        }
        captureDevice.unlockForConfiguration()
    }
    
    func getVideoZoomFactor() -> CGFloat {
        switch zoomState {
        
        case .ultrawide:
            return 1
        case .wide:
            return getWideVideoZoomFactor()
        case .telephoto:
            return getTelephotoVideoZoomFactor()
        }
        
        
    }
    
    func getWideVideoZoomFactor() -> CGFloat {
        guard let captureDevice = captureDevice else {
            return 1
        }
        switch captureDevice.deviceType {
        case .builtInTripleCamera: return 2
        case .builtInDualCamera: return 2
        default: return 1

        }
    }
    
    func getTelephotoVideoZoomFactor() -> CGFloat {
        guard let captureDevice = captureDevice else {
            return 2
        }
        switch captureDevice.deviceType {
        case .builtInTripleCamera: return 3
        case .builtInDualCamera: return 2
        default: return 2

        }
    }
    
    func setVideoZoomFactor() {
        let videoZoomFactor = getVideoZoomFactor()
        setVideoCaptureDeviceZoom(videoZoomFactor: videoZoomFactor)
    }
}
