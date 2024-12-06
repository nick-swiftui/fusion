//
//  TransferService.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 4/24/23.
//

import Foundation
import CoreBluetooth

struct TransferService
{
    static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    
    // Default UUID from Apple test project.
    //static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    
    // This app's uniquely generated UUID
    static let characteristicUUID = CBUUID(string: "B96DA56F-A197-4EEB-8742-D36C2479A37D")
}
