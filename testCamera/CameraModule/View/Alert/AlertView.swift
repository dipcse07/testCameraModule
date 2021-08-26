//
//  AlertView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 24/8/21.
//

import UIKit

class AlertView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var containerView:UIView!
    @IBOutlet private weak var alertLabel: UILabel!
    
    
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
    }
    
    func setAlertText(text:String){
        alertLabel.text = text
    }
}
