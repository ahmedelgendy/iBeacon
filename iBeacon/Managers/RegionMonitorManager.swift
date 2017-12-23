//
//  RegionMonitorManager.swift
//  iBeaconApp
//
//  Created by Elgendy on 19.12.2017.
//  Copyright © 2017 Elgendy. All rights reserved.
//

import Foundation
import CoreLocation

protocol RegionMonitorDelegate: NSObjectProtocol {
    func onBackgroundLocationAccessDisabled()
    func didStartMonitoring()
    func didStopMonitoring()
    func didEnterRegion(_ region: CLRegion!)
    func didExitRegion(_ region: CLRegion!)
    func didRangeBeacon(beacon: CLBeacon!, region: CLRegion!)
    func onError(_ error: NSError)
}

class RegionMonitor: NSObject {
    
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion?
    var rangedBeacon: CLBeacon! = CLBeacon()
    var pendingMonitorRequest: Bool = false
    
    // We must do it 'weak' for prevent memory leaks
    weak var delegate: RegionMonitorDelegate?
    
    init(delegate: RegionMonitorDelegate) {
        super.init()
        self.delegate = delegate
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
    }
    
    func startMonitoring(beaconRegion: CLBeaconRegion?) {
        
        print("Start monitoring")
        pendingMonitorRequest = true
        self.beaconRegion = beaconRegion
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied, .authorizedWhenInUse:
            delegate?.onBackgroundLocationAccessDisabled()
        case .authorizedAlways:
            locationManager.startMonitoring(for: beaconRegion!)
            pendingMonitorRequest = false
        }
        
    }
    
    func stopMonitoring() {
        print("Stop Monitorig")
        pendingMonitorRequest = false
        locationManager.stopRangingBeacons(in: beaconRegion!)
        locationManager.stopMonitoring(for: beaconRegion!)
        locationManager.stopUpdatingLocation()
        beaconRegion = nil
        delegate?.didStopMonitoring()
    }
    
}

extension RegionMonitor: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("didChangeAuthorizationStatus \(status)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if pendingMonitorRequest {
                locationManager.startMonitoring(for: beaconRegion!)
                pendingMonitorRequest = false
            }
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("didStartMonitoringForRegion \(region.identifier)")
        delegate?.didStartMonitoring()
        locationManager.requestState(for: region)
        
    }
    
    // The location manager calls this delegate method in response to a call to its requestState(for: region) method
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        print("didDetermineState")
        if state == CLRegionState.inside {
            print(" - entered region \(region.identifier)")
            locationManager.startRangingBeacons(in: beaconRegion!)
        } else {
            print(" - exited region \(region.identifier)")
            locationManager.stopRangingBeacons(in: beaconRegion!)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion - \(region.identifier)")
        delegate?.didEnterRegion(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion - \(region.identifier)")
        delegate?.didExitRegion(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
    }
    
}
