//
//  ArtistCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/11/23.
//

import MusicKit
import SwiftUI

/// `ArtistCell` is a view to use in a SwiftUI `List` to represent an `Artist`.
struct ArtistCell: View
{
    // MARK: - Object lifecycle
    
    init(_ artist: Artist, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User, bluetoothCentral: BluetoothCentral)
    {
        self.artist = artist
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
        
        self.bluetoothCentral = bluetoothCentral
    }
    
    // MARK: - Properties
    
    let artist: Artist
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    // MARK: - View
    
    var body: some View
    {
        NavigationLink(destination: ArtistDetailView(artist, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral))
        {
            MusicItemCell(
                artwork: artist.artwork,
                title: artist.name,
                subtitle: ""
            )
        }
    }
}

//struct ArtistCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        ArtistCell()
//    }
//}
