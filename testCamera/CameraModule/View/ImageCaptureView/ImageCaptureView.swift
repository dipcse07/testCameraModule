//
//  ImageCaptureView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 26/8/21.
//

import UIKit
import Photos
import UIKit

protocol ImageCaptureViewDelegate: AnyObject {
    func capturedImagedPassed(image: UIImage? )
    
    func captureImageViewTapped()
}

class ImageCaptureView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var ringView: UIView!
    
    var imageCaptureViewDelegate: ImageCaptureViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.customInit()
       // fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit() {
        let bundle = Bundle.main
        let nibName = String(describing: Self.self)
        bundle.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupContainerView()
    }
    
    @IBAction func tapHnadler(tapGesterRec: UITapGestureRecognizer){
        //self.handleTakePhoto()
        imageCaptureViewDelegate?.captureImageViewTapped()
    }
    
  
}

private extension ImageCaptureView {
    func setupContainerView() {
        containerView.layer.borderWidth = 4.0
        containerView.layer.borderColor =  UIColor.white.cgColor
    }
    
    
    
}
    
    
    
    

