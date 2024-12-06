//
//  ArtistAlbumsExpandedView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 6/21/23.
//

import SwiftUI
import MusicKit

struct ArtistAlbumsExpandedView: View
{
    // MARK: - Object lifecycle
    
    init(_ albums: [MusicItemCollection<Album>.Element]?, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User, bluetoothCentral: BluetoothCentral)
    {
        self.albums = albums
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
        
        self.bluetoothCentral = bluetoothCentral
    }
    
    // MARK: - Properties
    
    /// The album that this view represents.
    let albums: [MusicItemCollection<Album>.Element]?
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    // MARK: - View
    
    var body: some View
    {
        if self.albums != nil
        {
            ScrollView
            {
                LazyVGrid(columns: columns, spacing: 20)
                {
                    ForEach(albums!, id: \.self)
                    { album in
                        NavigationLink(destination: AlbumDetailView(album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral))
                        {
                            ArtistAlbumCell(artwork: album.artwork, title: album.title, releaseDate: album.releaseDate, contentRating: album.contentRating)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Albums")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//struct ArtistAlbumsExpandedView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        ArtistAlbumsExpandedView()
//    }
//}
