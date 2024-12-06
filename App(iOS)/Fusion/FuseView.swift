//
//  FuseView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/5/23.
//

import SwiftUI

struct FuseView: View
{
    @ObservedObject var songsQueue: SongsQueue
    
    @ObservedObject var user: User
    @ObservedObject var bluetoothCentral: BluetoothCentral
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    var sessionFilter = ["Host", "Join"]
    @State private var selectedSessionFilter = "Host"
    
    @State private var isHostingOrJoined = false
    
    var body: some View
    {
        VStack
        {
            Picker("", selection: $selectedSessionFilter)
            {
                ForEach(sessionFilter, id: \.self)
                {
                    Text($0)
                }
            }
            .padding(.top)
            .pickerStyle(.segmented)
            .disabled(bluetoothCentral.isHosting || bluetoothPeripheral.isPeering)
            
            if selectedSessionFilter == "Host"
            {
                HostView(songsQueue: songsQueue, user: user, bluetoothCentral: bluetoothCentral)
            }
            else
            {
                JoinView(user: user, bluetoothPeripheral: bluetoothPeripheral)
            }
            
            Spacer()
        }
        .onAppear
        {
            if bluetoothCentral.isHosting
            {
                selectedSessionFilter = "Host"
            }
            else if bluetoothPeripheral.isPeering
            {
                selectedSessionFilter = "Join"
            }
        }
    }
}

struct FuseView_Previews: PreviewProvider
{
    static var previews: some View
    {
        FuseView(songsQueue: SongsQueue(), user: User(), bluetoothCentral: BluetoothCentral(), bluetoothPeripheral: BluetoothPeripheral())
    }
}
