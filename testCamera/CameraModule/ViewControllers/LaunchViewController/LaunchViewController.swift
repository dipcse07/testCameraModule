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
    
    
    private var requestPhotoLibraryAuthView: RequestPhotoLibraryAuthView?
    private var photoLibraryAuthStatus = RequestPhotoLibraryAuthorizationController.getPhotoLibraryAuthorizationStatus() {
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
        
        guard photoLibraryAuthStatus == .granted else {
            addRequestPhotoLibraryAuthorizationView()
            return
        }
        if let _ = requestPhotoLibraryAuthView {
            removeRequestPhotoLibraryAuthorizationView()
            return
        }
        
        print("Show Capture View Controller")
        DispatchQueue.main.async {
            CameraModuleSetup.loadCaptureViewController()
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


//MARK:- PhotoLibrary Authorization
private extension LaunchViewController {
    
    func addRequestPhotoLibraryAuthorizationView() {
        guard requestPhotoLibraryAuthView == nil else {
            if photoLibraryAuthStatus == .unauthorized {
                requestPhotoLibraryAuthView?.configurationForErrorState()
            }
            return
        }
        
        let requestPhotoLibraryAuthorizationView = RequestPhotoLibraryAuthView()
        requestPhotoLibraryAuthorizationView.translatesAutoresizingMaskIntoConstraints = false
        requestPhotoLibraryAuthorizationView.delegate = self
        
        view.addSubview(requestPhotoLibraryAuthorizationView)
        NSLayoutConstraint.activate([
            requestPhotoLibraryAuthorizationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            requestPhotoLibraryAuthorizationView.topAnchor.constraint(equalTo: view.topAnchor),
            requestPhotoLibraryAuthorizationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            requestPhotoLibraryAuthorizationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if photoLibraryAuthStatus == .unauthorized {
            requestPhotoLibraryAuthorizationView.configurationForErrorState()
        }
        requestPhotoLibraryAuthorizationView.animateInViews()
        self.requestPhotoLibraryAuthView = requestPhotoLibraryAuthorizationView
        
        
    }
    func requestPhotoLibraryAuthorization() {
    
        RequestPhotoLibraryAuthorizationController.requestPhotoLibraryAuthorization(completionHandler: { [weak self] status in
            guard let self = self else {return}
            self.photoLibraryAuthStatus = status
        })
    }
    
    func removeRequestPhotoLibraryAuthorizationView() {
        guard let requestPhotoLibraryAuthView = requestPhotoLibraryAuthView else {return}
        requestPhotoLibraryAuthView.animateOutViews(completionHandler: { [weak self] in
            guard let self = self else {return}
            requestPhotoLibraryAuthView.removeFromSuperview()
            print("animation finished")
            self.requestPhotoLibraryAuthView = nil
            self.setupViewForNextAuthRequest()
        })
        
    }
    
}



//MARK:- Authorization Delegates
extension LaunchViewController: RequestCameraAuthorizationViewDelegate, RequestMicrophoneAuthorizationViewDelegate, RequestPhotoLibraryAuthorizationViewDelegate{
    
    //MARK:- Request Camera View Delegate
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
    
    //MARK:- Request MicroPhone Auth View Delegate
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
    
    //MARK:- Request PhotoLibrary AuthView Delegate
    func requestPhotoLibraryAuthorizationActionButtonTapped() {
        if photoLibraryAuthStatus == .notRequested {
            RequestPhotoLibraryAuthorizationController.requestPhotoLibraryAuthorization { [weak self] status in
                guard let self = self else{return}
                self.photoLibraryAuthStatus = status
            }
            // requestCameraAuthorization()
            return
        }
        if photoLibraryAuthStatus == .unauthorized {
            openSettings()
            return
        }
    }
}
