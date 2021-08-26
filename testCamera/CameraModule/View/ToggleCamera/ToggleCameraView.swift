//
//  ToggleCameraView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 15/8/21.
//

import UIKit
protocol ToggleCameraDelegate: AnyObject {
    func toggleCameraButtonTapped()
}
class ToggleCameraView: UIView {
    @IBOutlet private var contentView: UIView!
    var delegate: ToggleCameraDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
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
    
    @IBAction func toggleButtonHandler(btn: UIButton){
        delegate?.toggleCameraButtonTapped()
    }

}
