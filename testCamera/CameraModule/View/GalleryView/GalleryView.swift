//
//  GalleryView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 27/8/21.
//

import UIKit

protocol GalaryViewDelegate:AnyObject {
    func galleryButtonTapped()
}

class GalleryView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet private weak var galleryButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.customInit()
       // fatalError("init(coder:) has not been implemented")
    }
    var delegate: GalaryViewDelegate?
    private func customInit() {
        
        let bundle = Bundle.main
        let nibName = String(describing: Self.self)
        bundle.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
    }
    
    @IBAction func galleryButtonHandler(sender: UIButton){
        //self.handleTakePhoto()
        delegate?.galleryButtonTapped()
    }
    
    func setGalleryButtonImage(image: UIImage ){
        self.galleryButton.setImage(image, for: .normal)
    }
}

