//
//  LibraryRecentlyAddedView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 8/2/23.
//

import SwiftUI
import MusicKit

struct LibraryRecentlyAddedView: View
{
    init(_ albums: [MusicItemCollection<Album>.Element]?, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User)
    {
        self.recentlyAdded = albums
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
    }
    
    let recentlyAdded: [MusicItemCollection<Album>.Element]?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    var body: some View
    {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//            .onTapGesture
//            {
//                print(recentlyAdded?[0].title ?? "nil")
//            }
        if let items = recentlyAdded
        {
            VStack
            {
                HStack
                {
                    Text("Recently Added")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.leading)
                .offset(y: 20)
                
                LazyVGrid(columns: columns, spacing: 20)
                {
                    ForEach(items, id: \.self)
                    { album in
                        NavigationLink(destination: LibraryAlbumDetailView(album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user))
                        {
                            LibraryAlbumCell(user: user, artwork: album.artwork, title: album.title, artistName: album.artistName, contentRating: album.contentRating)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical)
                }
            }
//            ScrollView
//            {
//                LazyVStack
//                {
//                    ForEach(items, id: \.self)
//                    { item in
//                        Text(item.title)
//                    }
//                }
//            }
        }
    }
}

//struct LibraryRecentlyAddedView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        LibraryRecentlyAddedView()
//    }
//}
