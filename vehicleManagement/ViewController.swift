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
    
    var vehicle = ""
    var vehiclesList = [String]()
    var user = ""
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
        endTripButton.isEnabled = true
        self.database.child("cars").child(vehicle).child("isDriving").setValue(true)
    }
    
    @IBAction func endTrip(_ sender: Any) {
        stopLocationManager()
        endTripButton.isEnabled = false
        startTripButton.isEnabled = true
        self.database.child("cars").child(vehicle).child("isDriving").setValue(false)
        
        
        geocoder.reverseGeocodeLocation(lastLocation, completionHandler: {
            (placemarks, error) in
            
            if error == nil {
                let location = placemarks?[0]
                
                let city = (location?.locality ?? "") as String
                let postalCode = (location?.postalCode ?? "") as String
                let street = (location?.thoroughfare ?? "") as String
                let state = (location?.administrativeArea ?? "") as String
                let houseNumber = (location?.subThoroughfare ?? "") as String
                
                let locationString = houseNumber + " " + street + ", " + city + ", " + state + " " + postalCode
                
                print(locationString)
                
                self.database.child("cars").child(self.vehicle).child("lastKnownAddress").setValue(locationString)
                
                
            }
            
        })
        
        
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            print(location.coordinate)
            
            let coordinate: [String: Any] = [
                    
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
                
                ]
            
            print(coordinate)
            
            self.database.child("cars").child(self.vehicle).child("coordinates").setValue(coordinate)
            
            lastLocation = location
            
        }
            
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is CarSelectorViewController {
            
            let vc = segue.destination as? CarSelectorViewController
            vc?.vehicles = vehiclesList
            vc?.user = user
            
        }
    }
    

}
