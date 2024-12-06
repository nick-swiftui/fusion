//
//  LibraryArtistsView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/28/23.
//

import SwiftUI
import MusicKit

struct LibraryArtistsView: View
{
    init(_ artists: [MusicItemCollection<Artist>.Element]?, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User)
    {
        self.artists = artists
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
    }
    
    let artists: [MusicItemCollection<Artist>.Element]?
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    var body: some View
    {
        if self.artists != nil
        {
            ZStack
            {
                BackgroundView(user: user, songsQueue: songsQueue)
                
                ScrollView
                {
                    LazyVStack
                    {
                        ForEach(artists!, id: \.self)
                        { artist in
                            NavigationLink(destination: LibraryArtistDetailView(artist, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user))
                            {
                                LibraryArtistCell(artist: artist)
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
                .navigationTitle("Artists")
            }
        }
    }
}

//struct LibraryArtistsView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        LibraryArtistsView()
//    }
//}
