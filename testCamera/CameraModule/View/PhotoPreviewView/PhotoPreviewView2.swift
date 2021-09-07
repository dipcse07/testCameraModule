//
//  PhotoPreviewView2.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 7/9/21.
//

import UIKit
import Photos

protocol PhotoUsageDelegate: AnyObject {
    func useCapturedPhoto(image: UIImage)
}

class PhotoPreviewView2: UIView, UIGestureRecognizerDelegate {
    
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var textLable: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    lazy private var savePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(handleSavePhoto), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    
    private var initialCenter: CGPoint = .zero
    var photoUsageDelegate: PhotoUsageDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addSubviews(photoImageView, cancelButton, savePhotoButton)
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
        setupContainerView()
    }
    
    @objc private func handleCancel() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    @objc private func handleSavePhoto() {
        
        guard let previewImage = self.photoImageView.image else { return }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                do {
                    try PHPhotoLibrary.shared().performChangesAndWait {
                        PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
                        print("photo has saved in library...")
                        self.photoUsageDelegate?.useCapturedPhoto(image: previewImage)
                        self.handleCancel()
                    }
                } catch let error {
                    print("failed to save photo in library: ", error)
                }
            } else {
                print("Something went wrong with permission...")
            }
        }
    }

    @IBAction func addTextButtonPressed(_ sender: UIButton) {
        if textLable.text != nil , photoImageView.image != nil {
            photoImageView.image = textToImage(drawText: textLable.text!, inImage: photoImageView.image!, atPoint: initialCenter)
        }
    }
    
}


private extension PhotoPreviewView2  {
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func setupContainerView() {
        
        
        self.imageContainerView.addSubview(photoImageView)
        self.imageContainerView.addSubview(cancelButton)
        self.imageContainerView.addSubview(savePhotoButton)
        
        // Initialize Swipe Gesture Recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(didPan(_:)))
        textLable.addGestureRecognizer(panGestureRecognizer)
        textLable.translatesAutoresizingMaskIntoConstraints = false
        
        photoImageView.makeConstraints(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: 0, height: 0)
        
        cancelButton.makeConstraints(top: safeAreaLayoutGuide.topAnchor, left: nil, right: rightAnchor, bottom: nil, topMargin: 15, leftMargin: 0, rightMargin: 10, bottomMargin: 0, width: 50, height: 50)
        
        savePhotoButton.makeConstraints(top: nil, left: nil, right: cancelButton.leftAnchor, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 5, bottomMargin: 0, width: 50, height: 50)
        savePhotoButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
        
        textField.delegate = self
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {

        switch sender.state {
            case .began:
                initialCenter = textLable.center
                
            case .changed:
                let translation = sender.translation(in: sender.view)

                textLable.center = CGPoint(x: initialCenter.x + translation.x,
                                              y: initialCenter.y + translation.y)
                initialCenter = textLable.center
                print("panLabel changed")
            default:
                break
            }
    }
}


extension PhotoPreviewView2: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textLable.text = textField.text
        print(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
