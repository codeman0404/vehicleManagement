//
//  ViewController.swift
//  vehicleManagement
//
//  Created by Cody Anderson and Lucas Duff on 4/18/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    
    @IBOutlet weak var startTrackingButton: UIButton!
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    //var startDate: Date!
    var distanceTraveledThisTrip: Double = 0
    var numMeasurements = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func startLocationTrackingButton(_ sender: Any) {
        startLocationManager()
        startTrackingButton.isEnabled = false
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        // skip the first few measurements to avoid getting bad data
        if (lastLocation != nil) && (numMeasurements > 2) {
        
            if let location = locations.last {
                
                let distanceMoved = ((lastLocation.distance(from: location))/1000.0)
                if (distanceMoved > 15){
                    distanceTraveledThisTrip += distanceMoved
                    distanceTraveledLabel.text = String(format: "Distance Traveled: %.3f km", distanceTraveledThisTrip)
                }
                
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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // i only need updates for distance changes of more than 25 meters
        locationManager.distanceFilter = 25
        locationManager.startUpdatingLocation()
        
    }
    
    func stopLocationManager(){
        locationManager.stopUpdatingLocation()
    }


}

