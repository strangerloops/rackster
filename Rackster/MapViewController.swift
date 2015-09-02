//
//  MapViewController.swift
//  Rackster
//
//  Created by Michael Hassin on 4/28/15.
//  Copyright (c) 2015 strangerware. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {

    var mapView: MKMapView!
    var coordinates: [CLLocation]!
    var userLocation: CLLocation?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization")){
            locationManager.requestWhenInUseAuthorization()
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if CLLocationManager.locationServicesEnabled() {
                mapView = MKMapView(frame: self.view.frame)
                mapView.delegate = self
                mapView.showsUserLocation = true
                self.view.addSubview(mapView)
                coordinates = NSKeyedUnarchiver.unarchiveObjectWithFile((UIApplication.sharedApplication().delegate as! AppDelegate).archivePath()) as! [CLLocation]
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        centerViewOnUser()
        addAnnotations()
    }
    
    func centerViewOnUser(){
        if let userLocation = self.userLocation {
            let center = userLocation.coordinate
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let mapRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        let newLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        if self.userLocation == nil || !locationsWithinMileDistance(self.userLocation!, otherLocation: newLocation, distance: 0.1){
            self.userLocation = newLocation
            centerViewOnUser()
            addAnnotations()
        }
    }
    
    func locationsWithinMileDistance(location: CLLocation, otherLocation: CLLocation, distance: Double) -> Bool {
        return miles(location.distanceFromLocation(otherLocation)) < distance
    }
    
    func miles(meters: Double) -> CLLocationDistance {
        return meters * 0.000621371192
    }
    
    func addAnnotations(){
        if let userLocation = userLocation {
            mapView.removeAnnotations(mapView.annotations)
            for coordinate in (coordinates.filter { self.locationsWithinMileDistance($0, otherLocation: userLocation, distance: 0.5) }) {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate.coordinate
                mapView.addAnnotation(annotation)
            }
        }
    }
}
