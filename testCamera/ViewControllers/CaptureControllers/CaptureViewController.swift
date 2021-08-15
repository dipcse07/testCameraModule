//
//  CaptureViewController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 2/8/21.
//

import UIKit

class CaptureViewController: UIViewController {

    @IBOutlet weak var videoPreviewView: VideoPreviewView!
    @IBOutlet var recordView: RecordView!
    @IBOutlet weak var timerView: TimerView!
    
    @IBOutlet weak var switchZoomView: SwitchZoomView!
    
    
    private lazy var captureSessionController = CaptureSessionController()
    
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    private lazy var timerController = TimerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor  = .blue
        initConstraints()
        setupSwitchZoomView()
//        setupTimer()
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        videoPreviewView.videoPreviewLayer.session = captureSessionController.getCaptureSession()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print(size)
      
        hideViewsBeforeOrientationChange()
        coordinator.animate { context in
            
        } completion: {[weak self] context in
            guard let self = self else { return }
            self.setupOriatationConstraints(size: size)
            self.showViewsAfterDeviceOrientationChanges()
        }

    
    }
}


private extension CaptureViewController {
    func initConstraints() {
        portraitConstraints = [recordView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
                               recordView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                               switchZoomView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                               switchZoomView.widthAnchor.constraint(equalToConstant: 160),
                               switchZoomView.heightAnchor.constraint(equalToConstant: 60),
                               switchZoomView.bottomAnchor.constraint(equalTo: recordView.topAnchor, constant: -30)
        
        ]
        landscapeConstraints = [recordView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
                                recordView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                switchZoomView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                switchZoomView.widthAnchor.constraint(equalToConstant: 60),
                                switchZoomView.heightAnchor.constraint(equalToConstant: 160),
                                switchZoomView.trailingAnchor.constraint(equalTo: recordView.leadingAnchor, constant: -30)
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
    }
    
}


extension CaptureViewController: SwitchZoomViewDelegate {
    func switchZoomTapped(state: ZoomState) {
        print(state)
    }
    
    
}
