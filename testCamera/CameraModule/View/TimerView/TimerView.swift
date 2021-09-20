//
//  TimerView.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 7/8/21.
//

import UIKit

class TimerView: UIView {

    @IBOutlet private weak var contentView:UIView!
    @IBOutlet weak var timerLabel: UILabel!
    var updatedSecond:String = "00:00"
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
    }
    
    func updateTime(seconds: Int64) {
        
        let timerInterval = TimeInterval(integerLiteral: seconds)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let formatedString  = formatter.string(from: timerInterval) ?? "00:00"
    
        updatedSecond = formatedString
        timerLabel.text = updatedSecond
    }
    

}
