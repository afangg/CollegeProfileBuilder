//
//  ViewController.swift
//  CollegeProfileBuilder
//
//  Created by Wade Sellers on 7/22/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!

    let dataBase = CKContainer.default().publicCloudDatabase
    var collegeArray = [CKRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.rowHeight = 70
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.28, green:0.11, blue:0.14, alpha:1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        myTableView.backgroundColor = UIColor(red:0.94, green:0.84, blue:0.82, alpha:1.0)
        
        getCollege()
    }

    override func viewWillAppear(_ animated: Bool) {
        getCollege()
    }
    
    func getCollege()
    {
        collegeArray = []
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "College", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        dataBase.perform(query, inZoneWith: nil) { (records, error) in
            if let r = records
            {
                self.collegeArray = records!
                
                DispatchQueue.main.async
                {
                    self.myTableView.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collegeArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
        
        if indexPath.row % 2 == 1
        {
            cell.textLabel?.textColor = UIColor(red:0.94, green:0.84, blue:0.82, alpha:1.0)
            cell.detailTextLabel?.textColor = UIColor(red:0.94, green:0.84, blue:0.82, alpha:1.0)
            cell.backgroundColor = UIColor(red:0.28, green:0.11, blue:0.14, alpha:1.0)
        }
        else
        {
            cell.textLabel?.textColor = UIColor(red:0.28, green:0.11, blue:0.14, alpha:1.0)
            cell.detailTextLabel?.textColor = UIColor(red:0.28, green:0.11, blue:0.14, alpha:1.0)
            cell.backgroundColor = UIColor(red:0.94, green:0.84, blue:0.82, alpha:1.0)
        }
        
        cell.textLabel?.text = collegeArray[(indexPath as NSIndexPath).row].recordID.recordName
        cell.detailTextLabel?.text = collegeArray[(indexPath as NSIndexPath).row].object(forKey: "location") as! String
        if let data = collegeArray[(indexPath as NSIndexPath).row].object(forKey: "imageData")
        {
            cell.imageView?.image = UIImage(data: data as! Data)
        }
        return cell

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! DetailsViewController
        let indexPath = myTableView.indexPathForSelectedRow!
        nvc.selectedCollege = collegeArray[(indexPath as NSIndexPath).row]
        nvc.dataBase = dataBase
    }

    @IBAction func onAddButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New College", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add College Name Here"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add College Location Here"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add Number of Students Here"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add Webpage URL Here"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action) in
            
            let nameTextField = alert.textFields?[0].text
            let locationTextField = alert.textFields?[1].text
            let numberOfStudentsTextField = alert.textFields?[2].text
            let webPageTextField = alert.textFields?[3].text
            
            let recordID = CKRecordID(recordName: nameTextField!)
            let collegeRecord = CKRecord(recordType: "College", recordID: recordID)
            collegeRecord.setObject(locationTextField as! CKRecordValue, forKey: "location")
            collegeRecord.setObject(numberOfStudentsTextField as! CKRecordValue, forKey: "numberOfStudents")
            collegeRecord.setObject(webPageTextField as! CKRecordValue, forKey: "webpage")
            collegeRecord.setObject(self.collegeArray.count as! CKRecordValue, forKey: "index")
            
            self.dataBase.save(collegeRecord, completionHandler: { (record, error) in
                if let e = error {
                    print("Error saving image")
                }
            })
            self.collegeArray.append(collegeRecord)
            self.myTableView.reloadData()
        }
        
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func onEditButtonPressed(_ sender: UIBarButtonItem) {
        if sender.tag == 0 {
            myTableView.isEditing = true
            sender.tag = 1
        }
        else {
            myTableView.isEditing = false
            sender.tag = 0
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let college = collegeArray[(indexPath as NSIndexPath).row]
            collegeArray.remove(at: (indexPath as NSIndexPath).row)
            let collegeID = college.recordID
            dataBase.delete(withRecordID: collegeID) { (recordID, error) in
                if let e = error
                {
                    print("Error deleting")
                }
            }
            
            myTableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let college = collegeArray[(sourceIndexPath as NSIndexPath).row]
        collegeArray.remove(at: (sourceIndexPath as NSIndexPath).row)
        collegeArray.insert(college, at: (destinationIndexPath as NSIndexPath).row)
        
        for var i in 0...collegeArray.count - 1
        {
            collegeArray[i].setObject(i as! CKRecordValue, forKey: "index")
        }
        
        for record in collegeArray
        {
            dataBase.save(record, completionHandler: { (record, error) in
                if let e = error
                {
                    print("Error sorting")
                }
            })
        }
        myTableView.reloadData()
    }
}

