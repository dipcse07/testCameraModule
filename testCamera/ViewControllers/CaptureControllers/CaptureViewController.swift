//
//  CaptureViewController.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 2/8/21.
//

import UIKit

class CaptureViewController: UIViewController {

    @IBOutlet weak var videoPreviewView: VideoPreviewView!
    private lazy var captureSessionController = CaptureSessionController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor  = .blue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        videoPreviewView.videoPreviewLayer.session = captureSessionController.getCaptureSession()
    }
}
