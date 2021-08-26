//
//  AppSetup.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 2/8/21.
//

import Foundation
import UIKit

class CameraModuleSetup {
    static func loadCaptureViewController () {
        let nibName = String(describing: CaptureViewController.self)
        let bundle = Bundle.main
        let captureViewController = CaptureViewController(nibName: nibName, bundle: bundle)
        let window = Self.keyWindow
        window?.rootViewController = captureViewController
        window?.makeKeyAndVisible()
    }
    
    static var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first(where:{  $0.isKeyWindow
        })
    }
    
    static var interfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }
    
}
