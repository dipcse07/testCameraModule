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
    
    
    func makeConstraints(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, topMargin: CGFloat, leftMargin: CGFloat, rightMargin: CGFloat, bottomMargin: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: topMargin).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: leftMargin).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -rightMargin).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomMargin).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach{ addSubview($0) }
    }
    
}
