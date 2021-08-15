//
//  SwitchZoomView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 15/8/21.
//

import UIKit
enum ZoomState {
    case ultrawide
    case wide
    case telephoto
}

protocol SwitchZoomViewDelegate: AnyObject {
    func switchZoomTapped(state: ZoomState)
}
class SwitchZoomView: UIView {

    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var ultrawideButton: UIButton!
    
    @IBOutlet weak var wideButton: UIButton!
    @IBOutlet weak var telephotoButton: UIButton!
    
    
    private var zoomState = ZoomState.wide
    private var selectedButton: UIButton?
    public weak var delegate: SwitchZoomViewDelegate?
    
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
        wideButton.setTitleColor(.selected, for: .normal)
        selectedButton = wideButton
        
    }
    
    @IBAction func ultrawideButtonHandler(_ sender: UIButton) {
        selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
        zoomState = .ultrawide
        ultrawideButton.setTitleColor(.selected, for: .normal)
        selectedButton = ultrawideButton
        delegate?.switchZoomTapped(state: zoomState)

    }
    
    @IBAction func wideButtonHandler(_ sender: UIButton) {
        selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
        zoomState = .wide
        wideButton.setTitleColor(.selected, for: .normal)
        selectedButton = wideButton
        delegate?.switchZoomTapped(state: zoomState)

    }
    
    @IBAction func telephotoButtonHandler(_ sender: UIButton) {
        
        selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
        zoomState = .telephoto
        telephotoButton.setTitleColor(.selected, for: .normal)
        selectedButton = telephotoButton
        delegate?.switchZoomTapped(state: zoomState)
        
    }
    
    func hideUltraWidButton () {
        ultrawideButton.isHidden = true
    }
    func hideTelephotoButton () {
        telephotoButton.isHidden = true
    }
    
    func configureStackViewforPortraitOrientation () {
        stackView.axis = .horizontal
    }
    
    func configureStackViewforLandscapeOrientation () {
        stackView.axis = .vertical
    }
}
