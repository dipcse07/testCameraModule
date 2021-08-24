//
//  CaptureSessionController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 3/8/21.
//

import Foundation
import AVFoundation

enum CameraType {
    case ultrawide
    case wide
    case telephoto
}

enum CameraPosition{
    case front
    case back
}

typealias CaptureSessionInitializedCompletionHandler = () -> Void


class CaptureSessionController: NSObject {
    private lazy var captureSession = AVCaptureSession()
    private var captureDevice:AVCaptureDevice?
    private var captureDeviceInput:AVCaptureDeviceInput?
    private var zoomState: ZoomState = .wide
    private var cameraPosition = CameraPosition.back

//    init(completionHandler: @escaping CaptureSessionInitializedCompletionHandler){
//        super.init()
//        captureDevice = getBackVideoCaptureDevice()
//        initializeCaptureSession(completionHandler: completionHandler)
//    }
    
    override init()  {
        super.init()
        self.captureDevice = getBackVideoCaptureDevice()
    }
    
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func setZoomState(zoomState: ZoomState){
        self.zoomState = zoomState
        setVideoZoomFactor()
    }
    
    func getCameraTypes () -> [CameraType]?{
        guard let captureDevice = captureDevice else {return nil}
        switch captureDevice.deviceType {
        case .builtInTripleCamera: return [.telephoto, .wide, .ultrawide]
        case .builtInDualWideCamera: return [.ultrawide, .wide]
        case .builtInDualCamera: return[.wide, .telephoto]
        case .builtInWideAngleCamera: return [.wide]
        default:
            return nil
        }
    }
    
    func toggleCamera(){
        if let captureDeviceInput = captureDeviceInput {
            
            captureSession.removeInput(captureDeviceInput)
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            switch self.cameraPosition {
            case .front:
                if let backCaptureDevice = self.getBackVideoCaptureDevice() {
                    self.initializeCaptureSession(captureDevice: backCaptureDevice)
                }
                self.cameraPosition = .back
            case .back:
                if let frontCaptureDevice = self.getFrontVideoCaptureDevice() {
                    self.initializeCaptureSession(captureDevice: frontCaptureDevice)
                }
                self.cameraPosition = .front
            }
        }
        
    }
    
    func initializeCaptureSession(captureDevice: AVCaptureDevice? = nil, completionHandler: CaptureSessionInitializedCompletionHandler? = nil ) {
          
        
        print("inside initialCaptureSession")
        var tmpCaptureDevice = self.captureDevice
        if let passedCaptureDevice = captureDevice {
            print("Got the capture device from initialized method")
            tmpCaptureDevice = passedCaptureDevice
        }else {
            print("did not get the camera from initialized method itself")
//            self.captureDevice = getBackVideoCaptureDevice()
//            tmpCaptureDevice = self.captureDevice
        }
        guard let captureDevice = tmpCaptureDevice else { print("no back camera or camera detected at initializing capture sessionController")
            return}
        self.captureDevice = captureDevice
        guard let captureDeviceInput = getCaptureDeviceInput(captureDevice: captureDevice) else {return}
        self.captureDeviceInput = captureDeviceInput
        guard captureSession.canAddInput(captureDeviceInput) else {
            print(" can not add input")
            return}
        captureSession.addInput(captureDeviceInput)
        captureSession.startRunning()
        setVideoZoomFactor()
        completionHandler?()
    }
    
}
private extension CaptureSessionController {
    func getBackVideoCaptureDevice() -> AVCaptureDevice? {
        
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
            print("returning wide angle camera: " + wideAngleCamera.localizedName)
            return wideAngleCamera
            
        }
        return nil
}
    
    func getFrontVideoCaptureDevice() -> AVCaptureDevice? {
        
        if let trueDepthCamera = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front){
            return trueDepthCamera
        }
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front){
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
