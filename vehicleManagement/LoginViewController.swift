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
    
    @IBOutlet weak var vehicleUsedTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    @IBAction func login(_ sender: Any) {
        
        if let userName = self.userNameTextField.text {
            
            if let password = self.passwordTextField.text {
                
                if let vehicle = self.vehicleUsedTextField.text {
                    
                    database.child("accounts").child(String(userName)).getData{ (error, snapshot) in
                    
                        
                        if let error = error {
                            
                            print("Error getting data \(error)")
                            
                        } else if snapshot.exists() {
                            
                            DispatchQueue.main.async {
                                print("Got data \(snapshot.value!)")
                                
                                let value = snapshot.value as? NSDictionary
                                let returnedPassword = value?["password"] as? String ?? ""
                            
                            
                                // hash password and compare it agianst the password stored in firebase
                                let passwordData = Data(password.utf8)
                                let hashed = SHA256.hash(data: passwordData)
                                let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
                                
                                
                                
                                if (hashString == returnedPassword) && (vehicle == "vehicle"){
                                    
                                    self.performSegue(withIdentifier: "distanceViewController", sender: self)
                                    
                                } else {
                                    
                                    print("error logging in")
                                }
                            }
                        } else {
                            
                            print("username did not exist")
                            
                        }
                    }
                    
                } else {
                    print("error logging in")
                }
                
            } else {
                
                print("error logging in")
            }
            
        } else {
            print("error loggin  in")
        }
        
        
/*        database.child("accounts").child(String(1)).getData{ (error, snapshot) in
            
                if let error = error {
                    print("Error getting data \(error)")
                }
                else if snapshot.exists() {
                    
                    print("Got data \(snapshot.value!)")
                    
                    let value = snapshot.value as? NSDictionary
                    let returnedUsername = value?["username"] as? String ?? ""
                    let returnedPassword = value?["password"] as? String ?? ""
            
                    DispatchQueue.main.async {
                        
                        if let userName = self.userNameTextField.text {
                            
                            if let password = self.passwordTextField.text {
                                
                                if let vehicle = self.vehicleUsedTextField.text {
                                    
                                    // hash password and compare it agianst the password stored in firebase
                                    let passwordData = Data(password.utf8)
                                    let hashed = SHA256.hash(data: passwordData)
                                    let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
                                    
                                    if (hashString == returnedPassword) && (userName == returnedUsername && (vehicle == "vehicle")){
                                        
                                        self.performSegue(withIdentifier: "distanceViewController", sender: self)
                                        
                                    } else {
                                        
                                        print("error logging in")
                                    }
                                    
                                } else {
                                    print("error logging in")
                                }
                                
                            } else {
                                
                                print("error logging in")
                            }
                            
                        } else {
                            print("error loggin  in")
                        }
                    }
            
                }
        }*/
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
        vehicleUsedTextField.delegate = self
    }

}

