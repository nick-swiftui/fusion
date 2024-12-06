//
//  AlbumCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/9/23.
//

import MusicKit
import SwiftUI

/// `AlbumCell` is a view to use in a SwiftUI `List` to represent an `Album`.
struct AlbumCell: View
{
    // MARK: - Object lifecycle
    
    init(_ album: Album, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User, bluetoothCentral: BluetoothCentral)
    {
        self.album = album
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
        
        self.bluetoothCentral = bluetoothCentral
    }
    
    // MARK: - Properties
    
    let album: Album
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    // MARK: - View
    
    var body: some View
    {
        NavigationLink(destination: AlbumDetailView(album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral))
        {
            MusicItemCell(
                artwork: album.artwork,
                title: album.title,
                subtitle: album.artistName
            )
        }
    }
}

//struct AlbumCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        AlbumCell()
//    }
//}
