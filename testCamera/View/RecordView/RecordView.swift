//
//  RecordView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 14/8/21.
//

import UIKit

enum RecordViewState {
    case stopped
    case recording
}

class RecordView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var ringView: UIView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var stopView: UIView!
    
    private var state = RecordViewState.stopped
    
    
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
        
        switch state {
        
        case .stopped:
            state = .recording
            animateForRecording()
        case .recording:
            state = .stopped
            animateForStopped()
        }
    }
}

private extension RecordView {
    func setupContainerView() {
        containerView.layer.borderWidth = 4.0
        containerView.layer.borderColor =  UIColor.white.cgColor
    }
    
    func animateForRecording(){
        let ringViewAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.ringView.transform = CGAffineTransform(translationX: 0, y: 70)
            self.ringView.alpha = 0
        }
        stopView.transform = CGAffineTransform(translationX: 0, y: 70)
        stopView.alpha
         = 0
        stopView.isHidden = false
        let stopViewAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.stopView.transform = .identity
            self.stopView.alpha = 1
        }
//        ringView.alpha = 0
//       // ringView.isHidden = true
//        stopView.isHidden = false
//        stopView.alpha = 1
        
        ringViewAnimation.startAnimation()
        stopViewAnimation.startAnimation(afterDelay: 0.3)
    }
    
    func animateForStopped(){
        let stopViewAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.stopView.transform = CGAffineTransform(translationX: 0, y: 70)
            self.stopView.alpha = 0
            
        }
        self.ringView.transform = CGAffineTransform(translationX: 0, y: 70)
        self.ringView.alpha = 0
        let ringViewAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.ringView.transform = .identity
            self.ringView.alpha = 1
            
        }
        stopViewAnimation.startAnimation()
        ringViewAnimation.startAnimation(afterDelay: 0.3)
    }
}
