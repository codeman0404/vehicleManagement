//
//  LoginViewController.swift
//  vehicleManagement
//
//  Created by Cody Anderson and Lucas Duff on 4/20/21.
//

import UIKit
import FirebaseDatabase
import CryptoKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let database = Database.database().reference()
    private var validVehiclesList = [String]()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    @IBAction func login(_ sender: Any) {
        
        print("trying to log in")
        
        if let userName = self.userNameTextField.text {
            
            if let password = self.passwordTextField.text {
                    
                    database.child("accounts").child(String(userName)).getData{ (error, snapshot) in
                    
                        
                        if let error = error {
                            
                            print("Error getting data \(error)")
                            
                        } else if snapshot.exists() {
                            
                            DispatchQueue.main.async {
                                print("Got data \(snapshot.value!)")
                                
                                let value = snapshot.value as? NSDictionary
                                let returnedPassword = value?["password"] as? String ?? ""
                                let validVehicles = value?["valid_vehicles"] as? NSDictionary
                              
                                
                                // hash password and compare it agianst the password stored in firebase
                                let passwordData = Data(password.utf8)
                                let hashed = SHA256.hash(data: passwordData)
                                let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
                                    
                                    
                                    
                                if (hashString == returnedPassword){
                                       
                                    
                                    if let keys = validVehicles?.allKeys{
                                        for key in keys {
                                            
                                            let carAllowed = validVehicles![key]
                                            
                                            if ((carAllowed as! Bool) == true) {
                                                
                                                self.validVehiclesList.append(key as! String)
                                                
                                            }
                                            
                                         }
                                    }
                                    
                                    self.performSegue(withIdentifier: "toCarSelector", sender: self)
                                        
                                    } else {
                                        
                                    self.notificationLabel.text = "incorrect username or password"
                                    }
                            }
                        } else {
                            
                            DispatchQueue.main.async {
                                self.notificationLabel.text = "incorrect username or password"
                            }
                            
                        }
                    }
                
            } else {
                
                print("error logging in")
            }
            
        } else {
            print("error loggin  in")
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is CarSelectorViewController {
            
            let vc = segue.destination as? CarSelectorViewController
            vc?.vehicles = validVehiclesList
            vc?.user = self.userNameTextField.text!
            
        }
    }
    
    @objc func textFieldDidChange(sender: UITextField){
        
        //print("veh name text field changing")
        
        let text = self.userNameTextField.text
        let text2 = self.passwordTextField.text
        
        if ((text == "") || (text2 == "")) {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
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
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.isEnabled = false
        userNameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        
    }

}

