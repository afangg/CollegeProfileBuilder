//
//  MapViewController.swift
//  CollegeProfileBuilder
//
//  Created by Wade Sellers on 7/22/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    
    var college = CKRecord(recordType: "College")
    let locationManager = CLLocationManager()
    var annotation = MKPointAnnotation()
    var dataBase: CKDatabase!
    var crestImage = UIImage()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMapView.delegate = self
        createActionSheet()
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if var location = college.object(forKey: "location")
        {
            geocodeLocation(location as! String)
        }
        
        if college.object(forKey: "pinData") != nil{
            crestImage = UIImage(data: college.object(forKey: "pinData") as! Data)!
        }
        else
        {
            crestImage = #imageLiteral(resourceName: "MobileMakersPin")
        }
        annotation = MKPointAnnotation()
    }

    func geocodeLocation(_ location: String) {
        let geocode = CLGeocoder()
        geocode.geocodeAddressString(location, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                print(error!)
            }
            else {
                for place in placemarks!{
                    self.annotation.coordinate = place.location!.coordinate
                    
                    self.annotation.title = self.college.recordID.recordName
                    
                    self.myMapView.addAnnotation(self.annotation)
                }
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView!.canShowCallout = true
        pinView!.image = crestImage
        let detailButton = UIButton(type: .detailDisclosure) as UIView
        pinView!.rightCalloutAccessoryView = detailButton
       
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let mySpan = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let myRegion = MKCoordinateRegion(center: annotation.coordinate , span: mySpan)
        mapView.setRegion(myRegion, animated: true)
    }
    
    func createActionSheet() {
        let actionSheet = UIAlertController(title: "See User Location?", message: nil, preferredStyle: .actionSheet)
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 100)
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
            self.myMapView.showsUserLocation = true
        }
        actionSheet.addAction(yesAction)
        let noAction = UIAlertAction(title: "NO", style: .default, handler: nil)
        actionSheet.addAction(noAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! PickerViewController
        nvc.selectedCollege = college
        nvc.dataBase = dataBase
    }
}
