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
    @IBOutlet weak var TextOverlayCenter: UILabel!
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
    @IBOutlet weak var CenterPositionLabel: UILabel!
    @IBOutlet weak var HowToLabel: UILabel!
    var textFieldView: UITextField!
    @IBOutlet weak var PageControlView: UIPageControl!
    @IBOutlet weak var AddNewImageButton: UIButton!
    @IBOutlet weak var LastImageButton: UIButton!
    
    static var globalVersionNumber: Int = -1
    var localVersionNumber: Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        ViewController.globalVersionNumber += 1
        localVersionNumber = ViewController.globalVersionNumber
        
        PageControlView.numberOfPages = countSavedData()
        PageControlView.currentPage = localVersionNumber
        
        if(localVersionNumber == 0){
            LastImageButton.isEnabled = false
        }
        
        HowToLabel.text?.append("Widget previews are shown above\n\n")
        HowToLabel.text?.append("Customize your widget in four steps:\n")
        HowToLabel.text?.append("1. Select an image from your photos.\n")
        HowToLabel.text?.append("2. Crop your image.\n")
        HowToLabel.text?.append("3. Add a text overlay to your widget.\n")
        HowToLabel.text?.append("4. Choose the text overlay position: \n")
        HowToLabel.text?.append("\t-Bottom Left.\n")
        HowToLabel.text?.append("\t-Bottom Right.\n")
        HowToLabel.text?.append("\t-Top Left.\n")
        HowToLabel.text?.append("\t-Top Right.\n")
        HowToLabel.text?.append("\t-Dynamically Changing (10min).\n\n")
        HowToLabel.text?.append("Add widget to home screen:\n")
        HowToLabel.text?.append("1. Long press on the home screen.\n")
        HowToLabel.text?.append("2. Tap the plus icon in the top left corner.\n")
        HowToLabel.text?.append("3. Select the widget size.\n\n")
        HowToLabel.text?.append("Add and Remove multiple photos\n")
        HowToLabel.text?.append(" - The widget selects a random photo every 10min.\n")
        HowToLabel.text?.append(" - Add as many as you want.\n")


        smallLabels.append(TextOverlayLabelSmall)
        smallLabels.append(TextOverlayLabelSmall1)
        smallLabels.append(TextOverlayLabelSmall2)
        smallLabels.append(TextOverlayLabelSmall3)
        
        //mediumLabels.append(TextOverlayLabelMedium)
        //mediumLabels.append(TextOverlayLabelMedium1)
        //mediumLabels.append(TextOverlayLabelMedium2)
        //mediumLabels.append(TextOverlayLabelMedium3)
        mediumLabels.append(TextOverlayCenter)
        
        largeLabels.append(TextOverlayLabelLarge)
        largeLabels.append(TextOverlayLabelLarge1)
        largeLabels.append(TextOverlayLabelLarge2)
        largeLabels.append(TextOverlayLabelLarge3)

        let smallImgViewSize = ImageView.frame.width
        let mediumImgViewSize = ImageViewMedium.frame.width
        let largeImgViewSize = ImageVIewLarge.frame.width
        smallLabels.forEach{label in label.preferredMaxLayoutWidth = (smallImgViewSize-9)}
        mediumLabels.forEach{label in label.preferredMaxLayoutWidth = (mediumImgViewSize-9)}
        largeLabels.forEach{label in label.preferredMaxLayoutWidth = (largeImgViewSize-9)}
                        
        addCustomKeyboardControls()
        
        currentImgView = ImageView
        
        loadWidgetPreview()
        loadStoredImageValue()
        loadPositionValue()
        loadTextValue()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidgetTarget")
        ViewController.globalVersionNumber -= 1
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
        loadWidgetPreview()
        loadStoredImageValue()
    }
    @IBAction func DeleteImageClicked(_ sender: Any) {
        removeStoredImageValue()
    }
    @IBAction func TextChanged(_ sender: Any) {
        updateTextValue()
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidgetTarget")
    }
    @IBAction func TextboxEditing(_ sender: Any) {
        updateTextValue()
    }
    @IBAction func DeleteTextButton(_ sender: Any) {
        removeStoredTextValue()
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
    @IBAction func AddNewImageClicked(_ sender: Any) {
        addNewImageView()
    }
    @IBAction func LastImageClicked(_ sender: Any) {
        lastImageView()
    }
    
    func updateStoredImageValue(){
        if let imgData = uploadedImage?.pngData(){
            if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
                userDefaults.set(imgData as Data, forKey: "IMG_DATA\(localVersionNumber ?? 0)")
            }
        }
        
        currentImgView.image = uploadedImage
        currentImgView.contentMode = .scaleAspectFill
        
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidgetTarget")
    }
    func updateTextValue(){
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
            userDefaults.set(TextOverlayTextbox.text, forKey: "TEXT_DATA\(localVersionNumber ?? 0)")
        }
        
        loadTextValue()        
    }
    func updatePositionValue(){
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
            userDefaults.set(currentPosition.rawValue, forKey: "POS_DATA\(localVersionNumber ?? 0)")
        }
        
        loadTextValue()
        
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidgetTarget")
    }
    func removeStoredImageValue(){
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
            userDefaults.set(nil, forKey: "IMG_DATA\(localVersionNumber ?? 0)")
        }
        
        loadStoredImageValue()
        removeStoredTextValue()
    }
    func removeStoredTextValue(){
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
            userDefaults.set(nil, forKey: "TEXT_DATA\(localVersionNumber ?? 0)")
        }
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget"){
            userDefaults.set(nil, forKey: "POS_DATA\(localVersionNumber ?? 0)")
        }
        
        loadTextValue()
        loadPositionValue()
    }
    
    func loadWidgetPreview(){
        switch SizeSlider.selectedSegmentIndex {
        case 0:
            currentImgView = ImageView
            ImageView.isHidden = false
            ImageViewMedium.isHidden = true
            ImageVIewLarge.isHidden = true
            smallLabels.forEach{label in label.isHidden = false}
            mediumLabels.forEach{label in label.isHidden = true}
            largeLabels.forEach{label in label.isHidden = true}
            PositionSlider.isHidden = false
            break
        case 1:
            currentImgView = ImageViewMedium
            ImageView.isHidden = true
            ImageViewMedium.isHidden = false
            ImageVIewLarge.isHidden = true
            smallLabels.forEach{label in label.isHidden = true}
            mediumLabels.forEach{label in label.isHidden = false}
            largeLabels.forEach{label in label.isHidden = true}
            PositionSlider.isHidden = true
            break
        case 2:
            currentImgView = ImageVIewLarge
            ImageView.isHidden = true
            ImageViewMedium.isHidden = true
            ImageVIewLarge.isHidden = false
            smallLabels.forEach{label in label.isHidden = true}
            mediumLabels.forEach{label in label.isHidden = true}
            largeLabels.forEach{label in label.isHidden = false}
            PositionSlider.isHidden = false
            break
        default:
            break
        }
    }
    
    func loadStoredImageValue(){
        var storedImgData: Data!
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            storedImgData = userDefaults.data(forKey: "IMG_DATA\(localVersionNumber ?? 0)")
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
            storedTxtData = userDefaults.string(forKey: "TEXT_DATA\(localVersionNumber ?? 0)") ?? ""
        }
        //add overlay to selected image
        smallLabels.forEach{label in label.text = ""}
        mediumLabels.forEach{label in label.text = ""}
        largeLabels.forEach{label in label.text = ""}
                
        switch currentPosition {
        case .lower_left:
            smallLabels[1].text = storedTxtData
            mediumLabels[0].text = storedTxtData
            largeLabels[1].text = storedTxtData
            break
        case .lower_right:
            smallLabels[0].text = storedTxtData
            mediumLabels[0].text = storedTxtData
            largeLabels[0].text = storedTxtData
            break
        case .upper_left:
            smallLabels[2].text = storedTxtData
            mediumLabels[0].text = storedTxtData
            largeLabels[2].text = storedTxtData
            break
        case .upper_right:
            smallLabels[3].text = storedTxtData
            mediumLabels[0].text = storedTxtData
            largeLabels[3].text = storedTxtData
            break
        default:
            smallLabels[0].text = storedTxtData
            mediumLabels[0].text = storedTxtData
            largeLabels[0].text = storedTxtData
            break
        }
        
        TextOverlayTextbox.text = storedTxtData
        textFieldView.text = storedTxtData
    }
    func loadPositionValue(){
        var storedPosData: ePosition!
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            storedPosData = ePosition(rawValue: userDefaults.string(forKey: "POS_DATA\(localVersionNumber ?? 0)") ?? "LR")
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
    func isImageDataLoaded() -> Bool {
        var storedImgData: Data!
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            storedImgData = userDefaults.data(forKey: "IMG_DATA\(localVersionNumber ?? 0)")
            if(storedImgData != nil){
                return true
            }
        }
        return false
    }
    
    func countSavedData() -> Int{
        var foundImgDataCounter: Int = 0
        var storedImgData: Data!
        repeat {
            if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
                storedImgData = userDefaults.data(forKey: "IMG_DATA\(foundImgDataCounter)")
                if(storedImgData != nil){
                    foundImgDataCounter += 1
                }
                else if(foundImgDataCounter == localVersionNumber){
                    foundImgDataCounter += 1    //Image on the loaded page is nil, we still want page to count
                }
            }
        } while(storedImgData != nil)
        
        return foundImgDataCounter
    }
    
    func addNewImageView(){
        if(isImageDataLoaded()){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newView = storyboard.instantiateViewController(withIdentifier: "ViewController")
            newView.modalPresentationStyle = .overFullScreen
            show(newView, sender: self)
        }
    }
    
    func lastImageView(){
        if(localVersionNumber != 0){
            if let parent = presentingViewController as? ViewController{
                parent.PageControlView.numberOfPages = parent.countSavedData()
            }
            dismiss(animated: true) {
                
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        uploadedImage = image
        updateStoredImageValue()
    }
    
    func addCustomKeyboardControls(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
            
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        textFieldView = UITextField(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width-100, height: 50))
        textFieldView.addTarget(self, action: #selector(self.textFieldViewAction), for: .editingChanged)
        let textfieldBarButton = UIBarButtonItem.init(customView: textFieldView)
        
        let items = [textfieldBarButton, flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        TextOverlayTextbox.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        TextOverlayTextbox.resignFirstResponder()
        textFieldView.resignFirstResponder()
        TextOverlayTextbox.endEditing(true)
        textFieldView.endEditing(true)
    }
    @objc func textFieldViewAction(){
        TextOverlayTextbox.text = textFieldView.text
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
    @IBAction func SwipedRight(_ sender: Any) {
        lastImageView()
    }
    @IBAction func SwipeLeft(_ sender: Any) {
        addNewImageView()
    }
    
}
