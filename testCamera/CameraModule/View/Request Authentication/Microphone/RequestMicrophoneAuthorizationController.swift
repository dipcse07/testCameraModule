//
//  RequestMicrophoneAuthorizationController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 31/7/21.
//

import Foundation
import AVFoundation
import AVFAudio
enum MicrophoneAuthorizationStatus {
    case notRequested
    case granted
    case unauthorized
}

typealias RequestMicrophoneAuthorizationCompletionHandler = (MicrophoneAuthorizationStatus) -> Void

class RequestMicroPhoneAuthorizationController {
    
    static func requestMicroPhoneAuthorization(completionHandler: @escaping RequestMicrophoneAuthorizationCompletionHandler) {
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completionHandler(.unauthorized)
                    return
                }
                completionHandler(.granted)
            }
        })
    }
    
    static func getMicrophoneAuthorizationStatus() -> MicrophoneAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unauthorized
        }
    }
    
}
