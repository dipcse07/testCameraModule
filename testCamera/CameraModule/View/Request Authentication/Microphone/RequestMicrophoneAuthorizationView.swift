//
//  RequestMicrophoneAuthorizationView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 31/7/21.
//

import UIKit
protocol RequestMicrophoneAuthorizationViewDelegate: AnyObject {
    func requestMicrophneAuthorizationActionButtonTapped()
}
class RequestMicrophoneAuthorizationView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var microphoneImageView: UIImageView!
    
    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var actionButtonWidhConstant: NSLayoutConstraint!
    weak var delegate: RequestMicrophoneAuthorizationViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
        
    }
    
  required init?(coder: NSCoder) {
    super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    customInit()
    }
    
    func customInit() {
        let bundle = Bundle.main
        let nibName = String(describing: Self.self)
        bundle.loadNibNamed(nibName, owner: self, options: nil)
        actionButton.addShadow()
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    }
    
    @IBAction func actionButtonHandler(btn: UIButton){
        delegate?.requestMicrophneAuthorizationActionButtonTapped()
    }
    
    func animateInViews() {
        let viewsToAnimate = [microphoneImageView,titleLable,messageLabel,actionButton]

        for (i, viewToAnimate) in viewsToAnimate.enumerated() {
            guard let view = viewToAnimate else {continue}
            view.animateInView( delay: Double(i) * 0.15)
        }

    }
    func animateOutViews(completionHandler: @escaping () -> ()){
        let viewsToAnimate = [microphoneImageView,titleLable,messageLabel,actionButton]

        for (i, viewToAnimate) in viewsToAnimate.enumerated() {
            guard let view = viewToAnimate else {continue}
            var completionHandlerToCall: (() -> ())? = nil
            if viewToAnimate == viewsToAnimate.last{
                completionHandlerToCall = completionHandler
            }
            view.animateOutView(delay: Double(i) * 0.15, completionHandler: completionHandlerToCall)
  
        }
        
        
    }
    
    func configurationForErrorState() {
        titleLable.text = "Camera Authorization Denied"
        actionButton.setTitle("Open Settings", for: .normal)
        actionButtonWidhConstant.constant = 120
    }
    
}

