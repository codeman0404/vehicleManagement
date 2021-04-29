//
//  CarSelectorViewController.swift
//  vehicleManagement
//
//  Created by Cody Anderson on 4/29/21.
//

import UIKit

class CarSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var cartTable: UITableView!
    var vehicles = [String]()
    var user = ""
    private var vehicleChosen = ""
    
    @IBAction func registerNewVehicle(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toNewCarController", sender: self)
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("vehicle: " + vehicles[indexPath.row] + " was chosen")
        
        vehicleChosen = vehicles[indexPath.row]
        self.performSegue(withIdentifier: "toMainView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = vehicles[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is ViewController {
            
            let vc = segue.destination as? ViewController
            vc?.vehicle = vehicleChosen
            
        } else if segue.destination is newCarControllerView {
            
            let vc = segue.destination as? newCarControllerView
            vc?.vehicles = vehicles
            vc?.userName = user
            
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        cartTable.delegate = self
        cartTable.dataSource = self
    }
    
    
    
    
}
