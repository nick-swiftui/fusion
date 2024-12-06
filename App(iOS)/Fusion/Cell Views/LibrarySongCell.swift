//
//  LibrarySongCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/31/23.
//

import SwiftUI
import MusicKit

struct LibrarySongCell: View
{
    let song: Song
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @State private var isDuplicate = false
    
    var body: some View
    {
        HStack
        {
            MusicItemCell(
                artwork: song.artwork,
                title: song.title,
                subtitle: song.artistName
            )
            .onTapGesture
            {
                print("Song ID: \(song.id.description)")
                print("SongsQueueIDs: \(songsQueue.songArray)")
                print("Song Track Number: \(song.trackNumber ?? 0)")
                print("Current Entry ID: \(ApplicationMusicPlayer.shared.queue.currentEntry?.item?.id.description ?? "n/a")")
                print("SongsQueue Song ID: \(songsQueue.songArray.first??.id.description ?? "n/a")")
                print("Entries ID:")
                for entry in ApplicationMusicPlayer.shared.queue.entries
                {
                    //print(entry.item?.id.description ?? "n/a")
                    print(entry)
                }
                if ApplicationMusicPlayer.shared.queue.currentEntry != nil
                {
                    print("Current Entry Position: \(ApplicationMusicPlayer.shared.queue.entries.firstIndex(of: ApplicationMusicPlayer.shared.queue.currentEntry!) ?? -1)")
                }
            }
            
            Spacer()
            
            Menu
            {
                Button(action: addSongToQueueNext)
                {
                    Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                .disabled(bluetoothPeripheral.isPeering && !bluetoothPeripheral.permissions.contains("QN"))
                Button(action: addSongToQueueLast)
                {
                    Label("Play Last", systemImage: "text.line.last.and.arrowtriangle.forward")
                }
                .disabled(bluetoothPeripheral.isPeering && !bluetoothPeripheral.permissions.contains("QL"))
            }
        label:
            {
                Label("", systemImage: "ellipsis")
            }
        }
        .alert(isPresented: $isDuplicate)
        {
            Alert(
                title: Text("Duplicate Song"),
                message: Text("This song already exists in the queue. Add a different song."),
                dismissButton: .default(Text("Okay"))
                {
                    isDuplicate = false
                }
            )
        }
    }
    
    // MARK: - Methods
    
    func addSongToQueueNext() //async
    {
        Task
        {
            
            
            let completeAlbum = await fetchCompleteAlbum()
            
    //        if ApplicationMusicPlayer.shared.queue.entries.isEmpty
    //        {
    //            ApplicationMusicPlayer.shared.queue.entries.append(MusicPlayer.Queue.Entry(song))
    //            //songsQueue.array.append(song.id.rawValue)
    //            songsQueue.songArray.append(song)
    //        }
    //        else
    //        {
    //            ApplicationMusicPlayer.shared.queue.entries.insert(MusicPlayer.Queue.Entry(song), at: 1)
    //            //songsQueue.array.insert(song.id.rawValue, at: 1)
    //            songsQueue.songArray.insert(song, at: 1)
    //        }
            
            if completeAlbum == nil
            {
                return
            }
            
            if let completeAlbumTracks = completeAlbum?.tracks, let trackNumber = song.trackNumber
            {
                let trackIndex = trackNumber - 1
                let track = completeAlbumTracks[trackIndex]
                let song: Song? = await fetchSong(with: track.id.description)

                if song == nil
                {
                    return
                }

                isDuplicate = false
                isDuplicate = checkForDuplicateSong(song!)

                if isDuplicate
                {
                    return
                }

                print("No duplicate here.")

                songsQueue.queueNext = true

                if songsQueue.songArray.isEmpty
                {
                    //songsQueue.songArray.append(song)
                    songsQueue.songArray.append(self.song)
                }
                else
                {
                    songsQueue.songArray.insert(song, at: 0)
                }
            }
            
//            songsQueue.queueNext = true
//            if songsQueue.songArray.isEmpty
//            {
//                songsQueue.songArray.append(song)
//            }
//            else
//            {
//                songsQueue.songArray.insert(song, at: 0)
//            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
            {
                printPlayerQueueEntries()
            }
            print("The song id: \(song.id)")
    //        for song in songsQueue.array
    //        {
    //            print(song)
    //        }
            for song in songsQueue.songArray
            {
                print(song ?? "for song in songsQueue.songArray")
            }
            
            Task
            {
                try await ApplicationMusicPlayer.shared.queue.insert(song, position: .afterCurrentEntry)
                //ApplicationMusicPlayer.shared.queue = ApplicationMusicPlayer.Queue(ApplicationMusicPlayer.shared.queue.entries)
            }
        }
    }
    
    func addSongToQueueLast()
    {
        Task
        {
            
            
            let completeAlbum = await fetchCompleteAlbum()
            
            if completeAlbum == nil
            {
                return
            }
            
            if let completeAlbumTracks = completeAlbum?.tracks, let trackNumber = song.trackNumber
            {
                let trackIndex = trackNumber - 1
                let track = completeAlbumTracks[trackIndex]
                let song: Song? = await fetchSong(with: track.id.description)
                
                if song == nil
                {
                    return
                }
                
                isDuplicate = false
                isDuplicate = checkForDuplicateSong(song!)
                
                if isDuplicate
                {
                    return
                }
                
                print("No duplicate here.")
                
                songsQueue.queueLast = true
                
                //ApplicationMusicPlayer.shared.queue.entries.append(MusicPlayer.Queue.Entry(song))
                songsQueue.songArray.append(song)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
            {
                printPlayerQueueEntries()
            }
            
            Task
            {
                try await ApplicationMusicPlayer.shared.queue.insert(song, position: .tail)
            }
        }
    }
    
    func printPlayerQueueEntries()
    {
        print("Test: \(ApplicationMusicPlayer.shared.queue.entries)")
        if !ApplicationMusicPlayer.shared.queue.entries.isEmpty
        {
            print("Test:\nTitle: \(ApplicationMusicPlayer.shared.queue.entries[0].title)")
            print("Artist: \(ApplicationMusicPlayer.shared.queue.entries[0].subtitle ?? "N/A")")
        }
    }
    
    func checkForDuplicateSong(_ song: Song) -> Bool
    {
        var isDuplicate = false
        
        if songsQueue.history.contains(song) || songsQueue.currentSong == song || songsQueue.songArray.contains(song)
        {
            print("Song is here!")
            isDuplicate = true
        }
        
        return isDuplicate
    }
    
    func fetchCompleteAlbum() async -> Album?
    {
        guard let albumTitle = self.song.albumTitle else { return nil}
        
        let albumRequest = MusicCatalogSearchRequest(term: "\(albumTitle) \(self.song.artistName)", types: [Album.self])
        let albumResponse = try? await albumRequest.response()
        
        if let albumResponse = albumResponse
        {
            for album in albumResponse.albums
            {
                if album.title == albumTitle
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

//struct LibrarySongCell_Previews: PreviewProvider {
//    static var previews: some View {
//        LibrarySongCell()
//    }
//}
