//
//  ViewController.swift
//  vehicleManagement
//
//  Created by Cody Anderson and Lucas Duff on 4/18/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate  {
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    
    @IBOutlet weak var startTrackingButton: UIButton!
    
    @IBOutlet weak var startTripButton: UIButton!
    
    var vehicleName = "";
    
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    //var startDate: Date!
    var distanceTraveledThisTrip: Double = 0
    var numMeasurements = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
    }
    
    
    @IBAction func startTrip(_ sender: Any) {
        startLocationManager()
        startTripButton.isEnabled = false
    }
    
    @IBAction func startLocationTrackingButton(_ sender: Any) {
        startLocationManager()
        startTrackingButton.isEnabled = false
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        // skip the first few measurements to avoid getting bad data
        if (lastLocation != nil) && (numMeasurements > 2) {
        
            if let location = locations.last {
                
                let distanceMoved = lastLocation.distance(from: location)
                if (distanceMoved > 15){
                    distanceTraveledThisTrip += distanceMoved/1000.0
                    distanceTraveledLabel.text = String(format: "Distance Traveled: %.3f km", distanceTraveledThisTrip)
                }
                
                // attempt to geocode that coordinate
              /*  geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                    if error == nil {
                        let firstLocation = placemarks?[0]
                        
                        print(firstLocation?.country)
                        print(firstLocation?.locality)
                        print(firstLocation?.administrativeArea)
                        print(firstLocation?.thoroughfare)
                        print(firstLocation?.subThoroughfare)
                        
                    }
                    else {
                     // An error occurred during geocoding.
                        
                    }
                }) */
                
            }
        }
        
        
        if (numMeasurements < 3){
            numMeasurements += 1;
        }
        lastLocation = locations.last!
        print(lastLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       if let error = error as? CLError, error.code == .denied {
          // Location updates are not authorized.
          manager.stopUpdatingLocation()
          print("access was denied... stoping location querying")
          return
       }
    }
    
    func startLocationManager(){
        
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 25
        
    }
    
    func stopLocationManager(){
        locationManager.stopUpdatingLocation()
    }

}
