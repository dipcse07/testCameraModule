//
//  PointOfInterest.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 25/8/21.
//

import UIKit

class PointOfInterest: UIView {

 
    @IBOutlet private weak var contentView: UIView!
    
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
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.layer.borderColor = UIColor.yellow.cgColor
        contentView.layer.borderWidth = 1.0
    }
}
