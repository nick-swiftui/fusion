//
//  PeriPermissionsView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/8/23.
//

import SwiftUI
import CoreBluetooth

struct PeriPermissionsView: View
{
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    let peri: CBPeripheral
    
    @State private var permissionToPlayAndPause = false
    @State private var permissionToSkip = false
    @State private var permissionToRewind = false
//    @State private var permissionToChangeVolume = false
//    @State private var permissionToAdjustPlayback = false
//    @State private var permissionToChangeOutput = false
    @State private var permissionToAddSongNext = false
    @State private var permissionToAddSongLater = false
    @State private var permissionToChangeSongOrder = false
        
    var body: some View
    {
        VStack
        {
            Text("Set permissions here")
            
            Spacer()
            
            HStack
            {
                VStack(alignment: .leading)
                {
                    HStack
                    {
                        Text("Play & Pause     ")
                        Toggle("", isOn: $permissionToPlayAndPause)
                            .labelsHidden()
                            .onChange(of: permissionToPlayAndPause)
                            { newValue in
                                if newValue == true
                                {
                                    if !bluetoothCentral.periPermissions!.contains("P")
                                    {
                                        bluetoothCentral.periPermissions!.append("P")
                                        updatePermissions()
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.periPermissions!.contains("P")
                                    {
                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "P")
                                        bluetoothCentral.periPermissions!.remove(at: pos!)
                                        updatePermissions()
                                    }
                                }
                            }
                    }
                    HStack
                    {
                        Text("Skip\t\t        ")
                        Toggle("", isOn: $permissionToSkip)
                            .labelsHidden()
                            .onChange(of: permissionToSkip)
                            { newValue in
                                if newValue == true
                                {
                                    if !bluetoothCentral.periPermissions!.contains("S")
                                    {
                                        bluetoothCentral.periPermissions!.append("S")
                                        updatePermissions()
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.periPermissions!.contains("S")
                                    {
                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "S")
                                        bluetoothCentral.periPermissions!.remove(at: pos!)
                                        updatePermissions()
                                    }
                                }
                            }
                    }
                    HStack
                    {
                        Text("Rewind\t\t        ")
                        Toggle("", isOn: $permissionToRewind)
                            .labelsHidden()
                            .onChange(of: permissionToRewind)
                            { newValue in
                                if newValue == true
                                {
                                    if !bluetoothCentral.periPermissions!.contains("R")
                                    {
                                        bluetoothCentral.periPermissions!.append("R")
                                        updatePermissions()
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.periPermissions!.contains("R")
                                    {
                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "R")
                                        bluetoothCentral.periPermissions!.remove(at: pos!)
                                        updatePermissions()
                                    }
                                }
                            }
                    }
//                    HStack
//                    {
//                        Text("Change Volume")
//                        Toggle("", isOn: $permissionToChangeVolume)
//                            .labelsHidden()
//                            .onChange(of: permissionToChangeVolume)
//                            { newValue in
//                                if newValue == true
//                                {
//                                    if !bluetoothCentral.periPermissions!.contains("V")
//                                    {
//                                        bluetoothCentral.periPermissions!.append("V")
//                                        updatePermissions()
//                                    }
//                                }
//                                else
//                                {
//                                    if bluetoothCentral.periPermissions!.contains("V")
//                                    {
//                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "V")
//                                        bluetoothCentral.periPermissions!.remove(at: pos!)
//                                        updatePermissions()
//                                    }
//                                }
//                            }
//                    }
//                    HStack
//                    {
//                        Text("Adjust Playback")
//                        Toggle("", isOn: $permissionToAdjustPlayback)
//                            .labelsHidden()
//                            .onChange(of: permissionToAdjustPlayback)
//                            { newValue in
//                                if newValue == true
//                                {
//                                    if !bluetoothCentral.periPermissions!.contains("B")
//                                    {
//                                        bluetoothCentral.periPermissions!.append("B")
//                                        updatePermissions()
//                                    }
//                                }
//                                else
//                                {
//                                    if bluetoothCentral.periPermissions!.contains("B")
//                                    {
//                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "B")
//                                        bluetoothCentral.periPermissions!.remove(at: pos!)
//                                        updatePermissions()
//                                    }
//                                }
//                            }
//                    }
//                    HStack
//                    {
//                        Text("Change Output ")
//                        Toggle("", isOn: $permissionToChangeOutput)
//                            .labelsHidden()
//                            .onChange(of: permissionToChangeOutput)
//                            { newValue in
//                                if newValue == true
//                                {
//                                    if !bluetoothCentral.periPermissions!.contains("O")
//                                    {
//                                        bluetoothCentral.periPermissions!.append("O")
//                                        updatePermissions()
//                                    }
//                                }
//                                else
//                                {
//                                    if bluetoothCentral.periPermissions!.contains("O")
//                                    {
//                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "O")
//                                        bluetoothCentral.periPermissions!.remove(at: pos!)
//                                        updatePermissions()
//                                    }
//                                }
//                            }
//                    }
                    HStack
                    {
                        Text("Queue Next       ")
                        Toggle("", isOn: $permissionToAddSongNext)
                            .labelsHidden()
                            .onChange(of: permissionToAddSongNext)
                            { newValue in
                                if newValue == true
                                {
                                    if !bluetoothCentral.periPermissions!.contains("QN")
                                    {
                                        bluetoothCentral.periPermissions!.append("QN")
                                        updatePermissions()
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.periPermissions!.contains("QN")
                                    {
                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "QN")
                                        bluetoothCentral.periPermissions!.remove(at: pos!)
                                        updatePermissions()
                                    }
                                }
                            }
                    }
                    HStack
                    {
                        Text("Queue Last        ")
                        Toggle("", isOn: $permissionToAddSongLater)
                            .labelsHidden()
                            .onChange(of: permissionToAddSongLater)
                            { newValue in
                                if newValue == true
                                {
                                    if !bluetoothCentral.periPermissions!.contains("QL")
                                    {
                                        bluetoothCentral.periPermissions!.append("QL")
                                        updatePermissions()
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.periPermissions!.contains("QL")
                                    {
                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "QL")
                                        bluetoothCentral.periPermissions!.remove(at: pos!)
                                        updatePermissions()
                                    }
                                }
                            }
                    }
                    HStack
                    {
                        Text("Queue Order     ")
                        Toggle("", isOn: $permissionToChangeSongOrder)
                            .labelsHidden()
                            .onChange(of: permissionToChangeSongOrder)
                            { newValue in
                                if newValue == true
                                {
                                    if !bluetoothCentral.periPermissions!.contains("QO")
                                    {
                                        bluetoothCentral.periPermissions!.append("QO")
                                        updatePermissions()
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.periPermissions!.contains("QO")
                                    {
                                        let pos = bluetoothCentral.periPermissions!.firstIndex(of: "QO")
                                        bluetoothCentral.periPermissions!.remove(at: pos!)
                                        updatePermissions()
                                    }
                                }
                            }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            Button(action: clearPermissions)
            {
                Text("Clear Permissions")
            }
            .padding()
            
            Spacer()
        }
        .onAppear
        {
            // Loading view
            
            var textArray: [String] = ["\\"]
            for tc in bluetoothCentral.transferCharacteristics
            {
                let data = try! JSONEncoder().encode(textArray)
                peri.writeValue(data, for: tc, type: .withoutResponse)
                
                textArray = ["\\"]
            }
        }
        .onChange(of: bluetoothCentral.periPermissionsUpdated)
        { _ in
            guard let periPermissions = bluetoothCentral.periPermissions else { return }
            
            if bluetoothCentral.periPermissionsUpdated == false
            {
                return
            }
            
            for permission in periPermissions
            {
                switch permission
                {
                case "P":
                    permissionToPlayAndPause = true
                    print("P did it")
                case "S":
                    permissionToSkip = true
                case "R":
                    permissionToRewind = true
//                case "V":
//                    permissionToChangeVolume = true
//                case "B":
//                    permissionToAdjustPlayback = true
//                case "O":
//                    permissionToChangeOutput = true
                case "QN":
                    permissionToAddSongNext = true
                case "QL":
                    permissionToAddSongLater = true
                case "QO":
                    permissionToChangeSongOrder = true
                default:
                    // Should never happen
                    continue
                }
            }
            
            bluetoothCentral.periPermissionsUpdated = false
        }
    }
    
    func updatePermissions()
    {
        var textArray: [String] = []
        var permissionsString = "/"
        
        for tc in bluetoothCentral.transferCharacteristics
        {
            for permission in bluetoothCentral.periPermissions!
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
        }
    }
    
    func clearPermissions()
    {
        permissionToPlayAndPause = false
        permissionToSkip = false
        permissionToRewind = false
//        permissionToChangeVolume = false
//        permissionToAdjustPlayback = false
//        permissionToChangeOutput = false
        permissionToAddSongNext = false
        permissionToAddSongLater = false
        permissionToChangeSongOrder = false
    }
}

//struct PeriPermissionsView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        PeriPermissionsView(bluetoothCentral: BluetoothCentral(), peri: <#CBPeripheral#>)
//    }
//}
