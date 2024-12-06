//
//  ArtistDetailView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/11/23.
//

import SwiftUI
import MusicKit

struct ArtistDetailView: View
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
    
    /// The artist that this view represents.
    let artist: Artist
    
    @State var albums: MusicItemCollection<Album>?
    @State var sortedAlbums: [MusicItemCollection<Album>.Element]?
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    //private var albumsCount: Int = 0
    
    //@State var featuredAlbums: MusicItemCollection<Album>?
    //@State var sortedFeaturedAlbums: [MusicItemCollection<Album>.Element]?
    
    // MARK: - View
    
    var body: some View
    {
        GeometryReader
        { geometry in
            ScrollView
            {
                if let artwork = artist.artwork
                {
                    ArtworkImage(artwork, width: geometry.size.width)
                        .frame(width: geometry.size.width, height: geometry.size.width * 0.67)
                        .clipped()
                }
                
                //ArtistAboutView(artist)
                
//                if let featuredAlbum = featuredAlbums?.first
//                {
//                    FeaturedAlbumCell(artwork: featuredAlbum.artwork, title: featuredAlbum.title)
//                }
                
                Group
                {
                    NavigationLink(destination: ArtistAlbumsExpandedView(sortedAlbums, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral))
                    {
                        HStack
                        {
                            Text("Albums")
                                .font(.title2)
                                .fontWeight(.bold)
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color.gray)
                                .bold()
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                    
                    ScrollView(.horizontal)
                    {
                        HStack
                        {
                            if let albums = self.albums
                            {
                                if albums.count > 8
                                {
                                    ForEach(0..<8)
                                    { i in
                                        NavigationLink(destination: AlbumDetailView(albums[i], songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral))
                                        {
                                            ArtistAlbumCell(artwork: albums[i].artwork, title: albums[i].title, releaseDate: albums[i].releaseDate, contentRating: albums[i].contentRating)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                else
                                {
                                    ForEach(albums, id: \.self)
                                    { album in
                                        NavigationLink(destination: AlbumDetailView(album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral))
                                        {
                                            ArtistAlbumCell(artwork: album.artwork, title: album.title, releaseDate: album.releaseDate, contentRating: album.contentRating)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollIndicators(.hidden)
                }
                //.offset(y: geometry.size.width * 0.33)
            }
            .navigationTitle(artist.name)
            .task
            {
                try? await loadAlbums()
            }
//            .task
//            {
//                try? await loadFeaturedAlbums()
//            }
        }
    }
    
    private func loadAlbums() async throws
    {
        let detailedArtist = try await artist.with([.albums])
        await update(albums: detailedArtist.albums)
    }
    
    /// Safely updates `albums` properties on the main thread.
    @MainActor
    private func update(albums: MusicItemCollection<Album>?)
    {
        withAnimation
        {
            self.albums = albums
            
            if self.albums != nil
            {
                for album in self.albums!
                {
                    if album.releaseDate == nil
                    {
                        //foundNilReleaseDate = true
                        print("Found nil release date")
                        self.sortedAlbums = self.albums!.sorted
                        {
                            $0.title < $1.title
                        }
                        return
                    }
                }

                self.sortedAlbums = self.albums!.sorted
                {
                    $0.releaseDate! > $1.releaseDate!
                }
            }
        }
    }
    
//    private func loadFeaturedAlbums() async throws
//    {
//        let detailedArtist = try await artist.with([.featuredAlbums])
//        await update(featuredAlbums: detailedArtist.featuredAlbums)
//    }
//
//    /// Safely updates `featuredAlbums` properties on the main thread.
//    @MainActor
//    private func update(featuredAlbums: MusicItemCollection<Album>?)
//    {
//        //var foundNilReleaseDate: Bool = false
//
//        withAnimation
//        {
//            self.featuredAlbums = featuredAlbums
//
////            if self.featuredAlbums != nil
////            {
////                for album in self.featuredAlbums!
////                {
////                    if album.releaseDate == nil
////                    {
////                        //foundNilReleaseDate = true
////                        return
////                    }
////                }
////
////                self.sortedFeaturedAlbums = self.featuredAlbums!.sorted
////                {
////                    $0.releaseDate! > $1.releaseDate!
////                }
////            }
//        }
//    }
}

//struct ArtistDetailView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        ArtistDetailView()
//    }
//}
