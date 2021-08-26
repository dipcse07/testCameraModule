//
//  TorchView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 24/8/21.
//

import UIKit

enum TorchMode {
    case on, off
}

protocol TorchViewDelegate: AnyObject {
    func torchTapped(torchMode: TorchMode, completionHandler: (Bool) -> Void )
}

class TorchView: UIView {

    @IBOutlet private weak var contentView: UIView!
   
    @IBOutlet weak var torchButton: UIButton!
    
    
    private var torchMode = TorchMode.off
    weak var delegate: TorchViewDelegate?
    
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
    
    @IBAction func torchButtoPressed(_ sender: UIButton) {
        delegate?.torchTapped(torchMode: torchMode, completionHandler: { [weak self] success in
            guard let self = self else {return }
            guard success else {return}
            switch torchMode {
            case .on:
                torchButton.tintColor = .textOnBackgroundAlpha
                self.torchMode = .off
            case .off:
                torchButton.tintColor = .selected
                self.torchMode = .on
            }
        })
    }
    
}
