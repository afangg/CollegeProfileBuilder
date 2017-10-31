//
//  DetailsViewController.swift
//  CollegeProfileBuilder
//
//  Created by Wade Sellers on 7/22/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
import SafariServices

class DetailsViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collegeImageView: UIImageView!
    @IBOutlet weak var collegeLocationField: UITextField!
    @IBOutlet weak var numberOfStudentsField: UITextField!
    @IBOutlet weak var webPageField: UITextField!

    var selectedCollege: College!
    var imagePicker = UIImagePickerController()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = selectedCollege.name
        collegeLocationField.text = selectedCollege.location
        numberOfStudentsField.text = selectedCollege.numberOfStudents
        
        if selectedCollege.image != nil
        {
            collegeImageView.image = UIImage(data: (selectedCollege.image)!)
        }
        else
        {
            collegeImageView.image = #imageLiteral(resourceName: "college-pennant")
        }
        
        webPageField.text = selectedCollege.webPage

        imagePicker.delegate = self

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedCollege.location = collegeLocationField.text!
        selectedCollege.numberOfStudents = numberOfStudentsField.text!
        selectedCollege.webPage = webPageField.text!
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
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
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.collegeImageView.image = selectedImage
            let imageData = UIImagePNGRepresentation(selectedImage)
            self.selectedCollege.image = imageData
            appDelegate.saveContext()
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! MapViewController
        nvc.college = selectedCollege
    }
}
