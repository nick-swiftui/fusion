//
//  HostView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/5/23.
//

import SwiftUI

struct HostView: View
{
    @ObservedObject var songsQueue: SongsQueue
    
    @ObservedObject var user: User
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                VStack
                {
                    HStack
                    {
                        Text("Peers")
                            .font(.title)
                            .foregroundColor(user.appearance == "Light" ? .black : .white)
                        Spacer()
                        Text("\(bluetoothCentral.connectedPeripherals.count) / 7")
                    }
                    //.padding(.leading)
                    
                    List
                    {
                        ForEach(Array(bluetoothCentral.connectedPeripherals.keys), id: \.identifier)
                        { peri in
                            HStack
                            {
                                NavigationLink
                                {
                                    PeriPermissionsView(bluetoothCentral: bluetoothCentral, peri: peri)
                                }
                            label:
                                {
                                    Text(bluetoothCentral.connectedPeripherals[peri]!)
                                }
                            }
                            Button("Disconnect")
                            {
                                bluetoothCentral.disconnect(peripheral: peri)
                                print("xxxxx\(bluetoothCentral.connectedPeripherals.description)")
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack
                    {
                        Spacer()
                        NavigationLink
                        {
                            PermissionsView(user: user, bluetoothCentral: bluetoothCentral)
                        }
                        label:
                            {
                                Text("Permissions")
                            }
                        Spacer()
                    }
                    .padding()
                    
                    HStack
                    {
                        Text("Status: \(bluetoothCentral.isHosting ? "Hosting" : "Not Hosting")")
                        Spacer()
                    }
                    
    //                HStack
    //                {
    //                    Text("Input: \(bluetoothCentral.text ?? "nil")")
    //                    Spacer()
    //                }
                    
    //                HStack
    //                {
    //                    Text("\(bluetoothCentral.connectedPeripherals.count) / 7 connected peripherals")
    //                    Spacer()
    //                }
                    
                    HStack
                    {
                        Text("Scanning")
                        Toggle("", isOn: $bluetoothCentral.scanningToggleIsOn)
                            .disabled(!bluetoothCentral.scanningToggleEnabled)
                            .onChange(of: bluetoothCentral.scanningToggleIsOn)
                            { _ in
                                bluetoothCentral.toggleChanged()
                            }
                    }
                }
                .padding()
                
                if !user.isPro
                {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(LockedHostAlertView(user: user))
//                        .opacity(connectingOpacity)
//                        .onAppear
//                        {
//                            withAnimation
//                            {
//                                connectingOpacity = 1.0
//                            }
//                        }
//                        .onDisappear
//                        {
//                            withAnimation
//                            {
//                                connectingOpacity = 0.0
//                            }
//                        }
                }
            }
        }
    }
}

struct HostView_Previews: PreviewProvider
{
    static var previews: some View
    {
        HostView(songsQueue: SongsQueue(), user: User(), bluetoothCentral: BluetoothCentral())
    }
}





struct LockedHostAlertView: View
{
    //let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @ObservedObject var user: User
    
    var body: some View
    {
        ZStack
        {
            RoundedRectangle(cornerRadius: 10)
                .fill(user.appearance == "Light" ? Color.white : Color.black)
                .frame(width: 300, height: 150)
            
            Text("To start hosting, purchase the \nPro membership from the shop.")
                .font(.headline)
        }
    }
}











//    .alert("\(discoveredPeripheralName) wants to connect.", isPresented: $showingAlert)
//    {
//        let tempValue = bluetoothCentral.discoveredPeripheralName
//
//        Button("Allow", role: .cancel)
//        {
//            var textArray: [String] = ["+"]
//            var permissionsString = "/"
//
//            for peri in bluetoothCentral.connectedPeripherals.keys
//            {
//                if bluetoothCentral.connectedPeripherals[peri] == tempValue
//                {
//                    for tc in bluetoothCentral.transferCharacteristics
//                    {
//                        for permission in bluetoothCentral.permissions
//                        {
//                            permissionsString.append("\(permission),")
//                        }
//                        if permissionsString.last == ","
//                        {
//                            permissionsString.removeLast()
//                        }
//                        textArray.append(permissionsString)
//                        let data = try! JSONEncoder().encode(textArray)
//                        peri.writeValue(data, for: tc, type: .withoutResponse)
//
//                        textArray = ["+"]
//                        permissionsString = "/"
//                    }
//
//                    break
//                }
//            }
//
//            bluetoothCentral.showingAlert = false
//
//            bluetoothCentral.peripheralCheckInLine.remove(at: 0)
//            print(bluetoothCentral.peripheralCheckInLine.count)
//        }
//        Button("Deny", role: .none)
//        {
//            for peri in bluetoothCentral.connectedPeripherals.keys
//            {
//                if bluetoothCentral.connectedPeripherals[peri] == tempValue
//                {
//                    bluetoothCentral.disconnect(peripheral: peri)
//                    break
//                }
//            }
//            bluetoothCentral.showingAlert = false
//
//            bluetoothCentral.peripheralCheckInLine.remove(at: 0)
//        }
//    }
