//
//  ViewController.swift
//  CollegeProfileBuilder
//
//  Created by Wade Sellers on 7/22/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var collegeArray = [College]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myTableView.reloadData()
        getData()
    }
    
    func getData()
    {
        
        let fetchRequest: NSFetchRequest<College> = College.fetchRequest()
        let sort = NSSortDescriptor(key: "orderIndex", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            collegeArray = try context.fetch(fetchRequest)
            
            for college in collegeArray
            {
                print(college.name! + ": " + String(college.orderIndex))
            }
        } catch {
            print("Cannot fetch College")
        }
        
//        do {
//            collegeArray = try context.fetch(College.fetchRequest())
//        }
//        catch {
//            print("Error. Failed to fetch")
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collegeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = collegeArray[(indexPath as NSIndexPath).row].name
        cell.detailTextLabel?.text = collegeArray[(indexPath as NSIndexPath).row].location
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! DetailsViewController
        let indexPath = myTableView.indexPathForSelectedRow!
        nvc.selectedCollege = collegeArray[(indexPath as NSIndexPath).row]
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
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let newCollege = College(context: self.context)

            newCollege.name = alert.textFields?[0].text
            newCollege.location = alert.textFields?[1].text
            newCollege.numberOfStudents = alert.textFields?[2].text
            newCollege.webPage = alert.textFields?[3].text
            newCollege.orderIndex = Int16(self.collegeArray.count)
            
            appDelegate.saveContext()
            self.getData()
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
            let college = collegeArray[indexPath.row]
            context.delete(college)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getData()
        myTableView.reloadData()
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
            collegeArray[i].orderIndex = Int16(i)
        }

        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        self.getData()


        
    }
}

