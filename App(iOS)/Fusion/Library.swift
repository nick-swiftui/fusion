//
//  Library.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/27/23.
//

import Foundation
import MusicKit

class Library: ObservableObject
{
    @Published var albums: [MusicItemCollection<Album>.Element] = []
    @Published var artists: [MusicItemCollection<Artist>.Element] = []
    @Published var songs: [MusicItemCollection<Song>.Element] = []
    @Published var playlists: [MusicItemCollection<Playlist>.Element] = []
    
    @Published var recentlyAddedAlbums: [MusicItemCollection<Album>.Element] = []
    
    init()
    {
        fetchAlbums()
        fetchArtists()
        fetchSongs()
        fetchPlaylists()
    }
    
    func fetchAlbums()
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
                    
                    let tempRecentlyAddedAlbums = tempAlbums.sorted(by: {$0.libraryAddedDate ?? Date(timeIntervalSince1970: 0) > $1.libraryAddedDate ?? Date(timeIntervalSince1970: 0)})
                    
                    // Use the .prefix(min(60, originalArray.count)) method to keep at most the first 60 items
                    self.recentlyAddedAlbums = Array(tempRecentlyAddedAlbums.prefix(min(60, tempRecentlyAddedAlbums.count)))
                }
            }
            catch
            {
                print("Error: \(error)")
            }
        }
    }
    
    func fetchArtists()
    {
        Task
        {
            do
            {
                // Fetching all artists in the library
                
                let request = MusicLibraryRequest<Artist>()
                let response = try await request.response()
                print("\(response)")
                
                DispatchQueue.main.async
                {
                    var tempArtists: [MusicItemCollection<Artist>.Element] = []
                    
                    print(response.items.count)
                    
                    for artist in response.items
                    {
                        tempArtists.append(artist)
                    }
                    
                    self.artists = tempArtists
                }
            }
            catch
            {
                print("Error: \(error)")
            }
        }
    }
    
    func fetchSongs()
    {
        Task
        {
            do
            {
                // Fetching all songs in the library
                
                let request = MusicLibraryRequest<Song>()
                let response = try await request.response()
                print("\(response)")
                
                DispatchQueue.main.async
                {
                    var tempSongs: [MusicItemCollection<Song>.Element] = []
                    
                    print(response.items.count)
                    
                    for song in response.items
                    {
                        tempSongs.append(song)
                    }
                    
                    self.songs = tempSongs
                }
            }
            catch
            {
                print("Error: \(error)")
            }
        }
    }
    
    func fetchPlaylists()
    {
        Task
        {
            do
            {
                // Fetching all playlists in the library
                
                let request = MusicLibraryRequest<Playlist>()
                //let request = MusicCatalogResourceReques
                let response = try await request.response()
                print("\(response)")
                
                DispatchQueue.main.async
                {
                    var tempPlaylists: [MusicItemCollection<Playlist>.Element] = []
                    
                    print(response.items.count)
                    
                    for playlist in response.items
                    {
                        tempPlaylists.append(playlist)
                    }
                    
                    self.playlists = tempPlaylists
                }
            }
            catch
            {
                print("Error: \(error)")
            }
        }
    }
}
