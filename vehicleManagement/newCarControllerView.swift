//
//  newCarControllerView.swift
//  vehicleManagement
//
//  Created by Lucas Duff on 4/28/21.
//

import Foundation
import FirebaseDatabase

class newCarControllerView: UIViewController, UITextFieldDelegate {
    private let database = Database.database().reference()
    
    var userName = "Cody"
    
    @IBOutlet weak var newVehicleName: UITextField!
    
    @IBOutlet weak var newOdometer: UITextField!
    @IBOutlet weak var newAuthorizedDriver: UITextField!
    
    @IBOutlet weak var addDriver: UIButton!
    @IBOutlet weak var submitNewVehicle: UIButton!
    
    var newDrivers: [String] = []
    @IBAction func addDriverFuc(_ sender: Any) {
        if let newDriver = self.newAuthorizedDriver.text {
            newDrivers.append(newDriver)
        }
    }
    @IBAction func submitNewVehicleFunc(_ sender: Any) {
        if let newVehicle = self.newVehicleName.text{
            if let newInitOdometer = self.newOdometer.text {
                self.database.child("cars").child(newVehicle).getData{ (error, snapshot) in
                    if let error = error {
                        
                        print("Error getting data \(error)")
                        
                    } else if snapshot.exists() {
                        print("Vehicle already exists")
                    }else{
                        self.database.child("accounts").child(String(self.userName)).child("valid_vehicles").child(newVehicle).setValue(true)
                        for driver in self.newDrivers{
                            self.database.child("accounts").child(driver).child("valid_vehicles").child(newVehicle).setValue(true)
                        }
                        let object: [String: Any] = [
                            "coordinates": [
                                "latitude":0,
                                "longitude":0
                                ],
                            "fuel_level":50,
                            "isDriving":false,
                            "miles_since_clear":0,
                            "odometer":newInitOdometer,
                            "speed":0
                            ]
                        self.database.child("cars").child(newVehicle).setValue(object)
                    }
                    
                }
                        
                // self.database.child("accounts").child(String(userName)).
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newVehicleName.delegate = self
        newOdometer.delegate = self
        newAuthorizedDriver.delegate = self
    }
    
}
