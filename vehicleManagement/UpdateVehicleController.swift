//
//  UpdateVehicleController.swift
//  vehicleManagement
//
//  Created by Cody Anderson on 5/1/21.
//

import UIKit
import Firebase

class UpdateVehicleController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var user = ""
    var vehicle = ""
    var vehicleList = [String]()
    var authorizedUserList = [String]()
    private let database = Database.database().reference()
    
    @IBOutlet weak var milesTilOilChange: UILabel!
    @IBOutlet weak var removeDriverButton: UIButton!
    @IBOutlet weak var addDriverButton: UIButton!
    @IBOutlet weak var authorizedDriversTextField: UITextField!
    @IBOutlet weak var milesToNextOilChangeTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
  
    
    @IBAction func updateOil(_ sender: Any) {
        
        
        if (milesToNextOilChangeTextField.text != ""){
            
            let miles = Int(milesToNextOilChangeTextField.text!)
            
            self.database.child("cars").child(vehicle).child("milesToOil").setValue(miles)
            
            self.milesTilOilChange.text = "Miles Until Next Oil Change: " + milesToNextOilChangeTextField.text!
            
            milesToNextOilChangeTextField.text = ""
            
            
        }
    }
    
    @IBAction func addDriver(_ sender: Any) {
        
        if let newDriver = self.authorizedDriversTextField.text {
            
            self.database.child("accounts").child(newDriver).getData{ (error, snapshot) in
                
                if let error = error {
                    
                    print("Error getting data \(error)")
                
                // if this account exists, add them to the list of new drivers
                } else if snapshot.exists() {
                   
                    DispatchQueue.main.async {
                        
                        if let index = self.authorizedUserList.firstIndex(of: newDriver) {
                            print("person already exists")
                        } else {
                            self.authorizedUserList.append(newDriver)
                            self.tableView.reloadData()
                            
                            // update DB appropriately
                            self.database.child("accounts").child(newDriver).child("valid_vehicles").child(self.vehicle).setValue(true)
                            self.database.child("cars").child(self.vehicle).child("authorized_users").child(newDriver).setValue(true)
                            
                        }
                        
                        
                        self.authorizedDriversTextField.text = ""
                    }
                } else {
                    DispatchQueue.main.async {
                        self.authorizedDriversTextField.text = ""
                    }
                }
            }
        }
        
    }
    
    @IBAction func removeDriver(_ sender: Any) {
        
        if let driver = self.authorizedDriversTextField.text {

                        
            if let index = self.authorizedUserList.firstIndex(of: driver) {
                
                // update database accordingly
                self.database.child("accounts").child(driver).child("valid_vehicles").child(vehicle).removeValue()
                self.database.child("cars").child(self.vehicle).child("authorized_users").child(driver).removeValue()
                
                authorizedUserList.remove(at: index)
                
            }
            
            
                        
            self.tableView.reloadData()
            self.authorizedDriversTextField.text = ""
            
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authorizedUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
        cell.textLabel?.text = authorizedUserList[indexPath.row]
        return cell
    }
   
    @objc func textFieldDidChange(sender: UITextField){
        
        let text = self.authorizedDriversTextField.text
        
        if ((text == "")) {
            addDriverButton.isEnabled = false
            removeDriverButton.isEnabled = false
        } else {
            removeDriverButton.isEnabled = true
            addDriverButton.isEnabled = true
        }
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is ViewController {
            
            let vc = segue.destination as? ViewController
            vc?.user = user
            vc?.vehicle = vehicle
            vc?.vehiclesList = vehicleList
            
            
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        authorizedDriversTextField.delegate = self
        authorizedDriversTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        milesToNextOilChangeTextField.delegate = self
        addDriverButton.isEnabled = false
        removeDriverButton.isEnabled = false
        
        self.database.child("cars").child(vehicle).child("milesToOil").getData{
            (error,snapshot) in
            
            
            let milestTilNextOilChange = String(snapshot.value as! Int)
            DispatchQueue.main.async {
                self.milesTilOilChange.text = "Miles Until Next Oil Change: " + milestTilNextOilChange
            }
        }
        
    }
    
    
}
