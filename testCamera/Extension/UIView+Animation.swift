//
//  UIView+Animation.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 1/8/21.
//

import Foundation
import UIKit
extension UIView {
    func animateInView(delay: TimeInterval){
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -20)
        let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.alpha = 1
            self.transform = .identity
        }

        animation.startAnimation(afterDelay: delay)
    }
    
    func animateOutView(delay: TimeInterval, completionHandler: (() -> Void)? = nil) {
        let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            self.alpha = 0
            self.transform = .identity
        }
        animation.addCompletion { _ in
            completionHandler?()
        } // why we are calling completion handler before even starting the animation?
        
        animation.startAnimation(afterDelay: delay)
    }
}
