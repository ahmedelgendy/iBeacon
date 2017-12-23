//
//  RegionMonitorViewController.swift
//  iBeaconApp
//
//  Created by Elgendy on 18.12.2017.
//  Copyright © 2017 Elgendy. All rights reserved.
//

import UIKit
import CoreLocation

class RegionMonitorViewController: UIViewController {

    @IBOutlet weak var regionIdLabel: UILabel!
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    @IBOutlet weak var monitoringButton: UIButton!
    
    var doneButton: UIBarButtonItem!
    var isMonitoring = false
    let distanceFormatter = LengthFormatter()
    
    @IBAction func gestureTodismissKeyboard(_ sender: Any) {
        dismissKeyboard()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.synchronize()
    }
    
    func initFromDefaultValues() {
        
        let defaults = UserDefaults.standard
        
        if let uuid = defaults.string(forKey: K.UserDefaultsKeys.UUID) {
            uuidTextField.text = uuid
        }
        
        if let major = defaults.string(forKey: K.UserDefaultsKeys.MajorId) {
            majorTextField.text = major
        }
        
        if let minor = defaults.string(forKey: K.UserDefaultsKeys.MinorId) {
            minorTextField.text = minor
        }
    }
}

// Mark: Implementing RegionMonitorDelegate Methods
extension RegionMonitorViewController: RegionMonitorDelegate {
    
    func onBackgroundLocationAccessDisabled() {
        
        let alertController = UIAlertController(title: "Background Location Access Disabled", message: "Please change the location access to 'Always' in app settings.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didStartMonitoring() {
        isMonitoring = true
        monitoringButton.backgroundColor = UIColor.green
    }
    
    func didStopMonitoring() {
        isMonitoring = false
        
    }
    
    func didEnterRegion(_ region: CLRegion!) {
        
    }
    
    func didExitRegion(_ region: CLRegion!) {
        
    }
    
    func didRangeBeacon(beacon: CLBeacon!, region: CLRegion!) {
        regionIdLabel.text = region.identifier
        uuidTextField.text = beacon.proximityUUID.uuidString
        majorTextField.text = "\(beacon.major)"
        minorTextField.text = "\(beacon.minor)"
        switch (beacon.proximity) {
        case .far:
            proximityLabel.text = "Far"
        case .near:
            proximityLabel.text = "Near"
        case .immediate:
            proximityLabel.text = "Immediate"
        case .unknown:
            proximityLabel.text = "unknown"
        }
        distanceLabel.text = distanceFormatter.string(fromMeters: beacon.accuracy)
        
        rssiLabel.text = "\(beacon.rssi)"
    }
    
    func onError(_ error: NSError) {
        
    }
    
}

// MARK: UI Settings

extension RegionMonitorViewController {
    
    func setupUI(){
        setUIDelegates()
        setDoneButton()
    }
    
    func setUIDelegates(){
        uuidTextField.delegate = self
        majorTextField.delegate = self
        minorTextField.delegate = self
    }

    func setDoneButton(){
        doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
    }
    
    @objc func dismissKeyboard(){
        uuidTextField.resignFirstResponder()
        majorTextField.resignFirstResponder()
        minorTextField.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
    
}

// MARK: UITextFieldDelegate methods
extension RegionMonitorViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let defaults = UserDefaults.standard
        if textField == uuidTextField && !textField.text!.isEmpty {
            defaults.set(textField.text, forKey: K.UserDefaultsKeys.UUID)
        }
        if textField == majorTextField && !textField.text!.isEmpty {
            defaults.set(textField.text, forKey: K.UserDefaultsKeys.MajorId)
        }
        if textField == minorTextField && !textField.text!.isEmpty {
            defaults.set(textField.text, forKey: K.UserDefaultsKeys.MinorId)
        }
    }
    
}
