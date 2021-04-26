//
//  ViewController.swift
//  vehicleManagement
//
//  Created by Cody Anderson and Lucas Duff on 4/18/21.
//

import UIKit
import MapKit
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate  {
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    
    @IBOutlet weak var startTrackingButton: UIButton!
    
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    //var startDate: Date!
    var distanceTraveledThisTrip: Double = 0
    var numMeasurements = 0
    
    //bluetooth variables
    private var centralManager: CBCentralManager!
    private var piPeripheral: CBPeripheral!
    
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        //centralManager initialization for bluetooth
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func sendBLEMessage(_ sender: Any) {
        
        writeOutgoingValue(data: "hello bob")
    }
    
    @IBAction func startLocationTrackingButton(_ sender: Any) {
        startLocationManager()
        startTrackingButton.isEnabled = false
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        // skip the first few measurements to avoid getting bad data
        if (lastLocation != nil) && (numMeasurements > 2) {
        
            if let location = locations.last {
                
                let distanceMoved = lastLocation.distance(from: location)
                if (distanceMoved > 15){
                    distanceTraveledThisTrip += distanceMoved/1000.0
                    distanceTraveledLabel.text = String(format: "Distance Traveled: %.3f km", distanceTraveledThisTrip)
                }
                
                // attempt to geocode that coordinate
              /*  geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                    if error == nil {
                        let firstLocation = placemarks?[0]
                        
                        print(firstLocation?.country)
                        print(firstLocation?.locality)
                        print(firstLocation?.administrativeArea)
                        print(firstLocation?.thoroughfare)
                        print(firstLocation?.subThoroughfare)
                        
                    }
                    else {
                     // An error occurred during geocoding.
                        
                    }
                }) */
                
            }
        }
        
        
        if (numMeasurements < 3){
            numMeasurements += 1;
        }
        lastLocation = locations.last!
        print(lastLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       if let error = error as? CLError, error.code == .denied {
          // Location updates are not authorized.
          manager.stopUpdatingLocation()
          print("access was denied... stoping location querying")
          return
       }
    }
    
    func startLocationManager(){
        
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 25
        
    }
    
    func stopLocationManager(){
        locationManager.stopUpdatingLocation()
    }


    //Bluetooth
       
    func startScanning() -> Void {
      // Start Scanning
      centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    }

       
       /*
        The implementation of this function performs the following actions:

        Set the piPeripheral variable to the new peripheral found.
        Set the peripheral's delegate to self (ViewController)
        Printed the newly discovered peripheral's information in the console.
        Stopped scanning for peripherals.
        **/
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {

        piPeripheral = peripheral

        piPeripheral.delegate = self

        print("Peripheral Discovered: \(peripheral)")
          print("Peripheral name: \(peripheral.name)")
        print ("Advertisement Data : \(advertisementData)")
            
        centralManager?.stopScan()
        
        centralManager?.connect(piPeripheral!, options: nil)
       }
      
    
    // method that is run when the peripheral is connected to
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
       piPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }
    
    // method runs when the services have been discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("*******************************************************")

            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            guard let services = peripheral.services else {
                return
            }
            //We need to discover the all characteristic
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            print("Discovered Services: \(services)")
        }
    
    // method is called when peripheral characteristics have been disovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           
               guard let characteristics = service.characteristics else {
              return
          }

          print("Found \(characteristics.count) characteristics.")

          for characteristic in characteristics {

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {

              rxCharacteristic = characteristic

              peripheral.setNotifyValue(true, for: rxCharacteristic!)
              peripheral.readValue(for: characteristic)

              print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
              
              txCharacteristic = characteristic
              
              print("TX Characteristic: \(txCharacteristic.uuid)")
            }
          }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
     
          var characteristicASCIIValue = NSString()
     
          guard characteristic == rxCharacteristic,
     
          let characteristicValue = characteristic.value,
          let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }
     
          characteristicASCIIValue = ASCIIstring
     
          print("Value Recieved: \((characteristicASCIIValue as String))")
    }
    
    func writeOutgoingValue(data: String){
          
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        
        if let piPeripheral = piPeripheral {
              
          if let txCharacteristic = txCharacteristic {
                  
            piPeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
              }
          }
      }
    
    // function that allo=ws you to disconnect from the service
    func disconnectFromDevice () {
        if piPeripheral != nil {
        centralManager?.cancelPeripheralConnection(piPeripheral!)
        }
     }

}


extension ViewController: CBPeripheralDelegate {
}

extension ViewController: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
     switch central.state {
          case .poweredOff:
              print("Is Powered Off.")
          case .poweredOn:
              print("Is Powered On.")
              startScanning()
          case .unsupported:
              print("Is Unsupported.")
          case .unauthorized:
          print("Is Unauthorized.")
          case .unknown:
              print("Unknown")
          case .resetting:
              print("Resetting")
          @unknown default:
            print("Error")
          }
  }

}
