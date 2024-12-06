//
//  AccessoriesView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/5/23.
//

import SwiftUI

struct AccessoriesView: View
{
    @ObservedObject var songsQueue: SongsQueue
    
    @ObservedObject var user: User
    @ObservedObject var bluetoothCentral: BluetoothCentral
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var library: Library
    
    @State private var showingFuseSheet = false
    
    @State private var showingLibraryView = false
    
    //@State private var discoveredPeripheralName = ""
    
    var body: some View
    {
        NavigationStack
        {
            HStack
            {
                Button(action: toggleShowingFuseSheet)
                {
                    Text("Fuse")
                }
                .padding()
                .sheet(isPresented: $showingFuseSheet)
                {
                    FuseView(songsQueue: songsQueue, user: user, bluetoothCentral: bluetoothCentral, bluetoothPeripheral: bluetoothPeripheral)
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
                        .interactiveDismissDisabled(bluetoothPeripheral.showingConnectingAlert || bluetoothPeripheral.showingConnectingAlertBackup)
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
                
//                NavigationLink(destination: LibraryView(songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, library: library, user: user)) //.toolbar(.hidden, for: .tabBar)
//                {
//                    Text("Library")
//                }
            }
        }
    }
    
    func toggleShowingFuseSheet()
    {
        showingFuseSheet.toggle()
    }
    
    func toggleShowingLibraryView()
    {
        
    }
}

struct AccessoriesView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AccessoriesView(songsQueue: SongsQueue(), user: User(), bluetoothCentral: BluetoothCentral(), bluetoothPeripheral: BluetoothPeripheral(), library: Library())
    }
}
