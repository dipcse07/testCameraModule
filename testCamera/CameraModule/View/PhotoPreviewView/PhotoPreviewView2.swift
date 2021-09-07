//
//  PhotoPreviewView2.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 7/9/21.
//

import UIKit
import Photos
import CoreImage

protocol PhotoUsageDelegate: AnyObject {
    func useCapturedPhoto(image: UIImage)
}

class PhotoPreviewView2: UIView {
    
    struct Filter {
        let filterName: String
        var filterEffectValue: Any?
        var filterEffectValueName:String?
        
        init(filterName: String, filterEffectValue: Any?,filterEffectValueName:String?){
            self.filterName = filterName
            self.filterEffectValue = filterEffectValue
            self.filterEffectValueName = filterEffectValueName
        }
        
    }
    
    private func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage? {
        
        
        guard let cgImage = image.cgImage, let openGLContext = EAGLContext(api: .openGLES3) else {
            return nil
        }
        
        let context = CIContext(eaglContext: openGLContext)
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: filterEffect.filterName)
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey )
       
        if let filterEffectValue = filterEffect.filterEffectValue, let filterEffectValueName = filterEffect.filterEffectValueName {
            filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
        }
    
        var filteredImage: UIImage?
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
           let cgiImageResult = context.createCGImage(output, from: output.extent){
            filteredImage = UIImage(cgImage: cgiImageResult)
            
        }
        
        return filteredImage
    }
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var textLable: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    var originalImage: UIImage?
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
    
    var dropDown = DropDown()
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
        dropDownMenuSetUp()
        originalImage = photoImageView.image
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
//                        print("photo has saved in library...")
                       
                        
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
        self.showAlert(message: "Photo has been saved")
    }

    @IBAction func addTextButtonPressed(_ sender: UIButton) {
//        initialCenter = textLable.center
        
        if textLable.text != nil , photoImageView.image != nil {
            photoImageView.image = textToImage(drawText: textLable.text!, inImage: photoImageView.image!, atPoint: textLable.center)
        }
        textLable.text?.removeAll()
        initialCenter = .zero
    }
    
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        dropDown.show()
    }
    
}


private extension PhotoPreviewView2  {
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        // Setup the font specific variables
        var textColor = UIColor.white
           var textFont = UIFont(name: "Helvetica Bold", size: 48)!

           // Setup the image context using the passed image
        let scale = UIScreen.main.scale
           UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

           // Setup the font attributes that will be later used to dictate how the text should be drawn
           let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
           ]

           // Put the image into a rectangle as large as the original image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

           // Create a point within the space that is as bit as the image
        let rect = CGRect(x: point.x, y: point.y, width: image.size.width, height: image.size.height)

           // Draw the text into an image
        text.draw(in: rect, withAttributes: textFontAttributes)

           // Create a new image out of the images we have created
           let newImage = UIGraphicsGetImageFromCurrentImageContext()

           // End the context now that we have the image we need
           UIGraphicsEndImageContext()

           //Pass the image back up to the caller
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
                
        case .ended:
            let translation = sender.translation(in: sender.view)
            textLable.center = CGPoint(x: initialCenter.x + translation.x,
                                          y: initialCenter.y + translation.y)
            initialCenter = textLable.center
            default:
                break
            }
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
        // duration in seconds
        let duration: Double = 2
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
    private func dropDownMenuSetUp() {
        DropDown.appearance().backgroundColor = UIColor(named: "BackgroundAlpha60" )
        DropDown.appearance().textColor = UIColor.white
        DropDown.appearance().selectedTextColor = UIColor(named: "Selected" )!
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        DropDown.appearance().selectionBackgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
        dropDown.dataSource = ["Sepia", "Photo Transfer", "Noir","Blur","Clear Effect"]
        dropDown.anchorView =  filterButton
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            switch index {
            case 0: print("at index: \(index) ", item)
  
                let image = getImage()
                photoImageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CISepiaTone", filterEffectValue: 0.70, filterEffectValueName: kCIInputIntensityKey))
                
        
            case 1: print("at index: \(index) ", item)
                let image = getImage()
                photoImageView.image = applyFilterTo(image: image,
                filterEffect: Filter(filterName: "CIPhotoEffectProcess", filterEffectValue: nil, filterEffectValueName: nil))
            
            case 2: print("at index: \(index) ", item)
                let image = getImage()
                photoImageView.image = applyFilterTo(image: image,
                                                     filterEffect: Filter(filterName: "CIPhotoEffectNoir",
                                                                          filterEffectValue: nil,
                                                                          filterEffectValueName: nil))
                
            case 3: print("at index: \(index) ", item)
                let image = getImage()
                photoImageView.image = applyFilterTo(image: image,
                                                     filterEffect: Filter(filterName: "CIGaussianBlur", filterEffectValue: 8.0, filterEffectValueName: kCIInputRadiusKey))
                
                
            case 4: print("at index: \(index) ", item)
                
                photoImageView.image = getImage()
                
            default:
                break
            }
        }
        
    }
    
    private func getImage () -> UIImage {
        var image: UIImage
        if originalImage == nil {
            originalImage = photoImageView.image
            image = originalImage!
            
        }else {
            image = originalImage!
        }
        
        return image
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
