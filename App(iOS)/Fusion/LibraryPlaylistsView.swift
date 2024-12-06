//
//  LibraryPlaylistsView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 8/2/23.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistsView: View
{
    init(_ playlists: [MusicItemCollection<Playlist>.Element]?, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User)
    {
        self.playlists = playlists
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
    }
    
    let playlists: [MusicItemCollection<Playlist>.Element]?
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    var body: some View
    {
        ZStack
        {
            BackgroundView(user: user, songsQueue: songsQueue)
            
            ScrollView
            {
                LazyVStack
                {
                    ForEach(playlists!, id: \.self)
                    { playlist in
                        NavigationLink(destination: LibraryPlaylistDetailView(playlist, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user))
                        {
                            LibraryPlaylistCell(playlist: playlist)
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
                .background(Color.gray.opacity(0.25))
                .cornerRadius(6)
                .padding(.horizontal)
            }
            .navigationTitle("Playlists")
        }
    }
}

//struct LibraryPlaylistsView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        LibraryPlaylistsView()
//    }
//}
