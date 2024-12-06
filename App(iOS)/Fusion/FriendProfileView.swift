//
//  FriendProfileView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/8/23.
//

import SwiftUI

struct FriendProfileView: View
{
    let friend: Friend
    
    @ObservedObject var user: User
    
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    var body: some View
    {
        VStack
        {
            Text("Hello, \(friend.name)!")
            Text("ID:\(friend.id)")
            Button(action: selectFriend)
            {
                Text("Select")
            }
        }
    }
    
    func selectFriend()
    {
        user.update(searchID: friend.id)
        
        bluetoothPeripheral.updateServiceUUID(with: user.searchID)
        bluetoothPeripheral.setupPeri()
    }
}

struct FriendProfileView_Previews: PreviewProvider
{
    static var previews: some View
    {
        FriendProfileView(friend: Friend(name: "AI", id: UUID()), user: User(), bluetoothPeripheral: BluetoothPeripheral())
    }
}
