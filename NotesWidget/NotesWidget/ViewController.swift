//
//  ViewController.swift
//  NotesWidget
//
//  Created by Andrew Rotert on 7/3/20.
//

import UIKit
import WidgetKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var SelectImageButton: UIButton!
    @IBOutlet weak var SizeSlider: UISegmentedControl!
    @IBOutlet weak var ImageViewMedium: UIImageView!
    @IBOutlet weak var ImageVIewLarge: UIImageView!
    @IBOutlet weak var DeleteImageButton: UIButton!
    @IBOutlet weak var TextOverlayTextbox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addDoneButtonOnKeyboard()
        
        currentImgView = ImageView
        
        loadStoredValue()
    }
    
    var uploadedImage: UIImage!
    var currentImgView: UIImageView!
    
    @IBAction func SelectImageClicked(_ sender: Any) {
        let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
    }
    @IBAction func SliderChanged(_ sender: Any) {
        switch SizeSlider.selectedSegmentIndex {
        case 0:
            currentImgView = ImageView
            ImageView.isHidden = false
            ImageViewMedium.isHidden = true
            ImageVIewLarge.isHidden = true
            break
        case 1:
            currentImgView = ImageViewMedium
            ImageView.isHidden = true
            ImageViewMedium.isHidden = false
            ImageVIewLarge.isHidden = true
            break
        case 2:
            currentImgView = ImageVIewLarge
            ImageView.isHidden = true
            ImageViewMedium.isHidden = true
            ImageVIewLarge.isHidden = false
            break
        default:
            break
        }
        loadStoredValue()
    }
    @IBAction func DeleteImageClicked(_ sender: Any) {
        removeStoredValue()
    }
    @IBAction func TextChanged(_ sender: Any) {
        updateTextValue()
        loadTextValue()
    }
    
    func updateStoredValue(){
        if let imgData = uploadedImage?.pngData(){
            if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
                userDefaults.set(imgData as Data, forKey: "IMG_DATA")
            }
        }
        
        currentImgView.image = uploadedImage
        currentImgView.contentMode = .scaleAspectFill
        
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidgetTarget")
    }
    func updateTextValue(){
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
            userDefaults.set(TextOverlayTextbox.text, forKey: "TEXT_DATA")
        }
        
        currentImgView.image = uploadedImage
        currentImgView.contentMode = .scaleAspectFill
        
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidgetTarget")
    }
    func removeStoredValue(){
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
            userDefaults.set(nil, forKey: "IMG_DATA")
        }
        
        loadStoredValue()
    }
    
    func loadStoredValue(){
        var storedImgData: Data!
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            storedImgData = userDefaults.data(forKey: "IMG_DATA")
        }
        if(storedImgData != nil){
            currentImgView.image = UIImage.init(data: storedImgData)
            currentImgView.contentMode = .scaleAspectFill
        }
        else{
            currentImgView.image = UIImage.init(named: "DefaultImage")
            currentImgView.contentMode = .scaleAspectFill
        }
    }
    func loadTextValue(){
        var storedTxtData: String = ""
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            storedTxtData = userDefaults.string(forKey: "TEXT_DATA")!
        }
        //add overlay to selected image
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        uploadedImage = image
        updateStoredValue()
    }
    
    func addDoneButtonOnKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            TextOverlayTextbox.inputAccessoryView = doneToolbar
        }

        @objc func doneButtonAction(){
            TextOverlayTextbox.resignFirstResponder()
        }

}

//    var returnValue: [datatype]? = UserDefaults.standard.object(forKey: "key_name") as? [datatype]
//    UserDefaults.standard.removeObject(forKey:"key_name")
