//
//  BluetoothManager.swift
//  iBeaconApp
//
//  Created by Elgendy on 18.12.2017.
//  Copyright © 2017 Elgendy. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol KBluetoothManagerDelegate: class {
    func bluetoothState(state: BluetoothState!)
}

enum BluetoothState {
    case On, Off, Unknown
}

class KBluetoothManager: NSObject, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager
    weak var delegate: KBluetoothManagerDelegate?

    override init() {
        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        self.centralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {

        case .poweredOn:
            delegate?.bluetoothState(state: .On)

        case .poweredOff:
            delegate?.bluetoothState(state: .Off)

        default:
            delegate?.bluetoothState(state: .Unknown)
            
        }
        
    }
    
}
