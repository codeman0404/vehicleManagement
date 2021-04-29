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
    
    @IBOutlet weak var newVehicleName: UITextField!
    
    @IBOutlet weak var newOdometer: UITextField!
    @IBOutlet weak var newAuthorizedDriver: UITextField!
    
    @IBOutlet weak var addDriver: UIButton!
    @IBOutlet weak var submitNewVehicle: UIButton!
    
    var newDrivers: [String] = []
    @IBAction func addDriverFuc(_ sender: Any) {
        newDrivers.append(
    }
    
}
