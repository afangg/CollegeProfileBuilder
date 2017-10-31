//
//  PickerViewController.swift
//  CollegeProfileBuilder
//
//  Created by Alisha Fong on 10/6/17.
//  Copyright © 2017 Alisha Fong. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var selectedCollege: College!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage = UIImage()
        imagePicker.dismiss(animated: true) {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let imageData = UIImagePNGRepresentation(selectedImage)
            self.selectedCollege.crest = imageData
            appDelegate.saveContext()
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
