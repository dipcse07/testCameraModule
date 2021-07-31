//
//  LaunchViewController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 28/7/21.
//

import UIKit

class LaunchViewController: UIViewController {
    
    private var requestCameraAuthView: RequestCameraAuthorizationView?
    private var cameraAuthStatus = RequestCameraAuthorizationController.getCameraAuthorizationStatus() {
        didSet {
            setupViewForNextAuthRequest()
        }
    }
    
    private var requestMicroPhoneAuthView: RequestMicrophoneAuthorizationView?
    private var microPhoneAuthStatus = RequestMicroPhoneAuthorizationController.getMicrophoneAuthorizationStatus() {
        didSet {
            setupViewForNextAuthRequest()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewForNextAuthRequest()
    }
    
    private func openSettings(){
        let seetingsURLString = UIApplication.openSettingsURLString
        if let settingURL = URL(string: seetingsURLString){
            UIApplication.shared.open(settingURL, options: [ : ], completionHandler: nil)
        }
    }
    
    private func setupViewForNextAuthRequest() {
        guard cameraAuthStatus == .granted else {
            addRequestCameraAuthorizationView()
            return
        }
        if let _ = requestCameraAuthView {
            removeRequestCameraAuthorizationView()
            return
        }
        
        guard microPhoneAuthStatus == .granted else {
            addRequestMicroPhoneAuthorizationView()
            return
        }
        if let _ = requestMicroPhoneAuthView {
            removeRequestMicroPhoneAuthorizationView()
            return
        }

    }
    
    
}

private extension LaunchViewController {
    
    func addRequestCameraAuthorizationView() {
        guard requestCameraAuthView == nil else {
            if cameraAuthStatus == .unauthorized {
                requestCameraAuthView?.configureForErorrState()
            }
            return
        }
        
        let requestCameraAuthorizationView = RequestCameraAuthorizationView()
        requestCameraAuthorizationView.translatesAutoresizingMaskIntoConstraints = false
        requestCameraAuthorizationView.delegate = self
        
        view.addSubview(requestCameraAuthorizationView)
        NSLayoutConstraint.activate([
            requestCameraAuthorizationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            requestCameraAuthorizationView.topAnchor.constraint(equalTo: view.topAnchor),
            requestCameraAuthorizationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            requestCameraAuthorizationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if cameraAuthStatus == .unauthorized {
            requestCameraAuthorizationView.configureForErorrState()
        }
        requestCameraAuthorizationView.animateInviews()
        self.requestCameraAuthView = requestCameraAuthorizationView
        
        
    }
    func requestCameraAuthorization() {
        RequestCameraAuthorizationController.requestCameraAuthorization(completionHandler: { [weak self] status in
            guard let self = self else {return}
            self.cameraAuthStatus = status
        })
    }
    
    func removeRequestCameraAuthorizationView() {
        guard let requestCameraAuthView = requestCameraAuthView else {return}
        requestCameraAuthView.animateOutviews(completionHandler: { [weak self] in
            guard let self = self else {return}
            requestCameraAuthView.removeFromSuperview()
            print("animation finished")
            self.requestCameraAuthView = nil
            self.setupViewForNextAuthRequest()
        })
        
    }
    
}

//MARK:- Extension For Microphone Access and Controll

private extension LaunchViewController {
    
    func addRequestMicroPhoneAuthorizationView() {
        guard requestMicroPhoneAuthView == nil else {
            if microPhoneAuthStatus == .unauthorized {
                requestMicroPhoneAuthView?.configurationForErrorState()
            }
            return
        }
        
        let requestMicrophonneAuthorizationView = RequestMicrophoneAuthorizationView()
        requestMicrophonneAuthorizationView.translatesAutoresizingMaskIntoConstraints = false
        requestMicrophonneAuthorizationView.delegate = self
        
        view.addSubview(requestMicrophonneAuthorizationView)
        NSLayoutConstraint.activate([
            requestMicrophonneAuthorizationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            requestMicrophonneAuthorizationView.topAnchor.constraint(equalTo: view.topAnchor),
            requestMicrophonneAuthorizationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            requestMicrophonneAuthorizationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if microPhoneAuthStatus == .unauthorized {
            requestMicrophonneAuthorizationView.configurationForErrorState()
        }
        requestMicrophonneAuthorizationView.animateInViews()
        self.requestMicroPhoneAuthView = requestMicrophonneAuthorizationView
        
        
    }
    func requestMicrophoneAuthorization() {
    
        RequestMicroPhoneAuthorizationController.requestMicroPhoneAuthorization(completionHandler: { [weak self] status in
            guard let self = self else {return}
            self.microPhoneAuthStatus = status
        })
    }
    
    func removeRequestMicroPhoneAuthorizationView() {
        guard let requestMicroPhoneAuthView = requestMicroPhoneAuthView else {return}
        requestMicroPhoneAuthView.animateOutViews(completionHandler: { [weak self] in
            guard let self = self else {return}
            requestMicroPhoneAuthView.removeFromSuperview()
            print("animation finished")
            self.requestMicroPhoneAuthView = nil
            self.setupViewForNextAuthRequest()
        })
        
    }
    
}



extension LaunchViewController: RequestCameraAuthorizationViewDelegate, RequestMicrophoneAuthorizationViewDelegate{
    
    func requestCameraAuthorizationActionButtonTapped() {
        if cameraAuthStatus == .notRequested {
            RequestCameraAuthorizationController.requestCameraAuthorization { [weak self] status in
                guard let self = self else{return}
                self.cameraAuthStatus = status
            }
            // requestCameraAuthorization()
            return
        }
        if cameraAuthStatus == .unauthorized {
            
            openSettings()
            return
        }

    }
    
    func requestMicrophneAuthorizationActionButtonTapped() {
        if microPhoneAuthStatus == .notRequested {
            RequestMicroPhoneAuthorizationController.requestMicroPhoneAuthorization { [weak self] status in
                guard let self = self else{return}
                self.microPhoneAuthStatus = status
            }
            // requestCameraAuthorization()
            return
        }
        if microPhoneAuthStatus == .unauthorized {
            openSettings()
            return
        }
    }
    
}
