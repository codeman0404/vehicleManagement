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
    
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var registerNewAccountButton: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
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
                                
                                DispatchQueue.main.async {
                                    
                                    self.notificationLabel.text = "This username is already taken..."
                                    
                                }
                                
                            } else {
                                
                                // hash password
                                let passwordData = Data(password.utf8)
                                let hashed = SHA256.hash(data: passwordData)
                                let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
                                
                                DispatchQueue.main.async {
                                    
                                    let object: [String: Any] = [
                                        "password": hashString,
                                        "phoneNumber": self.phoneNumberTextField.text
                                    
                                    ]
                                    
                                    self.database.child("accounts").child(String(userName)).setValue(object)
                                
                                    
                                    self.performSegue(withIdentifier: "returnToLogin", sender: self)
                                    
                                }
                                
                                
                            }
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            self.notificationLabel.text = "password fields must match"
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @objc func textFieldDidChange(sender: UITextField){
        
        //print("veh name text field changing")
        
        let text = self.userNameTextField.text
        let text2 = self.passwordTextField.text
        let text3 = self.confirmPasswordTextField.text
        let text4 = self.phoneNumberTextField.text
        
        if ((text == "") || (text2 == "") || (text3 == "") || (text4 == "")) {
            registerNewAccountButton.isEnabled = false
        } else {
            registerNewAccountButton.isEnabled = true
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        phoneNumberTextField.delegate = self
        confirmPasswordTextField.delegate = self
        registerNewAccountButton.isEnabled = false
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

