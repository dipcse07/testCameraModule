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
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewForNextAuthRequest()
    }
    
}

private extension LaunchViewController {
    func setupViewForNextAuthRequest() {
        guard cameraAuthStatus == .granted else {
            addRequestCameraAuthorizationView()
            return
        }
        if let _ = requestCameraAuthView {
            removeRequestCameraAuthorizationView()
            return
        }
    }
    
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
            
            //            switch status {
            //            case .granted:
            //                print("granted")
            //            case .notRequested:
            //                break
            //            case .unauthorized:
            //                print("unauthorized")
            //            }
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
        //requestCameraAuthView?.removeFromSuperview()
    }
    
    func openSettings(){
        let seetingsURLString = UIApplication.openSettingsURLString
        if let settingURL = URL(string: seetingsURLString){
            UIApplication.shared.open(settingURL, options: [ : ], completionHandler: nil)
        }
    }
}

extension LaunchViewController: RequestCameraAuthorizationViewDelegate {
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
    
}
