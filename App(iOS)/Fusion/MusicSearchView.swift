//
//  MusicSearchView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/20/23.
//

import MusicKit
import SwiftUI

struct MusicSearchView: View
{
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var songsQueue: SongsQueue
    
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    @ObservedObject var bluetoothCentral: BluetoothCentral
    
    var body: some View
    {
        NavigationStack
        {
            VStack
            {
                Picker("", selection: $selectedSearchFilter)
                {
                    ForEach(searchFilters, id: \.self)
                    {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                
                searchResultsList
                    .animation(.default, value: albums)
            }
        }
        .searchable(text: $searchTerm, prompt: selectedSearchFilter)
        .onChange(of: searchTerm, perform: requestUpdatedSearchResults)
        .onChange(of: selectedSearchFilter)
        { _ in
            searchTerm = ""
        }
    }
    
    // MARK: - Search results requesting
    
    /// The current search term the user enters.
    @State private var searchTerm = ""
    
    /// The albums the app loads using MusicKit that match the current search term.
    @State private var albums: MusicItemCollection<Album> = []
    
    /// The artists the app loads using MusicKit that match the current search term.
    @State private var artists: MusicItemCollection<Artist> = []
    
    /// The songs the app loads using MusicKit that match the current search term.
    @State private var songs: MusicItemCollection<Song> = []
    
    var searchFilters = ["Albums", "Artists", "Songs"]
    @State private var selectedSearchFilter = "Albums"
    
    /// A list of albums, artists, or songs to display below the search bar.
    private var searchResultsList: some View
    {
        switch selectedSearchFilter
        {
        case "Albums":
            return AnyView(List(albums)
            { album in
                AlbumCell(album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral)
            })
        case "Artists":
            return AnyView(List(artists)
            { artist in
                ArtistCell(artist, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral)
            })
        case "Songs":
            return AnyView(List(songs)
            { song in
                SongCell(songsQueue: songsQueue, song, bluetoothPeripheral: bluetoothPeripheral)
                    //.disabled(true)
                    .buttonStyle(BorderlessButtonStyle())
            })
        default:
            return AnyView(Text("searchResultsList error"))
        }
    }
    
    /// Makes a new search request to MusicKit when the current search term changes.
    private func requestUpdatedSearchResults(for searchTerm: String)
    {
        Task
        {
            if searchTerm.isEmpty
            {
                self.reset()
            }
            else
            {
                do
                {
                    switch selectedSearchFilter
                    {
                    case "Albums":
                        // Issue a catalog search request for albums matching the search term.
                        var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Album.self])
                        
                        searchRequest.limit = 5
                        let searchResponse = try await searchRequest.response()
                        
                        // Update the user interface with the search response.
                        self.apply(searchResponse, for: searchTerm)
                    case "Artists":
                        // Issue a catalog search request for artists matching the search term.
                        var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Artist.self])
                        
                        searchRequest.limit = 5
                        let searchResponse = try await searchRequest.response()
                        
                        // Update the user interface with the search response.
                        self.apply(searchResponse, for: searchTerm)
                    case "Songs":
                        // Issue a catalog search request for songs matching the search term.
                        var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Song.self])
                        
                        searchRequest.limit = 5
                        let searchResponse = try await searchRequest.response()
                        
                        // Update the user interface with the search response.
                        self.apply(searchResponse, for: searchTerm)
                    default:
                        // Issue a catalog search request for albums matching the search term.
                        var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Album.self])
                        
                        searchRequest.limit = 5
                        let searchResponse = try await searchRequest.response()
                        
                        // Update the user interface with the search response.
                        self.apply(searchResponse, for: searchTerm)
                    }
                }
                catch
                {
                    print("Search request failed with error: \(error).")
                    self.reset()
                }
            }
        }
    }
    
    /// Safely updates the `albums`, `artists` or `songs` property on the main thread.
    @MainActor
    private func apply(_ searchResponse: MusicCatalogSearchResponse, for searchTerm: String)
    {
        if self.searchTerm == searchTerm
        {
            switch selectedSearchFilter
            {
            case "Albums":
                self.albums = searchResponse.albums
            case "Artists":
                self.artists = searchResponse.artists
            case "Songs":
                self.songs = searchResponse.songs
            default:
                self.albums = searchResponse.albums
            }
            
        }
    }
    
    /// Safely resets the `albums`, `artists`, & `songs` property on the main thread.
    @MainActor
    private func reset()
    {
        self.albums = []
        self.artists = []
        self.songs = []
    }
}

struct MusicSearchView_Previews: PreviewProvider
{
    static var previews: some View
    {
        MusicSearchView(songsQueue: SongsQueue.shared, bluetoothPeripheral: BluetoothPeripheral(), user: User(), bluetoothCentral: BluetoothCentral())
    }
}
