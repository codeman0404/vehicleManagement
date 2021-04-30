//
//  newCarControllerView.swift
//  vehicleManagement
//
//  Created by Lucas Duff on 4/28/21.
//

import Foundation
import FirebaseDatabase

class newCarControllerView: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            cell.textLabel?.text = userNames[indexPath.row]
            return cell
    }
    
    private let database = Database.database().reference()
    var userNames = [String]()
    var userName = ""
    var vehicles = [String]()
    
    @IBOutlet weak var newVehicleName: UITextField!
    
    @IBOutlet weak var milesToOilChangeTextField: UITextField!
    @IBOutlet weak var newOdometer: UITextField!
    @IBOutlet weak var newAuthorizedDriver: UITextField!
    @IBOutlet weak var addDriver: UIButton!
    @IBOutlet weak var submitNewVehicle: UIButton!
    @IBOutlet weak var acceptedNewDrivers: UITableView!
    
    var newDrivers: [String] = []
    @IBAction func addDriverFuc(_ sender: Any) {
        if let newDriver = self.newAuthorizedDriver.text {
            self.database.child("accounts").child(newDriver).getData{ (error, snapshot) in
                if let error = error {
                    
                    print("Error getting data \(error)")
                    
                } else if snapshot.exists() {
                   
                    DispatchQueue.main.async {
                        self.newDrivers.append(newDriver)
                        self.userNames.append(newDriver)
                        self.acceptedNewDrivers.reloadData()
                        self.newAuthorizedDriver.text = ""
                    }
                }
            }
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
                        
                        DispatchQueue.main.async {
                            // keep vehicles up to date
                            self.vehicles.append(newVehicle)
                            
                            self.database.child("accounts").child(String(self.userName)).child("valid_vehicles").child(newVehicle).setValue(true)
                            
                            for driver in self.newDrivers{
                                self.database.child("accounts").child(driver).child("valid_vehicles").child(newVehicle).setValue(true)
                            }
                            //if(newInitOdometer>=0 && newInitOdometer<=1000000){
                                let object: [String: Any] = [
                                    "coordinates": [
                                        "latitude":0,
                                        "longitude":0
                                    ],
                                    "fuel_level":50,
                                    "isDriving":false,
                                    "miles_since_clear":0,
                                    "odometer":newInitOdometer,
                                    "speed":0,
                                    "milesToOil": Int(self.milesToOilChangeTextField.text!),
                                    "owner": self.userName,
                                    "DTC" : ["isEngineLightOn": false]
                                ]
                                self.database.child("cars").child(newVehicle).setValue(object)
                        //}
                        }
                    }
                    
                }
                        
                // self.database.child("accounts").child(String(userName)).
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is CarSelectorViewController {
            
            let vc = segue.destination as? CarSelectorViewController
            vc?.vehicles = vehicles
            vc?.user = userName
            
        }
    }
    
    @objc func textFieldDidChange(sender: UITextField){
        
        //print("veh name text field changing")
        
        let text = self.newVehicleName.text
        let text2 = self.newOdometer.text
        let text3 = self.milesToOilChangeTextField.text
        
        if ((text == "") || ((text2 == "") || (text3 == ""))) {
            submitNewVehicle.isEnabled = false
        } else {
            submitNewVehicle.isEnabled = true
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newVehicleName.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        newOdometer.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        milesToOilChangeTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        milesToOilChangeTextField.delegate = self
        newVehicleName.delegate = self
        newOdometer.delegate = self
        newAuthorizedDriver.delegate = self
        acceptedNewDrivers.delegate = self
        acceptedNewDrivers.dataSource = self
        submitNewVehicle.isEnabled = false
    }
    
}
