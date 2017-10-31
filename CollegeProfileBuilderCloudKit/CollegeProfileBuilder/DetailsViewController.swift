//
//  DetailsViewController.swift
//  CollegeProfileBuilder
//
//  Created by Wade Sellers on 7/22/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
import SafariServices
import CloudKit

class DetailsViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collegeImageView: UIImageView!
    @IBOutlet weak var collegeLocationField: UITextField!
    @IBOutlet weak var numberOfStudentsField: UITextField!
    @IBOutlet weak var webPageField: UITextField!

    var selectedCollege = CKRecord(recordType: "College")
    var imagePicker = UIImagePickerController()
    var dataBase: CKDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.94, green:0.84, blue:0.82, alpha:1.0)
        navigationItem.title = selectedCollege.recordID.recordName
        collegeLocationField.text = selectedCollege.object(forKey: "location") as! String
        numberOfStudentsField.text = selectedCollege.object(forKey: "numberOfStudents") as! String
        webPageField.text = selectedCollege.object(forKey: "webpage") as! String

        if let data = selectedCollege.object(forKey: "imageData")
        {
            collegeImageView.image = UIImage(data: data as! Data)
        }

        imagePicker.delegate = self

    }

    
    @IBAction func dismissKeyboard(_ sender: Any)
    {
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        selectedCollege.setObject(collegeLocationField.text! as CKRecordValue, forKey: "location")
        selectedCollege.setObject(numberOfStudentsField.text! as CKRecordValue, forKey: "numberOfStudents")
        selectedCollege.setObject(webPageField.text! as CKRecordValue, forKey: "webpage")

        dataBase.save(selectedCollege) { (record, error) in
            if let e = error
            {
                print("Update error")
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    @IBAction func onViewWebpageButtonPressed(_ sender: UIButton) {
        let svc = SFSafariViewController(url: URL(string: "http://\(webPageField.text!)")!)
        present(svc, animated: true, completion: nil)
    }

    @IBAction func onSelectImageButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage = UIImage()
        imagePicker.dismiss(animated: true) {
            selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let imageData = UIImagePNGRepresentation(selectedImage)
            self.selectedCollege.setObject(imageData as! CKRecordValue, forKey: "imageData")
            self.collegeImageView.image = selectedImage
            
            self.dataBase.save(self.selectedCollege, completionHandler: { (record, error) in
                if let e = error
                {
                    "Error in saving image"
                }
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! MapViewController
        nvc.college = selectedCollege
        nvc.dataBase = dataBase
    }
}
