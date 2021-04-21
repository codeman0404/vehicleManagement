//
//  NewAccountViewController.swift
//  vehicleManagement
//
//  Created by Cody Anderson on 4/21/21.
//

import UIKit
import FirebaseDatabase
import CryptoKit

class NewAccountViewController: UIViewController, UITextFieldDelegate {
    
    private let database = Database.database().reference()
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBAction func registerNewAccount(_ sender: Any) {
        
        if let userName = userNameTextField.text {
            
            if let password = passwordTextField.text {
                
                if let repeatedPassword = confirmPasswordTextField.text {
                    
                    if (repeatedPassword == password){
                        
                        database.child("accounts").child(String(userName)).getData{ (error, snapshot) in
                        
                            
                            if let error = error {
                                
                                print("Error getting data \(error)")
                                
                            } else if snapshot.exists() {
                                
                                print("username already exists...")
                                
                            } else {
                                
                                print("username did not exist")
                                
                                // hash password and compare it agianst the password stored in firebase
                                let passwordData = Data(password.utf8)
                                let hashed = SHA256.hash(data: passwordData)
                                let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
                                
                                let object: [String: Any] = [
                                    
                                    "password": hashString,
                                    "vehicles": [
                                        
                                        "acura": "1",
                                        "scion": "1"
                                    
                                    ]
                                    
                                ]
                                
                                self.database.child("accounts").child(String(userName)).setValue(object)
                                
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}

