//
//  ViewController.swift
//  vehicleManagement
//
//  Created by Cody Anderson and Lucas Duff on 4/18/21.
//

import FirebaseDatabase
import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate  {
    
    @IBOutlet weak var startTripButton: UIButton!
    
    @IBOutlet weak var endTripButton: UIButton!
    
    
    private let database = Database.database().reference()
    var vehicleName = "";
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var distanceTraveledThisTrip: Double = 0
    var numMeasurements = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(vehicleName)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
    }
    
    
    @IBAction func startTrip(_ sender: Any) {
        startLocationManager()
        startTripButton.isEnabled = false
    }
    
    @IBAction func endTrip(_ sender: Any) {
        stopLocationManager()
        endTripButton.isEnabled = false
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        // skip the first few measurements to avoid getting bad data
        if (lastLocation != nil) && (numMeasurements > 2) {
        
            if let location = locations.last {
                
                
                let coordinate: [String: Any] = [
                        
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude
                    
                    ]
                
                self.database.child("cars").child(String(vehicleName)).setValue(coordinate)
                
                /*let distanceMoved = lastLocation.distance(from: location)
                if (distanceMoved > 15){
                    distanceTraveledThisTrip += distanceMoved/1000.0
                   /* distanceTraveledLabel.text = String(format: "Distance Traveled: %.3f km", distanceTraveledThisTrip)
                    */
 
                */
                }
                
            }
        }
       /*
        
        if (numMeasurements < 3){
            numMeasurements += 1;
        }
        lastLocation = locations.last!
        print(lastLocation.coordinate)
 
        */
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
