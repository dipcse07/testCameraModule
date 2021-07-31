//
//  RequestCameraAuthorizationView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 28/7/21.
//

import UIKit
protocol RequestCameraAuthorizationViewDelegate: AnyObject {
    func requestCameraAuthorizationActionButtonTapped()
}
class RequestCameraAuthorizationView: UIView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cameraImageView: UIImageView!
    
    weak var delegate: RequestCameraAuthorizationViewDelegate?
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
    
    @IBAction func actionButtonHandler(btn: UIButton) {
           delegate?.requestCameraAuthorizationActionButtonTapped()
       }

    func animateInviews (){
        cameraImageView.alpha = 0
        animateInView(view: cameraImageView, delay: 0.15)
    }
    func animateOutviews (completionHandler: @escaping () -> ()){
        cameraImageView.alpha = 0
        var completionHandlerToCall: (() -> ())? = nil
        
        completionHandlerToCall = completionHandler
        animateOutView(view: cameraImageView, delay: 0.15, completionHandler: completionHandlerToCall)
    }
    
    func configureForErorrState() {
        let title = "Camera Auth Denied"
        print(title)
    }
}

private extension RequestCameraAuthorizationView {
    
    func animateInView(view: UIView, delay: TimeInterval){
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: -20)
        let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            view.alpha = 1
            view.transform = .identity
        }

        animation.startAnimation(afterDelay: delay)
    }
    
    func animateOutView(view: UIView, delay: TimeInterval, completionHandler: (() -> Void)? = nil) {
        let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            view.alpha = 0
            view.transform = .identity
        }
        animation.addCompletion { _ in
            completionHandler?()
        } // why we are calling completion handler before even starting the animation?
        
        animation.startAnimation(afterDelay: delay)
    }
}
