//
//  LibrarySongsView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/31/23.
//

import SwiftUI
import MusicKit

struct LibrarySongsView: View
{
    init(_ songs: [MusicItemCollection<Song>.Element]?, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User)
    {
        self.songs = songs
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
    }
    
    let songs: [MusicItemCollection<Song>.Element]?
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    var body: some View
    {
        if self.songs != nil
        {
            ZStack
            {
                BackgroundView(user: user, songsQueue: songsQueue)
                
                ScrollView
                {
                    //playShuffleButtonRow
                    
                    LazyVStack
                    {
                        //playShuffleButtonRow
                        
                        ForEach(songs!, id: \.self)
                        { song in
                            LibrarySongCell(song: song, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral)
                                .padding(.horizontal)
                            Divider()
                        }
                    }
                    .background(Color.gray.opacity(0.25))
                    .cornerRadius(6)
                    .padding(.horizontal)
                }
                .navigationTitle("Songs")
            }
        }
    }
    
    private var playShuffleButtonRow: some View
    {
        HStack
        {
            Button(action: handlePlayButtonSelected)
            {
                HStack
                {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .frame(maxWidth: 200)
            }
            .buttonStyle(.prominent)
            
//            Button(action: handleShuffleButtonSelected)
//            {
//                HStack
//                {
//                    Image(systemName: "shuffle")
//                    Text("Shuffle")
//                }
//                .frame(maxWidth: 200)
//            }
//            .buttonStyle(.prominent)
        }
    }
    
    private func handlePlayButtonSelected()
    {
        var i = 0
        var tempSongArrayPre: [Song] = []
        var tempSongArray: [Song] = []
        
        if let songs = songs
        {
            songsQueue.standbySongs = songs
        }
        else
        {
            return
        }
        
        for _ in songs!
        {
            if songsQueue.standbySongs.isEmpty
            {
                break
            }
            
            tempSongArrayPre.append(songsQueue.standbySongs.removeFirst())
            
            i += 1
            if i == 10
            {
                break
            }
        }
        
        Task
        {
            for song in tempSongArrayPre
            {
                let completeAlbum = await fetchCompleteAlbum(from: song)
                
                if let completeAlbumTracks = completeAlbum?.tracks, let trackNumber = song.trackNumber
                {
                    let trackIndex = trackNumber - 1
                    
                    let song: Song? = await fetchSong(with: completeAlbumTracks[trackIndex].id.description)
                    if song == nil
                    {
                        return
                    }
                    
                    let isDuplicate = checkForDuplicateSong(song: song!)
                    if isDuplicate
                    {
                        return
                    }
                    
                    tempSongArray.append(song!)
                }
            }
            
            for song in tempSongArray
            {
                songsQueue.queueLast = true
                songsQueue.songArray.append(song)
                
//                Task
//                {
//                    try await ApplicationMusicPlayer.shared.queue.insert(song, position: .tail)
//                }
                try await ApplicationMusicPlayer.shared.queue.insert(song, position: .tail)
            }
        }
    }
    
    private func handleShuffleButtonSelected()
    {
        
    }
    
    func checkForDuplicateSong(song: Song) -> Bool
    {
        var isDuplicate = false
        
        if songsQueue.history.contains(song) || songsQueue.currentSong == song || songsQueue.songArray.contains(song)
        {
            print("Song is here!")
            isDuplicate = true
        }
        
        return isDuplicate
    }
    
    func fetchCompleteAlbum(from song: Song) async -> Album?
    {
        guard let albumTitle = song.albumTitle else { return nil}
        
        let albumRequest = MusicCatalogSearchRequest(term: "\(albumTitle) \(song.artistName)", types: [Album.self])
        let albumResponse = try? await albumRequest.response()
        
        if let albumResponse = albumResponse
        {
            for album in albumResponse.albums
            {
                if album.title == albumTitle && album.artistName == song.artistName
                {
                    print("Found Complete Album: \(album)")
                    // Keepeye
                    return try? await album.with([.tracks])
                }
            }
        }
//        if let album = albumResponse?.albums.first
//        {
//            print("Found Complete Album: \(album)")
//            print(albumResponse?.albums.count)
//            // Keepeye
//            return try? await album.with([.tracks])
//        }
        
        print("Could not find complete album")
        return nil
    }
    
    func fetchSong(with id: String) async -> Song?
    {
        let songRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(rawValue: id))
        //let libraryRequest = MusicLibraryRequest<Song>().filter(matching: \.id, equalTo: MusicItemID(rawValue: id))
        //var libraryRequest = MusicLibraryRequest<Song>().filter(matching: \.id, equalTo: MusicItemID(rawValue: id))
        let libraryRequest = MusicLibraryRequest<Song>()
        var filteredRequest = libraryRequest
        filteredRequest.filter(matching: \.id, equalTo: MusicItemID(rawValue: id))
        // 1067444894
        // 1065973707
        
        let songResponse = try? await songRequest.response()
        if let song = songResponse?.items.first
        {
            print("Found \(song).")
            //return song.title
            return song
        }
        
        let filteredRequestResponse = try? await filteredRequest.response()
        if let song = filteredRequestResponse?.items.first
        {
            print("Found \(song).")
            //return song.title
            return song
        }
        
        print("Could not find song.")
        //return "Could not find song."
        return nil
    }
}

//struct LibrarySongsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LibrarySongsView()
//    }
//}
