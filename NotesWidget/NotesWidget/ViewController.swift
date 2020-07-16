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
    @IBOutlet weak var TextOverlayLabelSmall: UILabel!
    @IBOutlet weak var TextOverlayLabelSmall1: UILabel!
    @IBOutlet weak var TextOverlayLabelSmall2: UILabel!
    @IBOutlet weak var TextOverlayLabelSmall3: UILabel!
    @IBOutlet weak var TextOverlayLabelMedium: UILabel!
    @IBOutlet weak var TextOverlayLabelMedium1: UILabel!
    @IBOutlet weak var TextOverlayLabelMedium2: UILabel!
    @IBOutlet weak var TextOverlayLabelMedium3: UILabel!
    @IBOutlet weak var TextOverlayLabelLarge: UILabel!
    @IBOutlet weak var TextOverlayLabelLarge1: UILabel!
    @IBOutlet weak var TextOverlayLabelLarge2: UILabel!
    @IBOutlet weak var TextOverlayLabelLarge3: UILabel!
    @IBOutlet weak var DeleteTextButton: UIButton!
    @IBOutlet weak var PositionSlider: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        smallLabels.append(TextOverlayLabelSmall)
        smallLabels.append(TextOverlayLabelSmall1)
        smallLabels.append(TextOverlayLabelSmall2)
        smallLabels.append(TextOverlayLabelSmall3)
        
        mediumLabels.append(TextOverlayLabelMedium)
        mediumLabels.append(TextOverlayLabelMedium1)
        mediumLabels.append(TextOverlayLabelMedium2)
        mediumLabels.append(TextOverlayLabelMedium3)

        largeLabels.append(TextOverlayLabelLarge)
        largeLabels.append(TextOverlayLabelLarge1)
        largeLabels.append(TextOverlayLabelLarge2)
        largeLabels.append(TextOverlayLabelLarge3)

        addDoneButtonOnKeyboard()
        
        currentImgView = ImageView
        
        loadStoredValue()
        loadPositionValue()
        loadTextValue()
    }
    override func viewDidDisappear(_ animated: Bool) {
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidgetTarget")
    }
    
    var uploadedImage: UIImage!
    var currentImgView: UIImageView!
    enum ePosition: String{
        case lower_left = "LL"
        case lower_right = "LR"
        case upper_left = "UL"
        case upper_right = "UR"
        case random_pos = "RP"
    }
    var currentPosition: ePosition!
    var smallLabels: [UILabel] = []
    var mediumLabels: [UILabel] = []
    var largeLabels: [UILabel] = []
    
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
            smallLabels.forEach{label in label.isHidden = false}
            mediumLabels.forEach{label in label.isHidden = true}
            largeLabels.forEach{label in label.isHidden = true}
            break
        case 1:
            currentImgView = ImageViewMedium
            ImageView.isHidden = true
            ImageViewMedium.isHidden = false
            ImageVIewLarge.isHidden = true
            smallLabels.forEach{label in label.isHidden = true}
            mediumLabels.forEach{label in label.isHidden = false}
            largeLabels.forEach{label in label.isHidden = true}
            break
        case 2:
            currentImgView = ImageVIewLarge
            ImageView.isHidden = true
            ImageViewMedium.isHidden = true
            ImageVIewLarge.isHidden = false
            smallLabels.forEach{label in label.isHidden = true}
            mediumLabels.forEach{label in label.isHidden = true}
            largeLabels.forEach{label in label.isHidden = false}
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
    }
    @IBAction func TextboxEditing(_ sender: Any) {
        updateTextValue()
        // TODO:
        //Prevent overflow by looking at the frame values of the label, thrid column.
    }
    @IBAction func DeleteTextButton(_ sender: Any) {
        TextOverlayTextbox.text = ""
        updateTextValue()
    }
    @IBAction func PositionSliderChanged(_ sender: Any) {
        switch PositionSlider.selectedSegmentIndex {
        case 0:
            currentPosition = .lower_left
            break
        case 1:
            currentPosition = .lower_right
            break
        case 2:
            currentPosition = .upper_left
            break
        case 3:
            currentPosition = .upper_right
            break
        case 4:
            currentPosition = .random_pos
            break
        default:
            currentPosition = .lower_right
            break
        }
        updatePositionValue()
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
        
        loadTextValue()
        
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidgetTarget")
    }
    func updatePositionValue(){
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
            userDefaults.set(currentPosition.rawValue, forKey: "POS_DATA")
        }
        
        loadTextValue()
        
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
            storedTxtData = userDefaults.string(forKey: "TEXT_DATA") ?? ""
        }
        //add overlay to selected image
        smallLabels.forEach{label in label.text = ""}
        mediumLabels.forEach{label in label.text = ""}
        largeLabels.forEach{label in label.text = ""}
        switch currentPosition {
        case .lower_left:
            smallLabels[1].text = storedTxtData
            mediumLabels[1].text = storedTxtData
            largeLabels[1].text = storedTxtData
            break
        case .lower_right:
            smallLabels[0].text = storedTxtData
            mediumLabels[0].text = storedTxtData
            largeLabels[0].text = storedTxtData
            break
        case .upper_left:
            smallLabels[2].text = storedTxtData
            mediumLabels[2].text = storedTxtData
            largeLabels[2].text = storedTxtData
            break
        case .upper_right:
            smallLabels[3].text = storedTxtData
            mediumLabels[3].text = storedTxtData
            largeLabels[3].text = storedTxtData
            break
        default:
            smallLabels[0].text = storedTxtData
            mediumLabels[0].text = storedTxtData
            largeLabels[0].text = storedTxtData
            break
        }
        
        TextOverlayTextbox.text = storedTxtData
    }
    func loadPositionValue(){
        var storedPosData: ePosition!
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            storedPosData = ePosition(rawValue: userDefaults.string(forKey: "POS_DATA") ?? "LR")
        }

        currentPosition = storedPosData
        
        switch currentPosition {
        case .lower_left:
            PositionSlider.selectedSegmentIndex = 0
            break
        case .lower_right:
            PositionSlider.selectedSegmentIndex = 1
            break
        case .upper_left:
            PositionSlider.selectedSegmentIndex = 2
            break
        case .upper_right:
            PositionSlider.selectedSegmentIndex = 3
            break
        case .random_pos:
            PositionSlider.selectedSegmentIndex = 4
            break
        default:
            break
        }
        
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}
