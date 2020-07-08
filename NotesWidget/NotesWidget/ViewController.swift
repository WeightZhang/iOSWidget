//
//  ViewController.swift
//  NotesWidget
//
//  Created by Andrew Rotert on 7/3/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var SelectImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            //TextBox1.text = userDefaults.string(forKey: "TEXT1") ?? ""
            //TextBox2.text = userDefaults.string(forKey: "TEXT2") ?? ""
            //TextBox3.text = userDefaults.string(forKey: "TEXT3") ?? ""
            //TextBox4.text = userDefaults.string(forKey: "TEXT4") ?? ""
            //TextBox5.text = userDefaults.string(forKey: "TEXT5") ?? ""
        //}
        
        updateStoredValue()
    }
    @IBAction func SelectImageClicked(_ sender: Any) {
    }
    
    @IBAction func SaveClicked(_ sender: Any) {
        //let text1 = TextBox1.text
        //let text2 = TextBox2.text
        //let text3 = TextBox3.text
        //let text4 = TextBox4.text
        //let text5 = TextBox5.text
        
        //if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
        //    userDefaults.set((text1 ?? "") as String, forKey: "TEXT1")
        //    userDefaults.set((text2 ?? "") as String, forKey: "TEXT2")
        //    userDefaults.set((text3 ?? "") as String, forKey: "TEXT3")
        //    userDefaults.set((text4 ?? "") as String, forKey: "TEXT4")
        //    userDefaults.set((text5 ?? "") as String, forKey: "TEXT5")
        //}

        updateStoredValue()
    }
    @IBAction func SliderChanged(_ sender: Any) {
        //TextPreview.backgroundColor = SelectedColor[ColorSlider.selectedSegmentIndex]
        //if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
        //    userDefaults.set((ColorSlider.selectedSegmentIndex) as Int, forKey: "BACKGROUND")
        //}
    }
    
    func updateStoredValue(){
        /*var storedValue1: String = ""
        var storedValue2: String = ""
        var storedValue3: String = ""
        var storedValue4: String = ""
        var storedValue5: String = ""

        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            storedValue1 = userDefaults.string(forKey: "TEXT1") ?? ""
            storedValue2 = userDefaults.string(forKey: "TEXT2") ?? ""
            storedValue3 = userDefaults.string(forKey: "TEXT3") ?? ""
            storedValue4 = userDefaults.string(forKey: "TEXT4") ?? ""
            storedValue5 = userDefaults.string(forKey: "TEXT5") ?? ""
        }
        
        TextPreview.text = ""
        TextPreview.text.append(storedValue1)
        TextPreview.text.append("\n")
        TextPreview.text.append(storedValue2)
        TextPreview.text.append("\n")
        TextPreview.text.append(storedValue3)
        TextPreview.text.append("\n")
        TextPreview.text.append(storedValue4)
        TextPreview.text.append("\n")
        TextPreview.text.append(storedValue5)
        */
    }

}

//    var returnValue: [datatype]? = UserDefaults.standard.object(forKey: "key_name") as? [datatype]
//    UserDefaults.standard.removeObject(forKey:"key_name")
