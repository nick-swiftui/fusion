//
//  BluetoothCentral.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 4/24/23.
//

import SwiftUI
import CoreBluetooth
import os

class BluetoothCentral: NSObject, ObservableObject
{
    @Published var text: String!
    {
        didSet
        {
            if self.text == ""
            {
                return
            }
            
            for peri in connectedPeripherals
            {
                for tc in transferCharacteristics
                {
                    peri.key.writeValue(self.text.data(using: .utf8)!, for: tc, type: .withoutResponse)
                }
            }
        }
    }

    var centralManager: CBCentralManager!

    @Published var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
        
    var data = Data()
    
    var serviceUUID: CBUUID!
    
    @Published var connectedPeripherals: [CBPeripheral : String] = [:]
    {
        didSet
        {
            print("didSet activated")
            if connectedPeripherals.isEmpty && !scanningToggleIsOn
            {
                isHosting = false
            }
            else
            {
                isHosting = true
            }
            
            if !oldValue.isEmpty
            {
                var tempArray: [String] = []
                
                for periName in connectedPeripherals.values
                {
                    tempArray.append(periName)
                }
                
                for peri in oldValue.keys
                {
                    sendPeers(to: peri, peers: tempArray)
                }
                
                tempArray = []
            }
        }
    }
    @Published var transferCharacteristics: [CBCharacteristic] = []
    
    @Published var scanningToggleEnabled: Bool!
    @Published var scanningToggleIsOn: Bool!
    {
        didSet
        {
            if connectedPeripherals.isEmpty && !scanningToggleIsOn
            {
                isHosting = false
            }
            else
            {
                isHosting = true
            }
        }
    }
    
    @Published var showingAlert = false
    
    @Published var discoveredPeripheralName = ""
    
    @Published var peripheralCheckInLine: [CBPeripheral] = []
    
    @Published var permissions: [String]!
    
    @Published var periPermissions: [String]?
    @Published var periPermissionsUpdated: Bool = false
    
    @Published var isHosting: Bool = false
    
    @Published var textUpdated: Bool = false
    
    @Published var songsQueueIdArray: [String] = []
    @Published var queueNext = false
    @Published var queueLast = false
    //@Published var queueOrder = false
    
    @Published var songsQueueIdArrayForcedUpdated = false
    @Published var songsQueueIdArrayUpdatedByPeer = false
    
    @Published var queueImported: Bool = false
    @Published var queueImportedCount: Int = 0
    @Published var queueImportedArray: [String] = []
    
    @Published var currentCheckedInPeri: CBPeripheral?
    
    @Published var showingConnectingAlert: Bool = false
    @Published var discoveredPeripheralNameCheckedIn: String = ""
    
    @Published var readyToSendNextBatch = false
    {
        didSet
        {
            if readyToSendNextBatch == true
            {
                readyToSendNextBatch = false
                updateQueue()
            }
        }
    }
    @Published var updateQueueIDs: [String] = []
    @Published var updateQueueCount: Int = 0
        
    override init()
    {
        super.init()
        
        if let data = UserDefaults.standard.data(forKey: "User.hostID"), let pData = UserDefaults.standard.data(forKey: "User.permissions")
        {
            print("!   Passed 1 if let   !")
            if let decoded = try? JSONDecoder().decode(UUID.self, from: data), let pDecoded = try? JSONDecoder().decode([String].self, from: pData)
            {
                serviceUUID = CBUUID(nsuuid: decoded)
                
                centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
                
                scanningToggleEnabled = false
                scanningToggleIsOn = false
                
                permissions = pDecoded
                
                print("BluetoothCentral init UD")
                return
            }
        }
        
        serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        scanningToggleEnabled = false
        scanningToggleIsOn = false
        
        permissions = []
        
        print("BluetoothCentral init")
    }
    
    deinit
    {
        // Don't keep it going while we're not showing.
        centralManager.stopScan()
        os_log("Scanning stopped")

        data.removeAll(keepingCapacity: false)
        
        print("BluetoothCentral deinit")
    }
    
    // MARK: - Toggle Methods
    
    func toggleChanged()
    {
        if scanningToggleIsOn
        {
            retrievePeripheral()
        }
        else
        {
            centralManager.stopScan()
        }
    }
    
    // MARK: - Helper Methods

    /*
     * We will first check if we are already connected to our counterpart
     * Otherwise, scan for peripherals - specifically for our service's 128bit CBUUID
     */
    private func retrievePeripheral()
    {
        if scanningToggleIsOn
        {
            centralManager.scanForPeripherals(withServices: [serviceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    /*
     *  Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    private func cleanup()
    {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = discoveredPeripheral,
            case .connected = discoveredPeripheral.state else { return }
        
        for service in (discoveredPeripheral.services ?? [] as [CBService])
        {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic])
            {
                if characteristic.uuid == TransferService.characteristicUUID && characteristic.isNotifying
                {
                    // It is notifying, so unsubscribe
                    self.discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
    
    func disconnect(peripheral: CBPeripheral)
    {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
//    func sendPermissions(to peer: String)
//    {
//        var textArray: [String] = []
//        var permissionsString = "/"
//
//        for peri in connectedPeripherals.keys
//        {
//            if connectedPeripherals[peri] == peer
//            {
//                for tc in transferCharacteristics
//                {
//                    for permission in permissions
//                    {
//                        permissionsString.append("\(permission),")
//                    }
//
//                    if permissionsString.last == ","
//                    {
//                        permissionsString.removeLast()
//                    }
//                    textArray.append(permissionsString)
//                    let data = try! JSONEncoder().encode(textArray)
//                    peri.writeValue(data, for: tc, type: .withoutResponse)
//
//                    textArray = []
//                    permissionsString = "/"
//                }
//            }
//
//            break
//        }
//    }
    
    func sendPermissions(to peri: CBPeripheral)
    {
        var textArray: [String] = []
        var permissionsString = "/"
        
        for tc in transferCharacteristics
        {
            if tc.service?.peripheral?.identifier != peri.identifier
            {
                continue
            }
            
            for permission in permissions
            {
                permissionsString.append("\(permission),")
            }
            
            if permissionsString.last == ","
            {
                permissionsString.removeLast()
            }
            textArray.append(permissionsString)
            let data = try! JSONEncoder().encode(textArray)
            peri.writeValue(data, for: tc, type: .withoutResponse)
            
            textArray = []
            permissionsString = "/"
            
            break
        }
    }
    
//    func sendHistory(to peer: String, with historyIDs: [String], count: Int)
//    {
//        var textArray: [String] = []
//        var historyString: String = "AddHA\(count),"
//
//        for peri in connectedPeripherals.keys
//        {
//            if connectedPeripherals[peri] == peer
//            {
//                for tc in transferCharacteristics
//                {
//                    for songID in historyIDs
//                    {
//                        historyString.append("\(songID),")
//                    }
//
//                    if historyString.last == ","
//                    {
//                        historyString.removeLast()
//                    }
//
//                    textArray.append(historyString)
//                    let data = try! JSONEncoder().encode(textArray)
//                    peri.writeValue(data, for: tc, type: .withoutResponse)
//
//                    textArray = []
//                    historyString = "AddHA\(count),"
//                }
//            }
//
//            break
//        }
//    }
    
    func sendHistory(to peri: CBPeripheral, with historyIDs: [String], count: Int)
    {
        var textArray: [String] = []
        var historyString: String = "AddHA\(count),"
        
        for tc in transferCharacteristics
        {
            if tc.service?.peripheral?.identifier != peri.identifier
            {
                continue
            }
            
            for songID in historyIDs
            {
                historyString.append("\(songID),")
            }
            
            if historyString.last == ","
            {
                historyString.removeLast()
            }
            
            textArray.append(historyString)
            let data = try! JSONEncoder().encode(textArray)
            peri.writeValue(data, for: tc, type: .withoutResponse)
            
            textArray = []
            historyString = "AddHA\(count),"
            
            break
        }
    }
    
//    func sendCurrentSong(to peer: String, with songID: String)
//    {
//        var textArray: [String] = []
//        var songIdString = "AddNP"
//
//        songIdString.append(songID)
//        textArray = [songIdString]
//
//        for peri in connectedPeripherals.keys
//        {
//            if connectedPeripherals[peri] == peer
//            {
//                for tc in transferCharacteristics
//                {
//                    let data = try! JSONEncoder().encode(textArray)
//                    peri.writeValue(data, for: tc, type: .withoutResponse)
//                }
//
//                textArray = []
//                songIdString = "AddNP"
//            }
//
//            break
//        }
//    }
    
    func sendCurrentSong(to peri: CBPeripheral, with songID: String)
    {
        var textArray: [String] = []
        var songIdString = "AddNP"
        
        songIdString.append(songID)
        textArray = [songIdString]
        
        for tc in transferCharacteristics
        {
            if tc.service?.peripheral?.identifier != peri.identifier
            {
                continue
            }
            
            let data = try! JSONEncoder().encode(textArray)
            peri.writeValue(data, for: tc, type: .withoutResponse)
            
            break
        }
        
        textArray = []
        songIdString = "AddNP"
    }
    
//    func sendQueue(to peer: String, queueIDs: [String], count: Int)
//    {
//        var textArray: [String] = []
//        var queueString: String = "AddSQIDA\(count),"
//
//        for peri in connectedPeripherals.keys
//        {
//            if connectedPeripherals[peri] == peer
//            {
//                for tc in transferCharacteristics
//                {
//                    for songID in queueIDs
//                    {
//                        queueString.append("\(songID),")
//                    }
//
//                    if queueString.last == ","
//                    {
//                        queueString.removeLast()
//                    }
//
//                    textArray.append(queueString)
//                    let data = try! JSONEncoder().encode(textArray)
//                    peri.writeValue(data, for: tc, type: .withoutResponse)
//
//                    textArray = []
//                    queueString = "AddSQIDA\(count),"
//                }
//            }
//
//            break
//        }
//    }
    
    func sendQueue(to peri: CBPeripheral, queueIDs: [String], count: Int)
    {
        var textArray: [String] = []
        var queueString: String = "AddSQIDA\(count),"
        
        for tc in transferCharacteristics
        {
            if tc.service?.peripheral?.identifier != peri.identifier
            {
                continue
            }
            
            for songID in queueIDs
            {
                queueString.append("\(songID),")
            }
            
            if queueString.last == ","
            {
                queueString.removeLast()
            }
            
            textArray.append(queueString)
            let data = try! JSONEncoder().encode(textArray)
            peri.writeValue(data, for: tc, type: .withoutResponse)
            
            textArray = []
            queueString = "AddSQIDA\(count),"
            
            break
        }
    }
    
    func updateQueue()
    {
        var textArray: [String] = []
        var queueString: String = "SQID\(updateQueueCount),"
        var i = 0
        
        for _ in updateQueueIDs
        {
            queueString.append("\(updateQueueIDs.remove(at: 0)),")
            i += 1
            
            if updateQueueIDs.isEmpty
            {
                // Maybe set updateQueueIDs to 0
            }
            
            if i == 40
            {
                break
            }
        }
        
        if queueString.last == ","
        {
            queueString.removeLast()
        }
        
        textArray.append(queueString)
        let data = try! JSONEncoder().encode(textArray)
        
        for peri in connectedPeripherals.keys
        {
            for tc in transferCharacteristics
            {
                if tc.service?.peripheral?.identifier != peri.identifier
                {
                    continue
                }
                
                peri.writeValue(data, for: tc, type: .withoutResponse)
                
                break
            }
        }
        
        if !updateQueueIDs.isEmpty
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.readyToSendNextBatch = true
            }
        }
        
        textArray = []
        queueString = "SQID\(updateQueueCount),"
    }
    
    func sendPeers(to peri: CBPeripheral, peers: [String])
    {
        var textArray: [String] = []
        var peersString: String = "AddPeers,"
        
        for tc in transferCharacteristics
        {
            if tc.service?.peripheral?.identifier != peri.identifier
            {
                continue
            }
            
            for peer in peers
            {
                peersString.append("\(peer),")
            }
            
            if peersString.last == ","
            {
                peersString.removeLast()
            }
            
            textArray.append(peersString)
            let data = try! JSONEncoder().encode(textArray)
            peri.writeValue(data, for: tc, type: .withoutResponse)
            
            textArray = []
            peersString = "AddPeers,"
            
            break
        }
    }
}

extension BluetoothCentral: CBCentralManagerDelegate
{
    // implementations of the CBCentralManagerDelegate methods

    /*
     *  centralManagerDidUpdateState is a required protocol method.
     *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
     *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
     *  the Central is ready to be used.
     */
    internal func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        scanningToggleEnabled = central.state == .poweredOn
        
        switch central.state
        {
        case .poweredOn:
            // ... so start working with the peripheral
            os_log("CBManager is powered on")
            retrievePeripheral()
        case .poweredOff:
            os_log("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            os_log("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            if #available(iOS 13.0, *)
            {
                switch central.authorization
                {
                case .denied:
                    os_log("You are not authorized to use Bluetooth")
                case .restricted:
                    os_log("Bluetooth is restricted")
                default:
                    os_log("Unexpected authorization")
                }
            }
            else
            {
                // Fallback on earlier versions
            }
            return
        case .unknown:
            os_log("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            os_log("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            os_log("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }

    /*
     *  This callback comes whenever a peripheral that is advertising the transfer serviceUUID is discovered.
     *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
     *  we start the connection process
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber)
    {
        
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending on your app’s use case.
        guard RSSI.intValue >= -50
        else
        {
                os_log("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
                return
        }
        
        os_log("Discovered %s at %d", String(describing: peripheral.name), RSSI.intValue)
        
        // Device is in range - have we already seen it?
        var periFound = false
        for peri in connectedPeripherals
        {
            if peri.key != peripheral
            {
                continue
            }
            else
            {
                periFound = true
                break
            }
        }
        if periFound == false
        {
            connectedPeripherals[peripheral] = ""
            
            os_log("Connecting to perhiperal %@", peripheral)
            centralManager.connect(peripheral, options: nil)
        }
    }

    /*
     *  If the connection fails for whatever reason, we need to deal with it.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    {
        os_log("Failed to connect to %@. %s", peripheral, String(describing: error))
        cleanup()
    }
    
    /*
     *  We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        os_log("Peripheral Connected")
        
        // Clear the data that we may already have
        data.removeAll(keepingCapacity: false)
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([serviceUUID])
    }
    
    /*
     *  Once the disconnection happens, we need to clean up our local copy of the peripheral
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        os_log("Perhiperal Disconnected")
        discoveredPeripheral = nil
        
        if let error = error
        {
            print("Peripheral disconnected with error: \(error.localizedDescription)")
        }
        else
        {
            print("Peripheral disconnected without error.")
        }
        
        connectedPeripherals.removeValue(forKey: peripheral)
        
        transferCharacteristics.removeAll
        { char in
            print("tcRa: \(char)")
            print(peripheral.identifier)
            return char.service?.peripheral?.identifier == peripheral.identifier
        }
        print("xxxx\(transferCharacteristics.description)")
//        for tc in transferCharacteristics
//        {
//            if tc.service?.peripheral?.identifier == peripheral.identifier
//            {
//                let i = transferCharacteristics.firstIndex(of: tc)!
//                transferCharacteristics.remove(at: i)
//                break
//            }
//        }
//        print("xxxx\(transferCharacteristics.description)")
    }

}

extension BluetoothCentral: CBPeripheralDelegate
{
    // implementations of the CBPeripheralDelegate methods

    /*
     *  The peripheral letting us know when services have been invalidated.
     */
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService])
    {
        
        for service in invalidatedServices where service.uuid == serviceUUID
        {
            os_log("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([serviceUUID])
        }
    }

    /*
     *  The Transfer Service was discovered
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        if let error = error
        {
            os_log("Error discovering services: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices
        {
            peripheral.discoverCharacteristics([TransferService.characteristicUUID], for: service)
        }
    }
    
    /*
     *  The Transfer characteristic was discovered.
     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        // Deal with errors (if any).
        if let error = error
        {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else { return }
        print("guard let passed!")
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicUUID
        {
            // If it is, subscribe to it
            transferCharacteristic = characteristic
            transferCharacteristics.append(characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        // Once this is complete, we just need to wait for the data to come in.
    }
    
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        print("func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) was executed")
        // Deal with errors (if any)
        if let error = error
        {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard let characteristicData = characteristic.value,
            let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
        os_log("Received %d bytes: %s", characteristicData.count, stringFromData)
        
        // Have we received the end-of-message token?
        if stringFromData == "EOM"
        {
            if String(data: self.data, encoding: .utf8)!.hasPrefix("?")
            {
                var tempValue = String(data: self.data, encoding: .utf8)
                tempValue?.remove(at: (String(data: self.data, encoding: .utf8)?.firstIndex(of: "?"))!)
                connectedPeripherals[peripheral] = tempValue
                discoveredPeripheralName = tempValue!
                
                // This is new, to make peers unique.
                discoveredPeripheral = peripheral
                
                //peripheralCheckInLine.append(peripheral)
                
                self.data = Data()
                //showingAlert = true
                
                if connectedPeripherals.count < 8
                {
                    peripheralCheckInLine.append(peripheral)
                    showingAlert = true
                }
                else
                {
                    disconnect(peripheral: peripheral)
                }
            }
            else if String(data: self.data, encoding: .utf8) == "!"
            {
                self.data = Data()
                disconnect(peripheral: peripheral)
            }
            else if String(data: self.data, encoding: .utf8)!.hasPrefix("/")
            {
                var tempString = String(data: self.data, encoding: .utf8)
                                
                tempString!.remove(at: String(data: self.data, encoding: .utf8)!.firstIndex(of: "/")!)
                
                if tempString!.isEmpty
                {
                    periPermissions = []
                }
                else
                {
                    periPermissions = (tempString!.components(separatedBy: ","))
                    periPermissionsUpdated = true
                }
                self.data = Data()
            }
//            else if String(data: self.data, encoding: .utf8)!.hasPrefix("SQID")
//            {
//                var tempString = String(data: self.data, encoding: .utf8)
//                //var tempArray: [String] = []
//                for _ in 0..<4
//                {
//                    tempString!.removeFirst()
//                }
//
//                if tempString != ""
//                {
//                    songsQueueIdArray = tempString!.components(separatedBy: ",")
//                }
//                else
//                {
//                    songsQueueIdArray = []
//                }
//
//                print(songsQueueIdArray)
//                self.data = Data()
//                //queueOrder = true
//            }
            else if String(data: self.data, encoding: .utf8)!.hasPrefix("SQID")
            {
                var tempString = String(data: self.data, encoding: .utf8)
                //var tempArray: [String] = []
                var tempQueueArray: [String] = []
                for _ in 0..<4
                {
                    tempString!.removeFirst()
                }
                
                if tempString != ""
                {
                    //songsQueueIdArray = tempString!.components(separatedBy: ",")
                    tempQueueArray = (tempString?.components(separatedBy: ","))!
                    
                    queueImportedCount = Int(tempQueueArray.remove(at: 0))!
                    queueImportedArray += tempQueueArray // I see error here.
                    
                    print("queueImportedCount: \(queueImportedCount)")
                    print("queueImportedArray.count: \(queueImportedArray.count)")
                    
                    print("songsQueueIdArray (1): \(songsQueueIdArray)")
                    print("queueImportedArray: \(queueImportedArray)")
                    
                    if queueImportedCount == queueImportedArray.count
                    {
                        queueImported = true
                        songsQueueIdArray = queueImportedArray
                        print("songsQueueIdArray (2): \(songsQueueIdArray)")
                    }
                    else
                    {
                        for tc in transferCharacteristics
                        {
                            let data = try! JSONEncoder().encode(["ReadyFNB"])
                            peripheral.writeValue(data, for: tc, type: .withoutResponse)
                        }
                    }
                }
                else
                {
                    songsQueueIdArray = []
                    queueImported = true
                }
                
                print(songsQueueIdArray)
                self.data = Data()
                //queueOrder = true
            }
            else if String(data: self.data, encoding: .utf8)!.hasPrefix("QNSQID")
            {
                var tempString = String(data: self.data, encoding: .utf8)
                
                for _ in 0..<6
                {
                    tempString!.removeFirst()
                }
                
                songsQueueIdArray.insert(tempString!, at: 0)
                self.data = Data()
                queueNext = true
                
                print("Queue next happened.")
            }
            else if String(data: self.data, encoding: .utf8)!.hasPrefix("QLSQID")
            {
                var tempString = String(data: self.data, encoding: .utf8)
                
                for _ in 0..<6
                {
                    tempString!.removeFirst()
                }
                
                songsQueueIdArray.append(tempString!)
                self.data = Data()
                queueLast = true
            }
            else
            {
                // End-of-message case: show the data.
                // Dispatch the text view update to the main queue for updating the UI, because
                // we don't know which thread this method will be called back on.
                DispatchQueue.main.async()
                {
                    self.text = String(data: self.data, encoding: .utf8)
                    print("text changed in class")
                    print(self.text ?? "text is nil")
                    self.data = Data()
                }
                // This fixed the play/pause issue.
                self.textUpdated = false
            }
        }
        else
        {
            // Otherwise, just append the data to what we have previously received.
            data.append(characteristicData)
        }
    }

    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
    {
        // Deal with errors (if any)
        if let error = error
        {
            os_log("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying
        {
            // Notification has started
            os_log("Notification began on %@", characteristic)
        }
        else
        {
            // Notification has stopped, so disconnect from the peripheral
            os_log("Notification stopped on %@. Disconnecting", characteristic)
            cleanup()
        }
        
    }
    
    /*
     *  This is called when peripheral is ready to accept more data when using write without response
     */
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral)
    {
        os_log("Peripheral is ready, send data")
        //writeData()
    }
    
}
