//
//  PermissionsView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/8/23.
//

import SwiftUI

struct PermissionsView: View
{
    @ObservedObject var user: User
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    @State private var permissionToPlayAndPause = false
    @State private var permissionToSkip = false
    @State private var permissionToRewind = false
    //@State private var permissionToChangeVolume = false
    //@State private var permissionToAdjustPlayback = false
    //@State private var permissionToChangeOutput = false
    @State private var permissionToAddSongNext = false
    @State private var permissionToAddSongLater = false
    @State private var permissionToChangeSongOrder = false
    
    var body: some View
    {
        VStack
        {
            Text("Set default permissions here")
            Text("")
            Text("Press 'Update' to update all connected devices")
            
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
                                    if !bluetoothCentral.permissions.contains("P")
                                    {
                                        bluetoothCentral.permissions.append("P")
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.permissions.contains("P")
                                    {
                                        let pos = bluetoothCentral.permissions.firstIndex(of: "P")
                                        bluetoothCentral.permissions.remove(at: pos!)
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                
                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
                                print("User: \(user.permissions)")
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
                                    if !bluetoothCentral.permissions.contains("S")
                                    {
                                        bluetoothCentral.permissions.append("S")
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.permissions.contains("S")
                                    {
                                        let pos = bluetoothCentral.permissions.firstIndex(of: "S")
                                        bluetoothCentral.permissions.remove(at: pos!)
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                
                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
                                print("User: \(user.permissions)")
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
                                    if !bluetoothCentral.permissions.contains("R")
                                    {
                                        bluetoothCentral.permissions.append("R")
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.permissions.contains("R")
                                    {
                                        let pos = bluetoothCentral.permissions.firstIndex(of: "R")
                                        bluetoothCentral.permissions.remove(at: pos!)
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                
                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
                                print("User: \(user.permissions)")
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
//                                    if !bluetoothCentral.permissions.contains("V")
//                                    {
//                                        bluetoothCentral.permissions.append("V")
//                                        user.update(permissions: bluetoothCentral.permissions)
//                                    }
//                                }
//                                else
//                                {
//                                    if bluetoothCentral.permissions.contains("V")
//                                    {
//                                        let pos = bluetoothCentral.permissions.firstIndex(of: "V")
//                                        bluetoothCentral.permissions.remove(at: pos!)
//                                        user.update(permissions: bluetoothCentral.permissions)
//                                    }
//                                }
//
//                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
//                                print("User: \(user.permissions)")
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
//                                    if !bluetoothCentral.permissions.contains("B")
//                                    {
//                                        bluetoothCentral.permissions.append("B")
//                                        user.update(permissions: bluetoothCentral.permissions)
//                                    }
//                                }
//                                else
//                                {
//                                    if bluetoothCentral.permissions.contains("B")
//                                    {
//                                        let pos = bluetoothCentral.permissions.firstIndex(of: "B")
//                                        bluetoothCentral.permissions.remove(at: pos!)
//                                        user.update(permissions: bluetoothCentral.permissions)
//                                    }
//                                }
//
//                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
//                                print("User: \(user.permissions)")
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
//                                    if !bluetoothCentral.permissions.contains("O")
//                                    {
//                                        bluetoothCentral.permissions.append("O")
//                                        user.update(permissions: bluetoothCentral.permissions)
//                                    }
//                                }
//                                else
//                                {
//                                    if bluetoothCentral.permissions.contains("O")
//                                    {
//                                        let pos = bluetoothCentral.permissions.firstIndex(of: "O")
//                                        bluetoothCentral.permissions.remove(at: pos!)
//                                        user.update(permissions: bluetoothCentral.permissions)
//                                    }
//                                }
//
//                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
//                                print("User: \(user.permissions)")
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
                                    if !bluetoothCentral.permissions.contains("QN")
                                    {
                                        bluetoothCentral.permissions.append("QN")
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.permissions.contains("QN")
                                    {
                                        let pos = bluetoothCentral.permissions.firstIndex(of: "QN")
                                        bluetoothCentral.permissions.remove(at: pos!)
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                
                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
                                print("User: \(user.permissions)")
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
                                    if !bluetoothCentral.permissions.contains("QL")
                                    {
                                        bluetoothCentral.permissions.append("QL")
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.permissions.contains("QL")
                                    {
                                        let pos = bluetoothCentral.permissions.firstIndex(of: "QL")
                                        bluetoothCentral.permissions.remove(at: pos!)
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                
                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
                                print("User: \(user.permissions)")
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
                                    if !bluetoothCentral.permissions.contains("QO")
                                    {
                                        bluetoothCentral.permissions.append("QO")
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                else
                                {
                                    if bluetoothCentral.permissions.contains("QO")
                                    {
                                        let pos = bluetoothCentral.permissions.firstIndex(of: "QO")
                                        bluetoothCentral.permissions.remove(at: pos!)
                                        user.update(permissions: bluetoothCentral.permissions)
                                    }
                                }
                                
                                print("BC: \(bluetoothCentral.permissions ?? ["BC Error"])")
                                print("User: \(user.permissions)")
                            }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            Button(action: updatePermissions)
            {
                Text("Update")
            }
            .padding()
            
            Button(action: clearPermissions)
            {
                Text("Clear Permissions")
            }
            .padding()
            
            Spacer()
        }
        .onAppear
        {
            for permission in bluetoothCentral.permissions
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
        }
    }
    
    func updatePermissions()
    {
        var textArray: [String] = []
        var permissionsString = "/"
        
        for peri in bluetoothCentral.connectedPeripherals.keys
        {
            for tc in bluetoothCentral.transferCharacteristics
            {
                if tc.service?.peripheral?.identifier != peri.identifier
                {
                    continue
                }
                
                for permission in bluetoothCentral.permissions
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
    }
    
    func clearPermissions()
    {
        bluetoothCentral.permissions = []
        user.update(permissions: bluetoothCentral.permissions)
        
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

struct PermissionsView_Previews: PreviewProvider
{
    static var previews: some View
    {
        PermissionsView(
            user: User(),
            bluetoothCentral: BluetoothCentral()
        )
    }
}
