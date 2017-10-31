//
//  MapViewController.swift
//  CollegeProfileBuilder
//
//  Created by Wade Sellers on 7/22/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    var imagePicker = UIImagePickerController()
    var crestImage = UIImage()

    var college: College!
    let locationManager = CLLocationManager()
    var annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myMapView.delegate = self
        geocodeLocation(college.location!)
        createActionSheet()
        locationManager.requestWhenInUseAuthorization()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if college.crest != nil{
            crestImage = UIImage(data: college.crest!)!
        }
        else
        {
            crestImage = #imageLiteral(resourceName: "MobileMakersCrest")
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

                    self.annotation.title = self.college.name

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

        if college.crest != nil{
            pinView!.image = UIImage(data: college.crest!)
        }
        else
        {
            pinView!.image = #imageLiteral(resourceName: "MobileMakersCrest")
        }

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
    }
}

