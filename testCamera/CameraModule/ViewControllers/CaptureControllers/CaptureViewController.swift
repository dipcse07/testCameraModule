//
//  CaptureViewController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 2/8/21.
//

import UIKit
import AVFoundation
import Photos
class CaptureViewController: UIViewController {
    
    @IBOutlet weak var videoPreviewView: VideoPreviewView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var recordView: RecordView!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var galleryView: GalleryView!
    @IBOutlet weak var torchView: TorchView!
    @IBOutlet weak var alertView: AlertView!
    @IBOutlet weak var pointOFInterestView: PointOfInterest!
    @IBOutlet weak var switchZoomView: SwitchZoomView!
    @IBOutlet weak var toggleCameraView: ToggleCameraView!
    @IBOutlet weak var imageCaptureView: ImageCaptureView!
    @IBOutlet weak var toggleCaptureButtonView: ToggleCaptureButtonView!
    @IBOutlet private weak var overlayView: UIView!
    
    
    private var captureSessionController = CaptureSessionController()
    private let photoOutput = AVCapturePhotoOutput()
    private var imagePickerController = UIImagePickerController()

    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    private lazy var timerController = TimerController()
    private var switchZommViewWidthConstraint:NSLayoutConstraint?
    private var switchZoomViewHeightConstraint: NSLayoutConstraint?
    private var shouldHideSwitchZoomView = false
    private var hideAlertViewWorkItem: DispatchWorkItem?
    private var pointOfInterestHalfCompletedWorkItem: DispatchWorkItem?
    private var pointOfInterestCompleteWorkItem: DispatchWorkItem?
    private var videoRecordButtonCompletionHandler: ((Bool) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor  = .blue
        self.setupTorchView()
        self.setupToggleCaptureModeView()
        self.setupVisualEfectView()
        self.setupImageCaptureView()
        self.setupGalleryView()
        self.setupToggleCameraView()
        self.setupCaptureSessionController()
        self.registerForApplicationStateNotification()
        self.setupRecordButton()
        //setupTimer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initConstraints()
        showInitialViews()
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
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showToast(message: "Could not save!! \n\(error)", fontSize: 12)
        } else {
            showToast(message: "Saved", fontSize: 12.0)
        }
    }
    
    @objc func video(_ video: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            
            showToast(message: "Could not save!! \n\(error)", fontSize: 12)
        } else {
            showToast(message: "Saved", fontSize: 12.0)
        }
        print(video)
    }
    
}

private extension CaptureViewController {
    
    func initConstraints() {
        portraitConstraints = [
            recordView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            recordView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchZoomView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchZoomView.heightAnchor.constraint(equalToConstant: 60),
            switchZoomView.bottomAnchor.constraint(equalTo: recordView.topAnchor, constant: -30),
            toggleCameraView.centerYAnchor.constraint(equalTo: recordView.centerYAnchor),
            toggleCameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -30)
        ]
        
        landscapeConstraints = [recordView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
                                recordView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                switchZoomView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                switchZoomView.widthAnchor.constraint(equalToConstant: 60),
                                
                                switchZoomView.trailingAnchor.constraint(equalTo: recordView.leadingAnchor, constant: -30),
                                toggleCameraView.centerXAnchor.constraint(equalTo: recordView.centerXAnchor),
                                toggleCameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  30)
        ]
        
        let switchZoomViewWidthConst =                                switchZoomView.widthAnchor.constraint(equalToConstant: 160)
        portraitConstraints.append(switchZoomViewWidthConst)
        self.switchZommViewWidthConstraint = switchZoomViewWidthConst
        
        let switchZoomViewHeightConst = switchZoomView.heightAnchor.constraint(equalToConstant: 160)
        landscapeConstraints.append(switchZoomViewHeightConst)
        self.switchZoomViewHeightConstraint = switchZoomViewHeightConst
        
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
                reduceSwitchZoomViewSize()
            }
            if cameraTypes.filter({ $0 == .telephoto
            }).isEmpty {
                switchZoomView.hideTelephotoButton()
                reduceSwitchZoomViewSize()
            }
            
            if cameraTypes == [.wide] {
                switchZoomView.isHidden = true
                self.shouldHideSwitchZoomView = true
            }
            
        }
    }
    
    func setupCaptureSessionController() {
        captureSessionController.presentingViewController = self
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
            self.captureSessionController.startRunning()
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
            self.captureSessionController.stopRunning()
        }
    }
    
    func setupVideoOrientation(){
        guard let interfaceOrientation = CameraModuleSetup.interfaceOrientation else {return }
        guard let videoOrientation = VideoOrientationController.getVideoOrientation(interfaceOrientation: interfaceOrientation) else {return}
        videoPreviewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
        
    }
    
    func reduceSwitchZoomViewSize() {
        let delta: CGFloat = 50
        self.switchZommViewWidthConstraint?.constant -= delta
        self.switchZoomViewHeightConstraint?.constant -= delta
    }
    
    func showInitialViews(){
        recordView.isHidden = false
        if shouldHideSwitchZoomView {
            switchZoomView.isHidden = false
        }
        toggleCameraView.isHidden = false
    }
    
    @IBAction func overlayViewTapHandler(tapGestureRecognizer: UITapGestureRecognizer){
        guard let tapView = tapGestureRecognizer.view else {return}
        
        let tapLocation = tapGestureRecognizer.location(in: tapView)
        let newLocation = tapView.convert(tapLocation, to: view)
        self.showPointOfInterestViewAtPoint(point: newLocation)
        let devicePoint = videoPreviewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: tapLocation)
        captureSessionController.setFocus(focusMode: .autoFocus, expoesureMode: .autoExpose, atPoint: devicePoint, shouldMonitorSubjectAreaChange: true)
    }
    
    func showAndHideAlertView(text:String){
        showAlertView(text: text )
        let hideAlertViewWorkItem  = DispatchWorkItem { [weak self] in
            guard let self = self else {return}
            self.hideAlertView()
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: hideAlertViewWorkItem)
        self.hideAlertViewWorkItem = hideAlertViewWorkItem
        
    }
    
    func showAlertView(text:String){
        self.hideAlertViewWorkItem?.cancel()
        self.hideAlertViewWorkItem = nil
        alertView.alpha = 0
        alertView.setAlertText(text: text)
        alertView.transform = CGAffineTransform(translationX: 0, y: 30)
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.alertView.transform = .identity
            self.alertView.alpha = 1.0
        }
        animation.startAnimation()
    }
    
    func hideAlertView() {
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.alertView.transform =  CGAffineTransform(translationX: 0, y: 30)
            self.alertView.alpha = 0
        }
        animation.startAnimation()
    }
    
    func setupTorchView() {
        torchView.delegate = self
    }
    
    func setupToggleCaptureModeView() {
        toggleCaptureButtonView.delegate = self
    }
    func setupGalleryView(){
        self.galleryView.delegate = self
    }
    func setupImageCaptureView(){
        self.imageCaptureView.isHidden = false
        self.imageCaptureView.imageCaptureViewDelegate = self
    }
    
    func setupRecordButton() {
        self.recordView.delegate = self
    }
    
    func showPointOfInterestViewAtPoint(point:CGPoint){
        pointOfInterestHalfCompletedWorkItem = nil
        pointOfInterestCompleteWorkItem = nil
        pointOFInterestView.center = point
        pointOFInterestView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.pointOFInterestView.transform = .identity
            self.pointOFInterestView.alpha = 1.0
        }
        animation.startAnimation()
        
        let pointOfInterestHalfCompletedWorkItem = DispatchWorkItem {
            [weak self] in
            guard let self = self else {return}
            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                self.pointOFInterestView.alpha = 0.5
            }
            animation.startAnimation()
        }
        
        let pointOfInterestCompletedWorkItem = DispatchWorkItem {
            [weak self] in
            guard let self = self else {return}
            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                self.pointOFInterestView.alpha = 0
            }
            animation.startAnimation()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: pointOfInterestHalfCompletedWorkItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: pointOfInterestCompletedWorkItem)
        
        self.pointOfInterestHalfCompletedWorkItem = pointOfInterestHalfCompletedWorkItem
        self.pointOfInterestCompleteWorkItem = pointOfInterestCompletedWorkItem
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
        captureSessionController.toggleCamera(completionHandler: {[weak self]cameraPosition in
            
            guard let self = self else {return}
            switch cameraPosition {
            case .front:
                self.switchZoomView.isHidden = true
                self.torchView.isHidden = true
            case .back:
                //if !self.shouldHideSwitchZoomView {
                self.switchZoomView.isHidden = false
                self.torchView.isHidden = false
            //}
            }
        })
    }
    
}

extension CaptureViewController: TorchViewDelegate {
    func torchTapped(torchMode: TorchMode, completionHandler: (Bool) -> Void ) {
        switch torchMode {
        
        case .on:
            let result =  captureSessionController.turnOfTorch()
            if !result {
                showAndHideAlertView(text: "Could not turn off the camera")
            }
            completionHandler(result)
        case .off:
            let result = captureSessionController.turnOnTorch()
            if !result {
                showAndHideAlertView(text: "Could not turn on the camera")
            }
            completionHandler(result)
        }
    }
}

extension CaptureViewController: ToggleCaptureButtonViewDelegate {
    func toggleCaptureButtonTapped(captureMode: CaptureMode, completionHandler: (Bool) -> Void) {
        switch captureMode {
        case .photo:
            print(captureMode)
            
            if  !self.timerView.isHidden {
             timerView.isHidden = true
             timerController.resetTimer()
             
             self.captureSessionController.stopRecording { error in
                 print(error ?? "Video recording error")
             }
             self.videoRecordButtonCompletionHandler(true)
             }
            
            self.imageCaptureView.isHidden = false
            self.recordView.isHidden = true
            completionHandler(true)
        case .video:
            print(captureMode)
         
            self.imageCaptureView.isHidden = true
            self.recordView.isHidden =  false
            completionHandler(true)
        }
    }
}

extension CaptureViewController:ImageCaptureViewDelegate {
    func capturedImagedPassed(image: UIImage?) {
        
    }
    
    func captureImageViewTapped() {
        self.captureSessionController.handleTakePhoto(uiViewController: self)
    }
}

extension CaptureViewController: GalaryViewDelegate {
    
    func galleryButtonTapped() {
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerController.delegate = self
        self.imagePickerController.mediaTypes = ["public.image", "public.movie"]
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
}

extension CaptureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //            self.galleryButton.contentMode = .scaleAspectFit
            //            self.galleryButton.setImage( pickedImage, for: .normal)
            self.galleryView.setGalleryButtonImage(image: pickedImage)
        }
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print("videoURL:\(String(describing: videoURL))")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CaptureViewController: RecordButtonViewDelegate {
    
    func recordButtonTapped(captureMode: RecordViewState, completionHandler: @escaping (Bool) -> Void) {
        switch captureMode {
        
        case .stopped:
            
            timerView.isHidden = false
            timerController.setupTimer {[weak self] seconds in
                guard let self = self else {
                    return
                }
                self.timerView.updateTime(seconds: seconds)
                print(seconds)
            }
            
            self.captureSessionController.recordVideo { videoUrl, error in
                guard let url = videoUrl else {
                    print(error ?? "Video recording error")
                    return
                }
                
                UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(self.video(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            self.videoRecordButtonCompletionHandler = completionHandler
            completionHandler(true)
        case .recording:
            timerView.isHidden = true
            timerController.resetTimer()
            
            self.captureSessionController.stopRecording { error in
                print(error ?? "Video recording error")
            }
            self.videoRecordButtonCompletionHandler = completionHandler
            completionHandler(true)
            
        }
    }

}
