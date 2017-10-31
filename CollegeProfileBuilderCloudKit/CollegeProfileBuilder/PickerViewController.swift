//
//  PickerViewController.swift
//  CollegeProfileBuilder
//
//  Created by Alisha Fong on 10/6/17.
//  Copyright © 2017 Alisha Fong. All rights reserved.
//

import UIKit
import CloudKit

class PickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var selectedCollege = CKRecord(recordType: "College")
    var dataBase: CKDatabase!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.94, green:0.84, blue:0.82, alpha:1.0)
        imagePicker.delegate = self
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)

        // Do any additional setup after loading the view.
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage = UIImage()
        imagePicker.dismiss(animated: true)
        {
            
            selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let imageData = UIImagePNGRepresentation(selectedImage)
            self.selectedCollege.setObject(imageData as! CKRecordValue, forKey: "pinData")
            self.dataBase.save(self.selectedCollege, completionHandler: { (record, error) in
                if let e = error
                {
                    print("There's an error with the imagePicker")
                }
            })
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
