//
//  PhotoPreviewView2.swift
//  testCamera
//
//  Created by MD SAZID HASAN DIP on 7/9/21.
//

import UIKit
import Photos
import CoreImage
//import CropViewController

protocol PhotoUsageDelegate: AnyObject {
    func useCapturedPhoto(image: UIImage)
    func sharePhoto(image: UIImage)
}

enum Fonts: String {
    case light = "Light"
    case Medium = "Medium"
    case Bold = "Bold"
}

@available(iOS 13.0, *)
class PhotoPreviewView2: UIView {
    
    @IBOutlet weak var textFunctionalityContainer: UIView!
    @IBOutlet weak var textAtributesContainer: UIView!
    @IBOutlet weak var fontColorButton: UIButton!
    @IBOutlet weak var fontButon: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var imageContainerView: UIView!
   // @IBOutlet weak var textLable: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    public var presentingViewController: UIViewController?
    var originalImage: UIImage?
    var fontAttributes: [NSAttributedString.Key : Any]!
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
        button.tintColor = .selected
        button.backgroundColor = .backgroundAlpha
        button.layer.cornerRadius = 5.0
        return button
    }()
    
    lazy private var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(handleSavePhoto), for: .touchUpInside)
        button.tintColor = .selected
        button.backgroundColor = .backgroundAlpha
        button.layer.cornerRadius = 5.0
        return button
    }()
    
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
    
    private var currentPoint: CGPoint!
    private var fontSize: CGFloat = 60.0
    private var dropDownForCrop = DropDown()
    private var fontMenuDropDown = DropDown()
    private var fontColorDropDown = DropDown()
    private var fontColor:UIColor = .white
    private var selectedFont: UIFont = UIFont.systemFont(ofSize: 60)
   // private var initialCenter: CGPoint = .zero
    private var textFieldInitialOrigin:CGPoint = .zero
    var photoUsageDelegate: PhotoUsageDelegate?
    var presetingViewController: UIViewController?
    init(frame: CGRect, presentingViewController: UIViewController?) {
        super.init(frame: frame)
        self.presentingViewController = presentingViewController
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
        dropDownMenuSetup()
        originalImage = photoImageView.image
        textField.font = self.selectedFont
        textField.textColor = self.fontColor
        textField.isHidden = true
        textAtributesContainer.isHidden = true
    }
    
    @objc private func handleCancel() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    @objc private func handleSharePhoto(){
        let items = [self.photoImageView.image]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentingViewController?.present(ac, animated: true, completion: {
            self.photoUsageDelegate?.sharePhoto(image: self.photoImageView.image!)
        })
    }
    
    @objc private func handleSavePhoto() {
        guard let previewImage = self.photoImageView.image else { return }
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    do {
                        try PHPhotoLibrary.shared().performChangesAndWait {
                            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
                            self.photoUsageDelegate?.useCapturedPhoto(image: previewImage)
                            self.handleCancel()
                        }
                    } catch let error {
                        print("failed to save photo in library: ", error)
                    }
                }
            } else {
                print("Something went wrong with permission...")
            }
        }
    }
    
    @IBAction func addTextButtonPressed(_ sender: UIButton) {
        if textField.text != nil , photoImageView.image != nil, self.fontAttributes != nil {
            if self.currentPoint == nil {
                self.currentPoint = CGPoint(x: textField.frame.origin.x, y: textField.frame.origin.y)
            }
                        photoImageView.image = textToImage(drawText: textField.text!, inImage: photoImageView.image!, atPoint: self.currentPoint)
                    }
        textField.text?.removeAll()
        textField.isHidden = true
        textAtributesContainer.isHidden = true
        //initialCenter = .zero
    }
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        dropDownForCrop.show()
    }
    
    @IBAction func cropButtonPressed(_ sender: UIButton) {
        presentCropViewController()
    }
    
    @IBAction func showTextField(_ sender: UIButton) {
        textField.backgroundColor = .backgroundAlpha
        textField.isHidden = textField.isHidden ? false : true
        textAtributesContainer.isHidden = textAtributesContainer.isHidden ? false: true
    }
    
    @IBAction func fontButtonPressed(_ sender: UIButton) {
        fontMenuDropDown.show()
    }
    
    @IBAction func fontColorButtonPressed(_ sender: UIButton) {
        fontColorDropDown.show()
    }
    
    func presentCropViewController() {
        let image: UIImage = getImage()
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        presentingViewController?.present(cropViewController, animated: true, completion: {
            print("Presenting Crop View Controller")
        })
    }
    
}

@available(iOS 13.0, *)
private extension PhotoPreviewView2  {
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        // Setup the font specific variables
        let size = image.size
            
        let widthRatio  = photoImageView.frame.width  / size.width
        let heightRatio = photoImageView.frame.height / size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
            
        textField.backgroundColor = .clear
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        //let scale2 = UIScreen.mai
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = self.fontAttributes
        
        // Put the image into a rectangle as large as the original image or the container
        // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: point.x, y: point.y, width:  newSize.width, height: newSize.height)
        
        // Draw the text into an image
        text.draw(in: rect.integral, withAttributes: textFontAttributes)
        
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
        self.imageContainerView.addSubview(doneButton)
        
        // Initialize Swipe Gesture Recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(didPan(_:)))
        textField.addGestureRecognizer(panGestureRecognizer)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        photoImageView.makeConstraints(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: 0, height: 0)
        
        cancelButton.makeConstraints(top: safeAreaLayoutGuide.topAnchor, left: nil, right: rightAnchor, bottom: nil, topMargin: 15, leftMargin: 0, rightMargin: 10, bottomMargin: 0, width: 50, height: 50)
        
        doneButton.makeConstraints(top: nil, left: nil, right: cancelButton.leftAnchor, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 5, bottomMargin: 0, width: 50, height: 50)
        doneButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
        
        textField.delegate = self
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            textFieldInitialOrigin = textField.frame.origin
            break
        case .changed:
            let translation = sender.translation(in: self.photoImageView)
            //textField.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            textField.frame.origin.x = textFieldInitialOrigin.x + translation.x
            textField.frame.origin.y = textFieldInitialOrigin.y + translation.y
//            self.currentPoint = CGPoint(x: translation.x, y: translation.y)
            print("X:: \(translation.x), Y::\(translation.y)")
        case .ended:
            self.currentPoint = CGPoint(x: textField.frame.origin.x, y: textField.frame.origin.y)
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
    
    private func dropDownCropMenuSetUp() {
        dropDownAppearance()
        // Do any additional setup after loading the view.
        dropDownForCrop.dataSource = ["Sepia", "Photo Transfer", "Noir","Blur","Clear Effect"]
        dropDownForCrop.anchorView =  filterButton
        dropDownForCrop.bottomOffset = CGPoint(x: 0, y:(dropDownForCrop.anchorView?.plainView.bounds.height)!)
        dropDownForCrop.topOffset = CGPoint(x: 0, y:-(dropDownForCrop.anchorView?.plainView.bounds.height)!)
        dropDownForCrop.direction = .bottom
        
        dropDownForCrop.selectionAction = { [unowned self] (index: Int, item: String) in
            switch index {
            case 0: print("at index: \(index) ", item)
                
                let image = getImage()
                photoImageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CISepiaTone", filterEffectValue: 0.70, filterEffectValueName: kCIInputIntensityKey))
        
            case 1: print("at index: \(index) ", item)
                let image = getImage()
                photoImageView.image = applyFilterTo(image: image,
                                                     filterEffect: Filter(filterName: "CIPhotoEffectProcess", filterEffectValue: nil,
                                                                          filterEffectValueName: nil))
                
            case 2: print("at index: \(index) ", item)
                let image = getImage()
                photoImageView.image = applyFilterTo(image: image,
                                                     filterEffect: Filter(filterName: "CIPhotoEffectNoir",
                                                                          filterEffectValue: nil,
                                                                          filterEffectValueName: nil))
                
            case 3: print("at index: \(index) ", item)
                let image = getImage()
                photoImageView.image = applyFilterTo(image: image,
                                                     filterEffect: Filter(filterName: "CIGaussianBlur", filterEffectValue: 8.0,
                                                                          filterEffectValueName: kCIInputRadiusKey))
            case 4: print("at index: \(index) ", item)
                photoImageView.image = getImage()
                
            default:
                break
            }
        }
    }
    
    private func dropDownFontMenuSetUp() {
        dropDownAppearance()
        fontMenuDropDown.dataSource = ["SystemFont", "Roboto", "Lobster"]
        fontMenuDropDown.anchorView =  fontButon
        fontMenuDropDown.bottomOffset = CGPoint(x: 0, y:(dropDownForCrop.anchorView?.plainView.bounds.height)!)
        fontMenuDropDown.topOffset = CGPoint(x: 0, y:-(dropDownForCrop.anchorView?.plainView.bounds.height)!)
        fontMenuDropDown.direction = .top
        
        fontMenuDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            
            guard let self = self else {return}
            switch index {
            case 0:
                self.selectedFont = UIFont.systemFont(ofSize: self.fontSize, weight: .bold)
                self.setupTextField(font: self.selectedFont, color: self.fontColor)
            case 1:
                self.selectedFont = UIFont(name: "Roboto-Medium", size: self.fontSize)! // ?? UIFont.systemFont(ofSize: 100, weight: .bold)
                self.setupTextField(font: self.selectedFont, color: self.fontColor)
            case 2:
                self.selectedFont = UIFont(name: "Lobster 1.4", size: self.fontSize)! //?? UIFont.systemFont(ofSize: 100, weight: .bold)
                self.setupTextField(font: self.selectedFont, color: self.fontColor)
            default:
                break
            }
        }
    }

    private func dropDownFontColorMenuSetUp() {
        
        dropDownAppearance()
        // Do any additional setup after loading the view.
        fontColorDropDown.dataSource = ["Green", "Blue", "Yellow","White","Black"]
        fontColorDropDown.anchorView =  fontColorButton
        fontColorDropDown.bottomOffset = CGPoint(x: 0, y:(dropDownForCrop.anchorView?.plainView.bounds.height)!)
        fontColorDropDown.topOffset = CGPoint(x: 0, y:-(dropDownForCrop.anchorView?.plainView.bounds.height)!)
        fontColorDropDown.direction = .top
        fontColorDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else {return}
            switch index {
            case 0: print("at index: \(index) ", item)
                self.fontColor = .green
                self.setupTextField(font: self.selectedFont, color: self.fontColor)
                
            case 1: print("at index: \(index) ", item)
                self.fontColor = .blue
                self.setupTextField(font: self.selectedFont, color: self.fontColor)
                
            case 2: print("at index: \(index) ", item)
                self.fontColor = .yellow
                self.setupTextField(font: self.selectedFont, color: self.fontColor)
                
            case 3: print("at index: \(index) ", item)
                self.fontColor = .white
                self.setupTextField(font: self.selectedFont, color: self.fontColor)
                
            case 4: print("at index: \(index) ", item)
                self.fontColor = .black
                self.setupTextField(font: self.selectedFont, color: self.fontColor)
            default:
                break
            }
        }
    }
    
    func dropDownMenuSetup() {
        dropDownCropMenuSetUp()
        dropDownFontMenuSetUp()
        dropDownFontColorMenuSetUp()
    }
    
    func dropDownAppearance() {
        DropDown.appearance().backgroundColor = UIColor(named: "BackgroundAlpha60" )
        DropDown.appearance().textColor = UIColor.white
        DropDown.appearance().selectedTextColor = UIColor(named: "Selected" )!
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        DropDown.appearance().selectionBackgroundColor = UIColor.clear
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
    
    func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage? {
        
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
    
    func setupTextField(font: UIFont = UIFont.systemFont(ofSize: 50, weight: .bold), color: UIColor = .white) {
        self.textField.font = font
        self.textField.textColor = color
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
        ]
        self.fontAttributes = textFontAttributes
        
        layoutIfNeeded()
    }
}

@available(iOS 13.0, *)
extension PhotoPreviewView2: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text?.removeAll()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
     
      //  let attributedString = NSAttributedString(string: text!, attributes: self.fontAttributes)
        if self.fontAttributes == nil {
            let textFontAttributes = [
                NSAttributedString.Key.font: selectedFont,
                NSAttributedString.Key.foregroundColor: fontColor,
            ]
            self.fontAttributes = textFontAttributes
        }
        print(textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}

@available(iOS 13.0, *)
extension PhotoPreviewView2: CropViewControllerDelegate {

func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
    // 'image' is the newly cropped version of the original image
    photoImageView.image = image
    cropViewController.dismiss(animated: true, completion: nil)
}
}
