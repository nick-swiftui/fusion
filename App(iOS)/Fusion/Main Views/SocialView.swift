//
//  SocialView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/20/23.
//

import SwiftUI
import CodeScanner
import CoreImage.CIFilterBuiltins

struct SocialView: View
{
    @ObservedObject var user: User
    
    @ObservedObject var songsQueue: SongsQueue
    
    @State private var isShowingCode = false
    @State private var isShowingScanner = false
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    //@State private var discoveredPeripheralName = ""
    
    @State private var showingMaxFriendsAlert = false
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                BackgroundView(user: user, songsQueue: songsQueue)
                
                VStack
                {
//                    HStack
//                    {
//                        Spacer()
//                        Text("\(user.friends.count)/\(user.isPro ? "100" : "10")")
//                    }
                    
                    if !user.friends.isEmpty
                    {
                        List
                        {
                            Section
                            {
                                Text("\(user.friends.count)/\(user.isPro ? "100" : "10")")
                            }
                            ForEach($user.friends, id: \.id)
                            { $friend in
                                Button(action:
                                {
                                    //selectFriend(friend)
                                })
                                {
                                    HStack
                                    {
                                        Text(friend.name)
                                            .foregroundColor(.primary)
                                        Spacer()
//                                        if friend.isSelected
//                                        {
//                                            Image(systemName: "checkmark")
//                                        }
                                    }
                                }
                            }
                            .onDelete(perform:
                            { indexSet in
                                user.friends.remove(atOffsets: indexSet)
                                
                                for friend in user.friends
                                {
                                    if friend.id == user.searchID
                                    {
                                        return
                                    }
                                }
                                
                                if !user.friends.isEmpty
                                {
                                    selectFriend(user.friends.first!)
                                }
                                else
                                {
                                    saveSearchingID(with: UUID().uuidString)
                                }
                            })
//                            .onChange(of: user.friends)
//                            { newValue in
//                                print(".onChange occured. \(user.friends)")
//                                for friend in newValue
//                                {
//                                    if friend.id == user.searchID
//                                    {
//                                        return
//                                    }
//                                }
//
//                                if !user.friends.isEmpty
//                                {
//                                    selectFriend(user.friends.first!)
//                                    print(user.searchID)
//                                }
//                                else
//                                {
//                                    user.update(searchID: UUID())
//                                    print("iE \(user.searchID)")
//                                }
//                            }
                        }
                        .scrollContentBackground(user.appearance == "Dynamic" ? .hidden : .visible)
                        .alert(isPresented: $showingMaxFriendsAlert)
                        {
                            Alert(
                                title: Text("Friends List Full"),
                                message: Text("Remove a friend to add another one."),
                                dismissButton: .default(Text("Okay"))
                                {
                                    showingMaxFriendsAlert = false
                                }
                            )
                        }
                    }
                    else
                    {
                        Spacer()
                    }
                    
//                    Text("Searching for: \(user.searchID)")
//
//                    Button("Remove")
//                    {
//                        user.friends.remove(at: 0)
//                    }
                }
                .navigationTitle("Friends")
                .toolbar
                {
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        Button
                        {
                            isShowingCode = true
                        }
                        label:
                        {
                            Text("Show QR Code")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                        Button
                        {
                            if (user.isPro && user.friends.count >= 100) || (!user.isPro && user.friends.count >= 10)
                            {
                                showingMaxFriendsAlert = true
                            }
                            else
                            {
                                isShowingScanner = true
                            }
                        }
                        label:
                        {
                            Label("Scan", systemImage: "qrcode.viewfinder")
                        }
                    }
                }
                .sheet(isPresented: $isShowingCode)
                {
                    Image(uiImage: generateQRCode(from: "\(user.name)\n\(user.hostID.uuidString)"))
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .alert(isPresented: $bluetoothPeripheral.showingAlert)
                        {
                            Alert(
                                title: Text("Disconnected"),
                                message: Text("The central has disconnected from you."),
                                dismissButton: .default(Text("Okay"))
                                {
                                    bluetoothPeripheral.showingAlert = false
                                }
                            )
                        }
                        .alert("\(bluetoothCentral.discoveredPeripheralNameCheckedIn) wants to connect.", isPresented: $bluetoothCentral.showingConnectingAlert)
                        {
                            //let peer = bluetoothCentral.discoveredPeripheralName
                            //let peri = bluetoothCentral.discoveredPeripheral
                            let peri = bluetoothCentral.currentCheckedInPeri
                            
                            var tempArray: [String] = []
                            //var tempString: String = ""
                            
                            Button("Allow", role: .cancel)
                            {
                                // First, send permissions.
                                //bluetoothCentral.sendPermissions(to: peer)
                                bluetoothCentral.sendPermissions(to: peri!)
                                
                                // Second, send history.
                                tempArray = []
                                
                                for aSong in songsQueue.history
                                {
                                    if let song = aSong
                                    {
                                        tempArray.append(song.id.description)
                                        
                                        if tempArray.count == 40
                                        {
                                            // Send to peer
                                            //bluetoothCentral.sendHistory(to: peer, with: tempArray, count: songsQueue.history.count)
                                            bluetoothCentral.sendHistory(to: peri!, with: tempArray, count: songsQueue.history.count)
                                            
                                            tempArray = []
                                        }
                                    }
                                }
                                
                                if !tempArray.isEmpty
                                {
                                    //bluetoothCentral.sendHistory(to: peer, with: tempArray, count: songsQueue.history.count)
                                    bluetoothCentral.sendHistory(to: peri!, with: tempArray, count: songsQueue.history.count)
                                }
                                
                                // Third, send current song.
                                if let song = songsQueue.currentSong
                                {
                                    //bluetoothCentral.sendCurrentSong(to: peer, with: song.id.description)
                                    bluetoothCentral.sendCurrentSong(to: peri!, with: song.id.description)
                                }
                                
                                // Fourth, send queue.
                                tempArray = []
                                
                                // This removes progress view from peri
                                // when .songArray is empty
                                if songsQueue.songArray.isEmpty
                                {
                                    bluetoothCentral.sendQueue(to: peri!, queueIDs: [], count: 0)
                                }
                                
                                for aSong in songsQueue.songArray
                                {
                                    if let song = aSong
                                    {
                                        tempArray.append(song.id.description)
                                        
                                        if tempArray.count == 40
                                        {
                                            // Send to peer
                                            //bluetoothCentral.sendQueue(to: peer, queueIDs: tempArray, count: songsQueue.songArray.count)
                                            bluetoothCentral.sendQueue(to: peri!, queueIDs: tempArray, count: songsQueue.songArray.count)
                                            
                                            tempArray = []
                                        }
                                    }
                                }
                                
                                if !tempArray.isEmpty
                                {
                                    //bluetoothCentral.sendQueue(to: peer, queueIDs: tempArray, count: songsQueue.songArray.count)
                                    bluetoothCentral.sendQueue(to: peri!, queueIDs: tempArray, count: songsQueue.songArray.count)
                                }
                                
                                // Fifth, send peers.
                                tempArray = []
                                
                                if !bluetoothCentral.connectedPeripherals.isEmpty
                                {
                                    for peri in bluetoothCentral.connectedPeripherals.values
                                    {
                                        tempArray.append(peri)
                                    }
                                    
                                    bluetoothCentral.sendPeers(to: peri!, peers: tempArray)
                                }
                                
                                // Finish up
                                bluetoothCentral.showingAlert = false
                                
                                bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                                print(bluetoothCentral.peripheralCheckInLine.count)
                            }
                            Button("Deny", role: .none)
                            {
                //                    for peri in bluetoothCentral.connectedPeripherals.keys
                //                    {
                //                        if bluetoothCentral.connectedPeripherals[peri] == peer
                //                        {
                //                            bluetoothCentral.disconnect(peripheral: peri)
                //                            break
                //                        }
                //                    }
                //                    bluetoothCentral.showingAlert = false
                //
                //                    bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                                
                                bluetoothCentral.disconnect(peripheral: peri!)
                                bluetoothCentral.showingAlert = false
                                
                                bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                            }
                        }
                }
                .sheet(isPresented: $isShowingScanner)
                {
                    CodeScannerView(codeTypes: [.qr], completion: handleScan)
                        .alert(isPresented: $bluetoothPeripheral.showingAlert)
                        {
                            Alert(
                                title: Text("Disconnected"),
                                message: Text("The central has disconnected from you."),
                                dismissButton: .default(Text("Okay"))
                                {
                                    bluetoothPeripheral.showingAlert = false
                                }
                            )
                        }
                        .alert("\(bluetoothCentral.discoveredPeripheralNameCheckedIn) wants to connect.", isPresented: $bluetoothCentral.showingConnectingAlert)
                        {
                            //let peer = bluetoothCentral.discoveredPeripheralName
                            //let peri = bluetoothCentral.discoveredPeripheral
                            let peri = bluetoothCentral.currentCheckedInPeri
                            
                            var tempArray: [String] = []
                            //var tempString: String = ""
                            
                            Button("Allow", role: .cancel)
                            {
                                // First, send permissions.
                                //bluetoothCentral.sendPermissions(to: peer)
                                bluetoothCentral.sendPermissions(to: peri!)
                                
                                // Second, send history.
                                tempArray = []
                                
                                for aSong in songsQueue.history
                                {
                                    if let song = aSong
                                    {
                                        tempArray.append(song.id.description)
                                        
                                        if tempArray.count == 40
                                        {
                                            // Send to peer
                                            //bluetoothCentral.sendHistory(to: peer, with: tempArray, count: songsQueue.history.count)
                                            bluetoothCentral.sendHistory(to: peri!, with: tempArray, count: songsQueue.history.count)
                                            
                                            tempArray = []
                                        }
                                    }
                                }
                                
                                if !tempArray.isEmpty
                                {
                                    //bluetoothCentral.sendHistory(to: peer, with: tempArray, count: songsQueue.history.count)
                                    bluetoothCentral.sendHistory(to: peri!, with: tempArray, count: songsQueue.history.count)
                                }
                                
                                // Third, send current song.
                                if let song = songsQueue.currentSong
                                {
                                    //bluetoothCentral.sendCurrentSong(to: peer, with: song.id.description)
                                    bluetoothCentral.sendCurrentSong(to: peri!, with: song.id.description)
                                }
                                
                                // Fourth, send queue.
                                tempArray = []
                                
                                // This removes progress view from peri
                                // when .songArray is empty
                                if songsQueue.songArray.isEmpty
                                {
                                    bluetoothCentral.sendQueue(to: peri!, queueIDs: [], count: 0)
                                }
                                
                                for aSong in songsQueue.songArray
                                {
                                    if let song = aSong
                                    {
                                        tempArray.append(song.id.description)
                                        
                                        if tempArray.count == 40
                                        {
                                            // Send to peer
                                            //bluetoothCentral.sendQueue(to: peer, queueIDs: tempArray, count: songsQueue.songArray.count)
                                            bluetoothCentral.sendQueue(to: peri!, queueIDs: tempArray, count: songsQueue.songArray.count)
                                            
                                            tempArray = []
                                        }
                                    }
                                }
                                
                                if !tempArray.isEmpty
                                {
                                    //bluetoothCentral.sendQueue(to: peer, queueIDs: tempArray, count: songsQueue.songArray.count)
                                    bluetoothCentral.sendQueue(to: peri!, queueIDs: tempArray, count: songsQueue.songArray.count)
                                }
                                
                                // Fifth, send peers.
                                tempArray = []
                                
                                if !bluetoothCentral.connectedPeripherals.isEmpty
                                {
                                    for peri in bluetoothCentral.connectedPeripherals.values
                                    {
                                        tempArray.append(peri)
                                    }
                                    
                                    bluetoothCentral.sendPeers(to: peri!, peers: tempArray)
                                }
                                
                                // Finish up
                                bluetoothCentral.showingAlert = false
                                
                                bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                                print(bluetoothCentral.peripheralCheckInLine.count)
                            }
                            Button("Deny", role: .none)
                            {
                //                    for peri in bluetoothCentral.connectedPeripherals.keys
                //                    {
                //                        if bluetoothCentral.connectedPeripherals[peri] == peer
                //                        {
                //                            bluetoothCentral.disconnect(peripheral: peri)
                //                            break
                //                        }
                //                    }
                //                    bluetoothCentral.showingAlert = false
                //
                //                    bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                                
                                bluetoothCentral.disconnect(peripheral: peri!)
                                bluetoothCentral.showingAlert = false
                                
                                bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                            }
                        }
                }
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage
    {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage
        {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
            {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func handleScan(result: Result<ScanResult, ScanError>)
    {
        isShowingScanner = false
        
        switch result
        {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            print(details)
            print(details.count)
            guard details.count == 2 else { return }
            
            addFriend(with: details)
            print(details)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func saveSearchingID(with id: String)
    {
        user.update(searchID: UUID(uuidString: id)!)
        bluetoothPeripheral.updateServiceUUID(with: user.searchID)
        bluetoothPeripheral.setupPeri()
    }
    
    func addFriend(with details: [String])
    {
        let friend =
        Friend(
            name: details[0],
            id: UUID(uuidString: details[1])!
        )
        
        if user.friends.contains(friend)
        {
            // Tell user they are already friends
        }
        else
        {
            user.add(friend: friend)
        }
        
        selectFriend(friend)
        
        //saveSearchingID(with: details[1])
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

struct SocialView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SocialView(user: User(), songsQueue: SongsQueue(), bluetoothPeripheral: BluetoothPeripheral(), bluetoothCentral: BluetoothCentral())
    }
}
