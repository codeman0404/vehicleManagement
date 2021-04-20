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
    
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    //var startDate: Date!
    var distanceTraveledThisTrip: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func startLocationTrackingButton(_ sender: Any) {
        startLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        if lastLocation != nil {
        
            if let location = locations.last {
                
                distanceTraveledThisTrip += ((lastLocation.distance(from: location))/1000.0);
                distanceTraveledLabel.text = String(format: "Distance Traveled: %.3f km", distanceTraveledThisTrip)
                
            }
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
        locationManager.startUpdatingLocation()
        
    }
    
    func stopLocationManager(){
        locationManager.stopUpdatingLocation()
    }


}

