//
//  CaptureViewController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 2/8/21.
//

import UIKit

class CaptureViewController: UIViewController {

    @IBOutlet weak var videoPreviewView: VideoPreviewView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet var recordView: RecordView!
    @IBOutlet weak var timerView: TimerView!
    
    @IBOutlet weak var switchZoomView: SwitchZoomView!
    
    @IBOutlet weak var toggleCameraView: ToggleCameraView!
    
    
    private var captureSessionController = CaptureSessionController()
    
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    private lazy var timerController = TimerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor  = .blue
        self.setupVisualEfectView()
        self.initConstraints()
        self.setupToggleCameraView()
        setupCaptureSessionController()
        registerForApplicationStateNotification()
//        setupTimer()
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .ApplicationDidBecomeActive,object: nil)
        NotificationCenter.default.removeObserver(self, name: .ApplicationWillResignActive,object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print(size)
      
        hideViewsBeforeOrientationChange()
        coordinator.animate { [weak self ] context in
            guard let self = self else {return}
            self.setupVideoOrientation()
        } completion: {[weak self] context in
            guard let self = self else { return }
            self.setupOriatationConstraints(size: size)
            self.showViewsAfterDeviceOrientationChanges()
        }

    
    }
}


private extension CaptureViewController {
    func initConstraints() {
        portraitConstraints = [
            recordView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
                               recordView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                               switchZoomView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                               switchZoomView.widthAnchor.constraint(equalToConstant: 160),
                               switchZoomView.heightAnchor.constraint(equalToConstant: 60),
                               switchZoomView.bottomAnchor.constraint(equalTo: recordView.topAnchor, constant: -30),
                               toggleCameraView.centerYAnchor.constraint(equalTo: recordView.centerYAnchor),
                               toggleCameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -30)
        
        ]
        
        landscapeConstraints = [recordView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
                                recordView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                switchZoomView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                switchZoomView.widthAnchor.constraint(equalToConstant: 60),
                                switchZoomView.heightAnchor.constraint(equalToConstant: 160),
                                switchZoomView.trailingAnchor.constraint(equalTo: recordView.leadingAnchor, constant: -30),
                                toggleCameraView.centerXAnchor.constraint(equalTo: recordView.centerXAnchor),
                                toggleCameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  30)
        ]
        
        let screenSize = UIScreen.main.bounds.size
        setupOriatationConstraints(size: screenSize )
    }
    
    func setupOriatationConstraints(size: CGSize){
        if size.width > size.height {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            switchZoomView.configureStackViewforLandscapeOrientation()
        }else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            switchZoomView.configureStackViewforPortraitOrientation()
            
            
        }
    }
    
    func setupTimer() {
        timerController.setupTimer {[weak self] seconds in
            guard let self = self else {
                return
            }
            self.timerView.updateTime(seconds: seconds)
            print(seconds)
        }
    }
    
    func hideViewsBeforeOrientationChange() {
        recordView.alpha = 0
        switchZoomView.alpha = 0
    
    }
    func showViewsAfterDeviceOrientationChanges() {
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.recordView.alpha = 1
            self.switchZoomView.alpha = 1
        }
        animation.startAnimation()
    }
    
    func setupSwitchZoomView(){
        switchZoomView.delegate = self
        if let cameraTypes = captureSessionController.getCameraTypes()
        {
            if cameraTypes.filter({ $0 == .ultrawide
            }).isEmpty {
                switchZoomView.hideUltraWidButton()
            }
            if cameraTypes.filter({ $0 == .telephoto
            }).isEmpty {
                switchZoomView.hideTelephotoButton()
            }

            if cameraTypes == [.wide] {
                switchZoomView.alpha = 0
            }

        }
    }
    
    func setupCaptureSessionController() {
        self.captureSessionController.initializeCaptureSession(completionHandler: { [ weak self] in
            guard let self = self else {return }
            
            
            if self.captureSessionController != nil {

                print("session is initialized")
                self.videoPreviewView.videoPreviewLayer.session = self.captureSessionController.getCaptureSession()
                self.setupVideoOrientation()
                self.setupToggleCameraView()
                self.setupSwitchZoomView()
               
                
}
            else {
                print("session is nil because capture sessionController is nill")
            }
            
        })

        
       
    }
    
    func setupToggleCameraView (){
        self.toggleCameraView.delegate = self
    }
    
    func setupVisualEfectView(){
        visualEffectView.effect = nil
    }
    
    func registerForApplicationStateNotification() {
        NotificationCenter.default.addObserver(
            forName: .ApplicationDidBecomeActive,
            object: nil,
            queue: .main)
        { [weak self ] notification in
            
            guard let self = self else {return }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.visualEffectView.effect = nil
                
            }
            completion: { _ in
            }
        }
        NotificationCenter.default.addObserver(
            forName: .ApplicationWillResignActive,
            object: nil,
            queue: .main)
        { [weak self ] notification in
            
            guard let self = self else {return }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.visualEffectView.effect = UIBlurEffect(style: .dark )
                
            }
            completion: { _ in
            }
        }
    }
    
    func setupVideoOrientation(){
        guard let interfaceOrientation = AppSetup.interfaceOrientation else {return }
        guard let videoOrientation = VideoOrientationController.getVideoOrientation(interfaceOrientation: interfaceOrientation) else {return}
        videoPreviewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
        
    }
    
}


extension CaptureViewController: SwitchZoomViewDelegate {
    func switchZoomTapped(state: ZoomState) {
        captureSessionController.setZoomState(zoomState: state)
        print(state)
    }

}
extension CaptureViewController: ToggleCameraDelegate {
    func toggleCameraButtonTapped() {
        print("toggle camera button Pressed")
        captureSessionController.toggleCamera()
    }
    
    
}
