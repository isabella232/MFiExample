//
//  CoreManager.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 20.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import Dronecode_SDK_Swift
import MFiAdapter
import RxSwift

class CoreManager {
    
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    
//    // Telemetry
//    let telemetry = Telemetry(address: "localhost", port: 50051)
//    // Action
//    let action = Action(address: "localhost", port: 50051)
//    // Mission
//    let mission = Mission(address: "localhost", port: 50051)
//    // Camera
//    let camera = Camera(address: "localhost", port: 50051)
//    // Info
//    let info = Info(address: "localhost", port: 50051)
//    // Calibration
//    let calibration = Calibration(address: "localhost", port: 50051)
    
    
    // Drone state
    let droneState = DroneState()
    
    // Drone
    let drone: Drone
    
    private static var sharedCoreManager: CoreManager = {
        let coreManager = CoreManager()
        
        return coreManager
    }()
    
    
    // Initialization
    
    private init() {
        drone = Drone()
        MFiAdapter.MFiConnectionStateAdapter.sharedInstance().startMonitorConnectionState()
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().startMonitorRCEvent()
    }
    
    deinit {
        MFiAdapter.MFiConnectionStateAdapter.sharedInstance().stopMonitorConnectionState()
    }
    
    // MARK: - Accessors
    
    class func shared() -> CoreManager {
        return sharedCoreManager
    }
    
    public func start() -> Void {
        
        drone.startMavlink
            .subscribe(onCompleted: {
                print("+DC+ Mavlink Started.")
            }, onError: { (error) in
                print("Error starting Mavlink: \(error)")
            })
            .disposed(by: disposeBag)
        
        _ = drone.core.connectionState
            .observeOn(MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { (connectionState) in
               print("Core connected")
            }, onError: { error in
               print("+DC+Failed to connect. Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
    }
}
