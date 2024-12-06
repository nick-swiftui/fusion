//
//  JoinView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/5/23.
//

import SwiftUI

struct JoinView: View
{
    @ObservedObject var user: User
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @State private var connectingOpacity = 0.0
    
    @State private var selectedFriend: Friend?
    
    var body: some View
    {
        ZStack
        {
            VStack
            {
                HStack
                {
                    Text("Connected To: \(bluetoothPeripheral.isPeering ? "\(selectedFriend?.name ?? "No one")" : "No one")")
                    Spacer()
                    Button("Disconnect")
                    {
                        updateText(with: "!")
                    }
                    .disabled(bluetoothPeripheral.connectedCentral == nil)
                }
                
//                HStack
//                {
//                    Button("Disconnect")
//                    {
//                        updateText(with: "!")
//                    }
//                    .disabled(bluetoothPeripheral.connectedCentral == nil)
//
//                    Spacer()
//                }
                
                if !bluetoothPeripheral.isPeering
                {
                    if !user.friends.isEmpty
                    {
                        VStack
                        {
                            HStack
                            {
                                Text("Friends")
                                    .font(.title)
                                    .foregroundColor(user.appearance == "Light" ? .black : .white)
                                Spacer()
                            }
                            
                            List
                            {
                                ForEach($user.friends, id: \.id)
                                { $friend in
                                    Button(action:
                                    {
                                        selectFriend(friend)
                                    })
                                    {
                                        HStack
                                        {
                                            Text(friend.name)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            if friend.isSelected
                                            {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
//                                .onDelete(perform:
//                                { indexSet in
//                                    user.friends.remove(atOffsets: indexSet)
//
//                                    for friend in user.friends
//                                    {
//                                        if friend.id == user.searchID
//                                        {
//                                            return
//                                        }
//                                    }
//
//                                    if !user.friends.isEmpty
//                                    {
//                                        selectFriend(user.friends.first!)
//                                    }
//                                    else
//                                    {
//                                        saveSearchingID(with: UUID().uuidString)
//                                    }
//                                })
                            }
                            .scrollContentBackground(user.appearance == "Dynamic" ? .hidden : .visible)
                        }
                    }
                }
                else
                {
                    if !bluetoothPeripheral.peersArray.isEmpty
                    {
                        VStack
                        {
                            HStack
                            {
                                Text("Peers")
                                    .font(.title)
                                    .foregroundColor(user.appearance == "Light" ? .black : .white)
                                Spacer()
                                Text("\(bluetoothPeripheral.peersArray.count) / 7")
                            }
                            
                            List(bluetoothPeripheral.peersArray, id: \.self)
                            { peer in
                                Text(peer)
                            }
                            .scrollContentBackground(user.appearance == "Dynamic" ? .hidden : .visible)
                        }
                        .opacity(bluetoothPeripheral.peersListOpacity)
                    }
                }
                
                Spacer()
                
                HStack
                {
                    Text("Status: \(bluetoothPeripheral.isPeering ? "Peering" : "Not Peering")")
                    Spacer()
                }
                
                HStack
                {
                    Text("Advertising")
                    Toggle("", isOn: $bluetoothPeripheral.advertisingToggleIsOn)
                        .disabled(!bluetoothPeripheral.advertisingToggleEnabled || bluetoothPeripheral.connectedCentral != nil)
                        .onChange(of: bluetoothPeripheral.advertisingToggleIsOn)
                        { newValue in
                            if newValue == true
                            {
                                bluetoothPeripheral.text = "?\(user.name)"
                                bluetoothPeripheral.showingConnectingAlert = true
                                bluetoothPeripheral.showingConnectingAlertBackup = true
                            }
                            
                            bluetoothPeripheral.toggleChanged()
                        }
                }
            }
            .padding()
            
            if bluetoothPeripheral.showingConnectingAlert == true || bluetoothPeripheral.showingConnectingAlertBackup == true
            {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(ProgressAlertView(user: user, bluetoothPeripheral: bluetoothPeripheral))
                    .opacity(connectingOpacity)
                    .onAppear
                    {
                        withAnimation
                        {
                            connectingOpacity = 1.0
                        }
                    }
                    .onDisappear
                    {
                        withAnimation
                        {
                            connectingOpacity = 0.0
                        }
                    }
            }
        }
        .onAppear
        {
            for friend in user.friends
            {
                if friend.isSelected
                {
                    selectedFriend = friend
                }
            }
        }
        .onChange(of: bluetoothPeripheral.connectedCentral)
        { newValue in
            if newValue != nil && bluetoothPeripheral.text == "!"
            {
                updateText(with: "!")
                //print("Connected - \(bluetoothPeripheral.text)")
            }
            else
            {
                //print("Not connected")
            }
        }
    }
    
    func updateText(with message: String)
    {
        bluetoothPeripheral.text = message
        bluetoothPeripheral.dataToSend = bluetoothPeripheral.text.data(using: .utf8)!
        bluetoothPeripheral.sendDataIndex = 0
        bluetoothPeripheral.peripheralManagerIsReady(toUpdateSubscribers: bluetoothPeripheral.peripheralManager)
    }
    
    func saveSearchingID(with id: String)
    {
        user.update(searchID: UUID(uuidString: id)!)
        bluetoothPeripheral.updateServiceUUID(with: user.searchID)
        bluetoothPeripheral.setupPeri()
    }
    
    func selectFriend(_ selectedFriend: Friend)
    {
        saveSearchingID(with: selectedFriend.id.description)
        
        user.friends = user.friends.map
        { friend in
            var mutableFriend = friend
            mutableFriend.isSelected = friend.id == selectedFriend.id
            return mutableFriend
        }
    }
}

struct JoinView_Previews: PreviewProvider
{
    static var previews: some View
    {
        JoinView(user: User(), bluetoothPeripheral: BluetoothPeripheral())
    }
}





struct ProgressAlertView: View
{
    //let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @ObservedObject var user: User
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    var body: some View
    {
        ZStack
        {
            RoundedRectangle(cornerRadius: 10)
                .fill(user.appearance == "Light" ? Color.white : Color.black)
                .frame(width: 150, height: 150)
            
            VStack
            {
                ProgressView()
                    .padding()
                
                Text("Please Wait")
                    .font(.headline)
                
                Button(action: cancelConnection)
                {
                    Text("Cancel")
                }
                //.disabled(!bluetoothPeripheral.advertisingToggleIsOn)
            }
        }
    }
    
    func cancelConnection()
    {
        updateText(with: "!")
        bluetoothPeripheral.advertisingToggleIsOn = false
        bluetoothPeripheral.showingConnectingAlert = false
        bluetoothPeripheral.showingConnectingAlertBackup = false
    }
    
    func updateText(with message: String)
    {
        bluetoothPeripheral.text = message
        bluetoothPeripheral.dataToSend = bluetoothPeripheral.text.data(using: .utf8)!
        bluetoothPeripheral.sendDataIndex = 0
        bluetoothPeripheral.peripheralManagerIsReady(toUpdateSubscribers: bluetoothPeripheral.peripheralManager)
    }
}
