//
//  ToggleCaptureButton.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 26/8/21.
//

import UIKit



enum CaptureMode {
    case photo, video
}

protocol ToggleCaptureButtonViewDelegate: AnyObject {
    func toggleCaptureButtonTapped(captureMode: CaptureMode, completionHandler: (Bool) -> Void )
}

class ToggleCaptureButtonView: UIView {


    @IBOutlet private weak var contentView: UIView!
   
    @IBOutlet private weak var toggleCaptureButton: UIButton!
    
    
    private var captureMode = CaptureMode.video
    weak var delegate: ToggleCaptureButtonViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }

    private func customInit() {
        let bundle = Bundle.main
        let nibName = String(describing: Self.self)
        bundle.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        toggleCaptureButton.tintColor = .textOnBackgroundAlpha
        toggleCaptureButton.setTitle("Video", for: .normal)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBAction func torchButtoPressed(_ sender: UIButton) {
        delegate?.toggleCaptureButtonTapped(captureMode: captureMode, completionHandler: { [weak self] success in
            guard let self = self else {return }
            guard success else {return}
            switch captureMode {
            case .photo:
                toggleCaptureButton.tintColor = .textOnBackgroundAlpha
                toggleCaptureButton.setTitle("Video", for: .normal)
                self.captureMode = .video
            case .video:
                toggleCaptureButton.tintColor = .textOnBackgroundAlpha
                toggleCaptureButton.setTitle("Photo", for: .normal)
                self.captureMode = .photo
            }
        })
    }
    
}
