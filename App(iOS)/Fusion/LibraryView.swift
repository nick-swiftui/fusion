//
//  LibraryView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/26/23.
//

import SwiftUI
import MusicKit

//@MainActor
struct LibraryView: View
{
    //@State private var musicLibrary = MusicLibrary.shared
    @State private var albums: [MusicItemCollection<Album>.Element] = []
    @State private var alreadyFetched = false
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var library: Library
    
    @ObservedObject var user: User
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                BackgroundView(user: user, songsQueue: songsQueue)
                
                Group
                {
                    if library.albums.count > 0
                    {
                        ScrollView
                        {
                            VStack
                            {
    //                            List
    //                            {
    //
    //                            }
    //                            .scrollContentBackground(user.appearance == "Dynamic" ? .hidden : .visible)
                                Group
                                {
                                    NavigationLink(
                                        destination:
                                        {
                                            LibraryAlbumsView(library.albums, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user)
                                        }
                                    )
                                    {
                                        LabelView(text: "Albums", symbolName: "square.stack")
                                    }
                                    
                                    NavigationLink(
                                        destination:
                                            {
                                                LibraryArtistsView(library.artists, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user)
                                            }
                                    )
                                    {
                                        LabelView(text: "Artists", symbolName: "music.mic")
                                    }
                                    
                                    NavigationLink(
                                        destination:
                                            {
                                                LibrarySongsView(library.songs, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user)
                                            }
                                    )
                                    {
                                        LabelView(text: "Songs", symbolName: "music.note")
                                    }
                                    NavigationLink(
                                        destination:
                                            {
                                                LibraryPlaylistsView(library.playlists, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user)
                                            }
                                    )
                                    {
                                        LabelView(text: "Playlists", symbolName: "music.note.list")
                                    }
                                }
                                
                                LibraryRecentlyAddedView(library.recentlyAddedAlbums, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user)
                            }
                            .background(Color.gray.opacity(0.25))
                            .cornerRadius(6)
                            .padding(.horizontal)
                        }
                        //LibraryAlbumsView(library.albums, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user)
                        
                    }
                    else
                    {
                        Text("albums == 0")
                    }
                }
                .navigationTitle("Library")
        //        .onAppear
        //        {
        //            if !alreadyFetched
        //            {
        //                fetchData()
        //            }
        //        }
            }
        }
    }
    
    struct LabelView: View
    {
        var text: String
        var symbolName: String

        var body: some View
        {
            HStack
            {
                Image(systemName: symbolName)
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)

                Text(text)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .frame(height: 44)
            .overlay(
                VStack
                {
                    // Wrapping the Divider in a VStack to extend its width
                    Spacer()
                    Divider()
                        .padding(.leading)
                }
            )
        }
    }
    
    func fetchData()
    {
        Task
        {
            do
            {
                // Fetching all albums in the library

                let request = MusicLibraryRequest<Album>()

                let response = try await request.response()
                print("\(response)")
                
                
                DispatchQueue.main.async
                {
                    var tempAlbums: [MusicItemCollection<Album>.Element] = []
                    
                    print(response.items.count)
                    for album in response.items
                    {
                        tempAlbums.append(album)
                    }
                    
                    self.albums = tempAlbums
                    
                    print(tempAlbums.count == 0 ? "==0" : ">0")
                    print(response.items.count == 0 ? "==0" : ">0")
                    
                    print(response.items.last?.url ?? "No URL")
                    print(response.items.last?.id)
                    
                    print(self.albums.last!.playParameters!)
                    print(self.albums.last?.tracks)
                    
                    alreadyFetched = true
                }
            }
            catch
            {
                print("Error: \(error)")
            }
        }
    }
}

//struct LibraryView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        LibraryView()
//    }
//}
