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
    @IBOutlet weak var updateVehicleButton: UIButton!
    
    var userAllowedToUpdateVehicle = false
    var vehicle = ""
    var vehiclesList = [String]()
    var user = ""
    var validUsersList = [String]()
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
        
        self.database.child("cars").child(vehicle).child("owner").getData{ (error, snapshot) in
            
            if let error = error {
                
                
                print(error)
                
            } else if snapshot.exists() {
                
                let vehicleOwner = snapshot.value as? String ?? ""
                
                print(vehicleOwner)
                print(self.user)
                
                if (vehicleOwner == self.user){
                    
                    DispatchQueue.main.async {
                        self.updateVehicleButton.isEnabled = true
                        self.userAllowedToUpdateVehicle = true
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.updateVehicleButton.isEnabled = false
                    }
                }
                
                
            } else {
                
                DispatchQueue.main.async {
                    self.updateVehicleButton.isEnabled = false
                }
                
            }
            
        }
        
    }
    
    @IBAction func updateVehicleData(_ sender: Any) {
        
        self.database.child("cars").child(vehicle).child("authorized_users").getData{ (error, snapshot) in
            
            
            if let error = error {
                
                print("Error getting data \(error)")
                
            } else if snapshot.exists() {
               
                DispatchQueue.main.async {
                    let value = snapshot.value as? NSDictionary
                    let users = value!.allKeys as! [String]
                    self.validUsersList = users
                    self.performSegue(withIdentifier: "toUpdateCarController", sender: self)
                }
                
            }
            
        }
        
    }
    
    
    @IBAction func startTrip(_ sender: Any) {
        startLocationManager()
        updateVehicleButton.isEnabled = false
        startTripButton.isEnabled = false
        endTripButton.isEnabled = true
        self.database.child("cars").child(vehicle).child("isDriving").setValue(true)
    }
    
    @IBAction func endTrip(_ sender: Any) {
        
        stopLocationManager()
        endTripButton.isEnabled = false
        startTripButton.isEnabled = true
        
        if (userAllowedToUpdateVehicle == true){
            updateVehicleButton.isEnabled = true
        }
        
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
            
        } else if segue.destination is UpdateVehicleController {
            
            let vc = segue.destination as? UpdateVehicleController
            vc?.user = user
            vc?.authorizedUserList = validUsersList
            vc?.vehicle = vehicle
            vc?.vehicleList = vehiclesList
            
        }
    }
    

}
