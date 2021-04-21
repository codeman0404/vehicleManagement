//
//  LoginViewController.swift
//  vehicleManagement
//
//  Created by Cody Anderson and Lucas Duff on 4/20/21.
//

import UIKit
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let database = Database.database().reference()
    
    @IBOutlet weak var vehicleUsedTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    @IBAction func login(_ sender: Any) {
        
        database.child("randomEntry").setValue(10)
        
        if let userName = userNameTextField.text {
            
            if let password = passwordTextField.text {
                
                if let vehicle = vehicleUsedTextField.text {
                    
                    if (password == "password") && (userName == "Cody" && (vehicle == "vehicle")){
                        
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

