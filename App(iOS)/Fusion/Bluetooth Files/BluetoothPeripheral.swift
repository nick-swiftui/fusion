//
//  BluetoothPeripheral.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 4/24/23.
//

import SwiftUI
import CoreBluetooth
import os

import MusicKit

class BluetoothPeripheral: NSObject, ObservableObject
{
    @Published var text: String!
    @Published var advertisingToggleEnabled: Bool!
    @Published var advertisingToggleIsOn: Bool!
    {
        didSet
        {
            if !advertisingToggleIsOn && connectedCentral == nil
            {
                isPeering = false
            }
            else
            {
                isPeering = true
            }
        }
    }
    
    var peripheralManager: CBPeripheralManager!

    var transferCharacteristic: CBMutableCharacteristic?
    var connectedCentral: CBCentral?
    {
        didSet
        {
            if !advertisingToggleIsOn && connectedCentral == nil
            {
                isPeering = false
            }
            else
            {
                isPeering = true
            }
        }
    }
    var dataToSend = Data()
    var sendDataIndex: Int = 0
        
    @Published var serviceUUID: CBUUID!
    
    @Published var showingAlert = false
    
    @Published var permissions: [String] = []
    
    @Published var isPeering: Bool = false
    
    @Published var hostIsPlaying: Bool = false
    
    @Published var textArray: [String] = []
    
    @Published var songsQueueIdArray: [String] = []
    
    @Published var queueNext = false
    //@Published var queueOrder = false
    @Published var queueLast = false
    @Published var queueOrder = false
    
    @Published var isQueueSender = false
    
    @Published var addSongToNowPlaying: Bool = false
    @Published var addSongToHistory: Bool = false
    
    @Published var textArrayUpdatedThisWrite: Bool = false
    
    @Published var currentSongID: String = ""
    @Published var currentSongChanged: Bool = false
    
    @Published var historySongID: String = ""
    @Published var historySongChanged: Bool = false
    
    @Published var clearNowPlaying: Bool = false
    
    @Published var previousSongID: String = ""
    @Published var previousSongChanged: Bool = false
    
    @Published var historyImported: Bool = false
    @Published var historyImportedCount: Int = 0
    @Published var historyImportedArray: [String] = []
    
    @Published var queueImported: Bool = false
    @Published var queueImportedCount: Int = 0
    @Published var queueImportedArray: [String] = []
    
    @Published var queueUpdateImported: Bool = false
    @Published var queueUpdateImportedCount: Int = 0
    @Published var queueUpdateImportedArray: [String] = []
    
    @Published var justConnected: Bool = false
    
    @Published var hadQueueImported: Bool = false
    
    @Published var showingConnectingAlert: Bool = false
    
    @Published var peersArray: [String] = []
    @Published var peersListOpacity: Double = 0.0
    
    @Published var readyToSendNextBatch = false
    
    @Published var showingConnectingAlertBackup = false
    {
        didSet
        {
            if readyToSendNextBatch == true
            {
                readyToSendNextBatch = false
                exportQueue()
            }
        }
    }
    @Published var exportQueueIDs: [String] = []
    @Published var exportQueueCount: Int = 0
    
    override init()
    {
        super.init()
        
        if let data = UserDefaults.standard.data(forKey: "User.searchID")
        {
            if let decoded = try? JSONDecoder().decode(UUID.self, from: data)
            {
                //guard let decodedName = decoded.name else { }
                serviceUUID = CBUUID(nsuuid: decoded)
                
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
                
                text = "Did you get my message?"
                advertisingToggleEnabled = false
                advertisingToggleIsOn = false
                
                print("BluetoothPeripheral init UD")
                return
            }
        }
        
        serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
        
        text = "Did you get my message?"
        advertisingToggleEnabled = false
        advertisingToggleIsOn = false
        
        print("BluetoothPeripheral init")
    }
    
    deinit
    {
        // Don't keep advertising going while we're not showing.
        peripheralManager.stopAdvertising()
        
        print("BluetoothPeripheral deinit")
    }
    
    // MARK: - Toggle Methods

    func toggleChanged()
    {
        // All we advertise is our service's UUID.
        if advertisingToggleIsOn == true
        {
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
            print(serviceUUID!)
        }
        else
        {
            peripheralManager.stopAdvertising()
        }
    }
    
    // MARK: - Helper Methods

    /*
     *  Sends the next amount of data to the connected central
     */
    static var sendingEOM = false
    
    private func sendData()
    {
        
        guard let transferCharacteristic = transferCharacteristic
        else
        {
            return
        }
        
        // First up, check if we're meant to be sending an EOM
        if BluetoothPeripheral.sendingEOM
        {
            // send it
            let didSend = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
            // Did it send?
            if didSend
            {
                // It did, so mark it as sent
                BluetoothPeripheral.sendingEOM = false
                os_log("Sent: EOM")
            }
            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return
        }
        
        // We're not sending an EOM, so we're sending data
        // Is there any left to send?
        if sendDataIndex >= dataToSend.count
        {
            // No data left.  Do nothing
            return
        }
        
        // There's data left, so send until the callback fails, or we're done.
        var didSend = true
        while didSend
        {
            
            // Work out how big it should be
            var amountToSend = dataToSend.count - sendDataIndex
            if let mtu = connectedCentral?.maximumUpdateValueLength
            {
                amountToSend = min(amountToSend, mtu)
            }
            
            // Copy out the data we want
            let chunk = dataToSend.subdata(in: sendDataIndex..<(sendDataIndex + amountToSend))
            
            // Send it
            didSend = peripheralManager.updateValue(chunk, for: transferCharacteristic, onSubscribedCentrals: nil)
            
            // If it didn't work, drop out and wait for the callback
            if !didSend
            {
                return
            }
            
            let stringFromData = String(data: chunk, encoding: .utf8)
            os_log("Sent %d bytes: %s", chunk.count, String(describing: stringFromData))
            
            // It did send, so update our index
            sendDataIndex += amountToSend
            // Was it the last one?
            if sendDataIndex >= dataToSend.count
            {
                // It was - send an EOM
                
                // Set this so if the send fails, we'll send it next time
                BluetoothPeripheral.sendingEOM = true
                
                //Send it
                let eomSent = peripheralManager.updateValue("EOM".data(using: .utf8)!,
                                                             for: transferCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent
                {
                    // It sent; we're all done
                    BluetoothPeripheral.sendingEOM = false
                    os_log("Sent: EOM")
                }
                return
            }
        }
    }

    private func setupPeripheral()
    {
        
        // Build our service.
        
        // Start with the CBMutableCharacteristic.
        let transferCharacteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID,
                                                         properties: [.notify, .writeWithoutResponse],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        
        // Create a service from the characteristic.
        let transferService = CBMutableService(type: serviceUUID, primary: true)
        
        // Add the characteristic to the service.
        transferService.characteristics = [transferCharacteristic]
        
        // And add it to the peripheral manager.
        peripheralManager.add(transferService)
        
        // Save the characteristic for later.
        self.transferCharacteristic = transferCharacteristic

    }
    
    // MARK: - Other Methods
    
    func setupPeri()
    {
        setupPeripheral()
    }
    
    func updateServiceUUID(with id: UUID)
    {
        serviceUUID = CBUUID(nsuuid: id)
    }
    
    func updateText(with message: String)
    {
        self.text = message
        self.dataToSend = self.text.data(using: .utf8)!
        self.sendDataIndex = 0
        self.peripheralManagerIsReady(toUpdateSubscribers: self.peripheralManager)
    }
    
    func exportQueue()
    {
        var queueString: String = "SQID\(exportQueueCount),"
        var i = 0
        
        for _ in exportQueueIDs
        {
            queueString.append("\(exportQueueIDs.remove(at: 0)),")
            i += 1
            
            if exportQueueIDs.isEmpty
            {
                // Maybe set exportQueueCount to 0
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
        
        updateText(with: queueString)
        
        queueString = "SQID\(exportQueueCount),"
        
        print("queue exported")
    }
}

extension BluetoothPeripheral: CBPeripheralManagerDelegate
{
    // implementations of the CBPeripheralManagerDelegate methods

    /*
     *  Required protocol method.  A full app should take care of all the possible states,
     *  but we're just waiting for to know when the CBPeripheralManager is ready
     *
     *  Starting from iOS 13.0, if the state is CBManagerStateUnauthorized, you
     *  are also required to check for the authorization state of the peripheral to ensure that
     *  your app is allowed to use bluetooth
     */
    internal func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        
        advertisingToggleEnabled = peripheral.state == .poweredOn
        
        switch peripheral.state
        {
        case .poweredOn:
            // ... so start working with the peripheral
            os_log("CBManager is powered on")
            setupPeripheral()
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
                switch peripheral.authorization
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
            os_log("A previously unknown peripheral manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }

    /*
     *  Catch when someone subscribes to our characteristic, then start sending them data
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic)
    {
        os_log("Central subscribed to characteristic")
        
        // Turn off advertising
        advertisingToggleIsOn = false
        
        // Get the data
        dataToSend = text.data(using: .utf8)!
        
        // Reset the index
        sendDataIndex = 0
        
        // save central
        connectedCentral = central
        
        // Start sending
        sendData()
    }
    
    /*
     *  Recognize when the central unsubscribes
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        os_log("Central unsubscribed from characteristic")
        connectedCentral = nil
        
        showingAlert = true
        
        permissions = []
        
        showingConnectingAlert = false
        showingConnectingAlertBackup = false
    }
    
    /*
     *  This callback comes in when the PeripheralManager is ready to send the next chunk of data.
     *  This is to ensure that packets will arrive in the order they are sent
     */
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    {
        // Start sending again
        sendData()
    }
    
    /*
     * This callback comes in when the PeripheralManager received write to characteristics
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    {
//        for aRequest in requests
//        {
//            guard let requestValue = aRequest.value,
//                let stringFromData = String(data: requestValue, encoding: .utf8)
//            else
//            {
//                continue
//            }
//
//            os_log("Received write request of %d bytes: %s", requestValue.count, stringFromData)
//            self.text = stringFromData
//        }
        //print(requests.count)
        for aRequest in requests
        {
            //print(aRequest)
            guard let requestValue = aRequest.value
            else
            {
                continue
            }
            
            //print("Look here! -> \(requestValue)")
            
            if let arrayFromData = try? JSONDecoder().decode([String].self, from: requestValue)
            {
                os_log("Received write request of %d bytes: %@", requestValue.count, arrayFromData)
                self.textArray = arrayFromData
                
                self.textArrayUpdatedThisWrite = true
            }
            
            if let stringFromData = String(data: requestValue, encoding: .utf8)
            {
                os_log("Received write request of %d bytes: %s", requestValue.count, stringFromData)
                self.text = stringFromData
            }
            
//            if let songArrayFromData = try? JSONDecoder().decode([Song?].self, from: requestValue)
//            {
//                os_log("Received write request of %d bytes: %@", requestValue.count, songArrayFromData)
//                self.songsArray = songArrayFromData
//                print("Songs here! -> \(self.songsArray)")
//            }
            
//            if let songsArrayFromData = try? JSONDecoder().decode([Song].self, from: requestValue)
//            {
//                os_log("Received write request of %d bytes: %@", requestValue.count, songsArrayFromData)
//                self.songsArray = songsArrayFromData
//                print("Songs here! -> \(self.songsArray)")
//            }
        }
        
//        if self.text.hasPrefix("+")
//        {
//            var tempString = self.text
//            tempString!.remove(at: self.text.firstIndex(of: "+")!)
//
//            if tempString != ""
//            {
//                permissions = (tempString!.components(separatedBy: ","))
//            }
//            else
//            {
//                permissions = []
//            }
//        }
        if self.textArray.first == "+"
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            tempArray.removeFirst()
            
            for _ in 0..<tempArray.count
            {
                if tempArray.first!.hasPrefix("/")
                {
                    tempArray[0].removeFirst()
                    if tempArray[0] != ""
                    {
                        permissions = tempArray[0].components(separatedBy: ",")
                    }
                    else
                    {
                        permissions = []
                    }
                }
                
                tempArray.removeFirst()
            }
            
//            if tempArray.first != ""
//            {
//                permissions = (tempString!.components(separatedBy: ","))
//            }
//            else
//            {
//                permissions = []
//            }
            
            self.textArrayUpdatedThisWrite = false
        }
//        else if self.text.hasPrefix("/")
//        {
//            var tempString = self.text
//            tempString!.remove(at: self.text.firstIndex(of: "/")!)
//
//            if tempString != ""
//            {
//                permissions = (tempString!.components(separatedBy: ","))
//            }
//            else
//            {
//                permissions = []
//            }
//        }
        else if self.textArray.first!.hasPrefix("/")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            tempArray[0].removeFirst()
            
            if tempArray[0] != ""
            {
                permissions = tempArray[0].components(separatedBy: ",")
            }
            else
            {
                permissions = []
            }
            
            self.textArrayUpdatedThisWrite = false
        }
//        else if self.text == "\\"
//        {
//            var permissionsString = ""
//
//            for permission in permissions
//            {
//                if permission != ""
//                {
//                    permissionsString.append("\(permission),")
//                }
//                else
//                {
//                    permissions = []
//                }
//            }
//
//            if permissionsString.last == ","
//            {
//                permissionsString.removeLast()
//            }
//
//            self.text = "/" + permissionsString
//            self.dataToSend = self.text.data(using: .utf8)!
//            self.sendDataIndex = 0
//            self.peripheralManagerIsReady(toUpdateSubscribers: self.peripheralManager)
//
//            permissionsString = ""
//        }
        else if self.textArray.first!.hasPrefix("\\")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var permissionsString = ""
            
            for permission in permissions
            {
                if permission != ""
                {
                    permissionsString.append("\(permission),")
                }
                else
                {
                    permissions = []
                }
            }
            
            if permissionsString.last == ","
            {
                permissionsString.removeLast()
            }
            
            self.text = "/" + permissionsString
            self.dataToSend = self.text.data(using: .utf8)!
            self.sendDataIndex = 0
            self.peripheralManagerIsReady(toUpdateSubscribers: self.peripheralManager)

            permissionsString = ""
            
//            self.textArray = ["/" + permissionsString]
//            let data = try! JSONEncoder().encode(textArray)
//            self.dataToSend = data
//            self.sendDataIndex = 0
//            self.peripheralManagerIsReady(toUpdateSubscribers: self.peripheralManager)
            
            self.textArrayUpdatedThisWrite = false
        }
//        else if self.textArray.first!.hasPrefix("SQID")
//        {
//            if !self.textArrayUpdatedThisWrite
//            {
//                return
//            }
//
//            var tempArray = self.textArray
//            for _ in 0..<4
//            {
//                tempArray[0].removeFirst()
//            }
//
//            if tempArray[0] != ""
//            {
//                songsQueueIdArray = tempArray[0].components(separatedBy: ",")
//            }
//            else
//            {
//                songsQueueIdArray = []
//            }
//
//            print(songsQueueIdArray)
//            queueOrder = true
//
//            if isQueueSender
//            {
//                queueOrder = false
//                isQueueSender = false
//            }
//
//            self.textArrayUpdatedThisWrite = false
//        }
        else if self.textArray.first!.hasPrefix("SQID")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            var tempQueueArray: [String] = []
            
            for _ in 0..<4
            {
                tempArray[0].removeFirst()
            }
            
            if tempArray[0] != ""
            {
                //songsQueueIdArray = tempArray[0].components(separatedBy: ",")
                tempQueueArray = tempArray[0].components(separatedBy: ",")
                
                queueUpdateImportedCount = Int(tempQueueArray.remove(at: 0))!
                queueUpdateImportedArray += tempQueueArray
                print("queueUpdateImportedArray: \(queueUpdateImportedArray)")
                
                if queueUpdateImportedCount == queueUpdateImportedArray.count
                {
                    queueUpdateImported = true
                    print("queueUpdateImported == true")
                    
                    songsQueueIdArray = queueUpdateImportedArray
                }
            }
            else
            {
                songsQueueIdArray = []
                queueUpdateImported = true
            }
            
            print(songsQueueIdArray)
            queueOrder = true
            
            if isQueueSender
            {
                queueOrder = false
                isQueueSender = false
            }
            
            //self.hadQueueImported = true
            
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("QNSQID")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            for _ in 0..<6
            {
                tempArray[0].removeFirst()
            }
            
            songsQueueIdArray.insert(tempArray[0], at: 0)
            queueNext = true
            
            if isQueueSender
            {
                queueNext = false
                isQueueSender = false
            }
            
            self.textArrayUpdatedThisWrite = false
            
            print("Queue next happened. (Peri)")
        }
        else if self.textArray.first!.hasPrefix("QLSQID")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            for _ in 0..<6
            {
                tempArray[0].removeFirst()
            }
            
            songsQueueIdArray.append(tempArray[0])
            queueLast = true
            
            if isQueueSender
            {
                queueLast = false
                isQueueSender = false
            }
            
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("AddSQIDA")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            justConnected = true
            
            var tempArray = self.textArray
            var tempQueueArray: [String] = []
            
            for _ in 0..<8
            {
                tempArray[0].removeFirst()
            }
            
            if tempArray[0] != ""
            {
                tempQueueArray = tempArray[0].components(separatedBy: ",")
                
                queueImportedCount = Int(tempQueueArray.remove(at: 0))!
                queueImportedArray += tempQueueArray
                print("queueImportedArray: \(queueImportedArray)")
                
                if queueImportedCount == queueImportedArray.count
                {
                    queueImported = true
                    print("queueImported == true")
                    
                    // This fixes skip problem when connecting new peer
                    songsQueueIdArray = queueImportedArray
                }
                
                if queueImportedCount == 0
                {
                    justConnected = false
                }
                
                if historyImportedArray.isEmpty
                {
                    showingConnectingAlertBackup = false
                }
            }
            
            self.peersListOpacity = 1.0
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("AddNP")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            for _ in 0..<5
            {
                tempArray[0].removeFirst()
            }
            
            if tempArray[0] != ""
            {
                currentSongID = tempArray[0]
            }
            else
            {
                currentSongID = ""
            }
            
            currentSongChanged = true
            
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("AddHA")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            var tempHistoryArray: [String] = []
            
            for _ in 0..<5
            {
                tempArray[0].removeFirst()
            }
            
            if tempArray[0] != ""
            {
                tempHistoryArray = tempArray[0].components(separatedBy: ",")
                
                historyImportedCount = Int(tempHistoryArray.remove(at: 0))!
                historyImportedArray += tempHistoryArray
                print("historyImportedArray: \(historyImportedArray)")
                
                if historyImportedCount == historyImportedArray.count
                {
                    historyImported = true
                    print("historyImported == true")
                }
            }
            
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("AddPeers,")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            var tempPeersArray: [String] = []
            
            for _ in 0..<9
            {
                tempArray[0].removeFirst()
            }
            
            if tempArray[0] != ""
            {
                tempPeersArray = tempArray[0].components(separatedBy: ",")
                peersArray = tempPeersArray
            }
            else
            {
                peersArray = []
            }
            
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("AddH")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            for _ in 0..<4
            {
                tempArray[0].removeFirst()
            }
            
            if tempArray[0] != ""
            {
                historySongID = tempArray[0]
            }
            else
            {
                historySongID = ""
            }
            
            historySongChanged = true
            
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("ClearNP")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            clearNowPlaying = true
            
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("AddPS")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            var tempArray = self.textArray
            for _ in 0..<5
            {
                tempArray[0].removeFirst()
            }
            
            if tempArray[0] != ""
            {
                previousSongID = tempArray[0]
            }
            else
            {
                previousSongID = ""
            }
            
            previousSongChanged = true
            
            //queueOrder = true
            
            self.textArrayUpdatedThisWrite = false
        }
        else if self.textArray.first!.hasPrefix("ReadyFNB")
        {
            if !self.textArrayUpdatedThisWrite
            {
                return
            }
            
            self.readyToSendNextBatch = true
            
            self.textArrayUpdatedThisWrite = false
        }
    }
}
