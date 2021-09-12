//
//  UIImage+Rotation.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 12/9/21.
//

import Foundation
import UIKit
import CoreImage
extension UIImage {
func fixOrientation() -> UIImage {
    if self.imageOrientation == UIImage.Orientation.up {
return self

}

UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

    self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

    let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!

UIGraphicsEndImageContext()

return normalizedImage;

}

}

