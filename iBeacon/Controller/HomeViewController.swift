//
//  ViewController.swift
//  iBeaconApp
//
//  Created by Elgendy on 18.12.2017.
//  Copyright © 2017 Elgendy. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var bluetoothStateLabel: UILabel!
    
    var bluetoothManager = KBluetoothManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bluetoothManager.delegate = self
        
    }

}

// MARK: UI Settings
extension HomeViewController {
    
    func setBluetoothStateLabel(title: String, color: UIColor) {
        bluetoothStateLabel.text = title
        bluetoothStateLabel.textColor = color
    }
    
    private func showAlertWhenBluetoothIsOFF() {
        let alertController = UIAlertController(title: "iBeacon App", message: "Please turn on your Bluetooth", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: Bluetooth Delegate
extension HomeViewController: KBluetoothManagerDelegate {

    func bluetoothState(state: BluetoothState!) {
        
        switch state {
            
        case .On:
            setBluetoothStateLabel(title: "Bluetooth: ON", color: .green)
            
        case .Off:
            setBluetoothStateLabel(title: "Bluetooth: OFF", color: .red)
            showAlertWhenBluetoothIsOFF()
            
        default:
            setBluetoothStateLabel(title: "Bluetooth: Unkown", color: .blue)
            
        }
        
    }
    
}


