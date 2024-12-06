//
//  MusicControlsView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/19/23.
//

import MusicKit
import SwiftUI

struct MusicControlsView: View
{
    @ObservedObject var songsQueue: SongsQueue
    
    @ObservedObject var bluetoothCentral: BluetoothCentral
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    @ObservedObject var playerSharedQueue = ApplicationMusicPlayer.shared.queue
    
    //@State private var song: Song? = nil
    
    @State private var ceDuplicateCheckerID: String = ""
    
    @State private var endingEntry: Bool = false
    
    var body: some View
    {
        VStack
        {
            if songsQueue.currentSong != nil
            {
                HStack
                {
                    NowPlayingMusicItemCell(
                        artwork: songsQueue.currentSong?.artwork,
                        title: songsQueue.currentSong?.title ?? "N/A",
                        subtitle: songsQueue.currentSong?.artistName ?? "N/A",
                        user: user
                    )
                    
                    Spacer()
                }
            }
            else
            {
                NowPlayingEmptyMusicItemCell(user: user)
            }
            
            Spacer()
            //Spacer()
            
            HStack
            {
                Spacer()
                
                Button(action: replaySong)
                {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundColor(user.appearance == "Light" ? .black : .white)
                }
                .disabled(bluetoothPeripheral.isPeering && !bluetoothPeripheral.permissions.contains("R"))
                
                Spacer()
                
                Button(action: playAndPauseSong)
                {
                    if bluetoothPeripheral.isPeering
                    {
                        Image(systemName: (bluetoothPeripheral.hostIsPlaying ? "pause.fill" : "play.fill"))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .foregroundColor(user.appearance == "Light" ? .black : .white)
                    }
                    else
                    {
                        Image(systemName: (isPlaying ? "pause.fill" : "play.fill"))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .foregroundColor(user.appearance == "Light" ? .black : .white)
                    }
                }
                .disabled(bluetoothPeripheral.isPeering && !bluetoothPeripheral.permissions.contains("P"))
                
                Spacer()
                
                Button(action: skipSong)
                {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundColor(user.appearance == "Light" ? .black : .white)
                }
                .disabled(bluetoothPeripheral.isPeering && !bluetoothPeripheral.permissions.contains("S"))
                
                Spacer()
            }
            .frame(height: 30)
            
            Spacer()
            //Spacer()
        }
        .onChange(of: playerState.playbackStatus)
        { _ in
            print("isPlaying == \(isPlaying)")
            if bluetoothCentral.isHosting
            {
                bluetoothCentral.textUpdated = true
                switch isPlaying
                {
                case true:
                    bluetoothCentral.text = "Play"
//                    for peri in bluetoothCentral.connectedPeripherals
//                    {
//                        for tc in bluetoothCentral.transferCharacteristics
//                        {
//                            peri.key.writeValue("Play".data(using: .utf8)!, for: tc, type: .withoutResponse)
//                        }
//                    }
                    print("Player is playing.")
                case false:
                    bluetoothCentral.text = "Pause"
//                    for peri in bluetoothCentral.connectedPeripherals
//                    {
//                        for tc in bluetoothCentral.transferCharacteristics
//                        {
//                            peri.key.writeValue("Pause".data(using: .utf8)!, for: tc, type: .withoutResponse)
//                        }
//                    }
                    print("Player is NOT playing.")
                }
            }
        }
        .onChange(of: bluetoothCentral.text)
        { newValue in
            print("bcText newValue == \(newValue ?? "error")")
            print("bcTextUpdated == \(bluetoothCentral.textUpdated)")
            if newValue == "Play" || newValue == "Pause"
            {
                print("This happened.")
                if bluetoothCentral.textUpdated
                {
                    bluetoothCentral.textUpdated = false
                }
                else
                {
                    playAndPauseSong()
                }
            }
            else if newValue == "Skip"
            {
                skipSong()
            }
            else if newValue == "Rewind"
            {
                replaySong()
            }
            
            bluetoothCentral.text = ""
        }
        .onChange(of: bluetoothPeripheral.text)
        { newValue in
            print("bpText newValue == \(newValue ?? "error")")
            if newValue == "Play" || newValue == "Pause"
            {
                print("This happened 2.")
                switch newValue
                {
                case "Play":
                    bluetoothPeripheral.hostIsPlaying = true
                case "Pause":
                    bluetoothPeripheral.hostIsPlaying = false
                default:
                    print("This should never execute.")
                }
                
                //playAndPauseSong()
            }
        }
        .onChange(of: ApplicationMusicPlayer.shared.queue.entries.count)
        { newValue in
            print("player.queue count: \(newValue)")
        }
        .onChange(of: ApplicationMusicPlayer.shared.queue.currentEntry)
        { newValue in
            // This prevents the .onChange from executing more than it should
            if newValue?.id.description == ceDuplicateCheckerID
            {
                return
            }
            ceDuplicateCheckerID = newValue?.id.description ?? "ce nil"
            print("Current Entry changed. (Music Controls)")
            print("newValue == \(newValue?.title ?? "stupid")")
            
            if !songsQueue.currentEntryChangedFromInApp
            {
                if let songID = newValue?.item?.id.description
                {
                    print("print(songID: \(songID))")
                    songsQueue.currentEntryChangedFromControlCenter = true
                    
                    if newValue?.item?.id != songsQueue.currentSong?.id && songsQueue.songArray.isEmpty && newValue?.item?.id != songsQueue.history.last??.id
                    {
                        ApplicationMusicPlayer.shared.queue.currentEntry = ApplicationMusicPlayer.shared.queue.entries.last
                        
//                        if let duration = songsQueue.currentSong?.duration
//                        {
//                            ApplicationMusicPlayer.shared.playbackTime = duration
//                        }
                        
                        songsQueue.currentEntryChangedFromControlCenter = false
                        return
                    }
//                    if songsQueue.songArray.isEmpty && newValue?.item?.id != songsQueue.currentSong?.id && endingEntry == false
//                    {
//                        endingEntry = true
//
//                        Task
//                        {
//                            while newValue?.item?.id != songsQueue.currentSong?.id
//                            {
//                                try await ApplicationMusicPlayer.shared.skipToNextEntry()
//                            }
//
//                            if let duration = songsQueue.currentSong?.duration
//                            {
//                                ApplicationMusicPlayer.shared.playbackTime = duration
//                            }
//
//                            songsQueue.currentEntryChangedFromControlCenter = false
//                            return
//                        }
//                    }
                    
                    if songID == songsQueue.history.last??.id.description
                    {
                        replaySong()
                    }
                    else if songID == songsQueue.songArray.first??.id.description
                    {
                        skipSong()
                    }
                    else
                    {
                        songsQueue.currentEntryChangedFromControlCenter = false
                        print("Ahh lookie here!")
                    }
                }
            }
            else
            {
                songsQueue.currentEntryChangedFromInApp = false
            }
            
            if !songsQueue.standbySongs.isEmpty
            {
                let tempSongPre: Song = songsQueue.standbySongs.removeFirst()
                var tempSong: Song?
                
                Task
                {
                    let completeAlbum = await fetchCompleteAlbum(from: tempSongPre)
                    
                    if let completeAlbumTracks = completeAlbum?.tracks, let trackNumber = tempSongPre.trackNumber
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
                        
                        tempSong = song!
                    }
                    else
                    {
                        return
                    }
                    
                    songsQueue.queueLast = true
                    songsQueue.songArray.append(tempSong!)
                    
                    Task
                    {
                        try await ApplicationMusicPlayer.shared.queue.insert(tempSong!, position: .tail)
                    }
                }
            }
            
            //bluetoothCentral.queueImportedArray = []
        }
//        .onChange(of: playerSharedQueue.currentEntry)
//        { newValue in
//            print("Current Entry changed. (Music Controls)xxx")
//            print("newValue == \(newValue?.title ?? "stupid")")
//        }
//        .onReceive(ApplicationMusicPlayer.shared.queue.objectWillChange)
//        {
//
//        }
//        .onReceive(ApplicationMusicPlayer.shared.queue.currentEntry.publisher)
//        { _ in
//            print(".onReceive currentEntry publisher")
//            print(ApplicationMusicPlayer.shared.queue.currentEntry?.title ?? "nothing here")
//        }
    }
    
    // MARK: - Playback
    
    /// The MusicKit player to use for Apple Music playback.
    private let player = ApplicationMusicPlayer.shared
    
    /// The state of the MusicKit player to use for Apple Music playback.
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    
    /// `true` when the content view sets a playback queue on the player.
    @State private var isPlaybackQueueSet = false
    
    /// `true` when the player is playing.
    private var isPlaying: Bool
    {
        return (playerState.playbackStatus == .playing)
    }
    
    /// The action to perform when the user taps the Play/Pause button.
    private func handlePlayButtonSelected()
    {
        if !isPlaying
        {
            if !isPlaybackQueueSet
            {
                isPlaybackQueueSet = true
                beginPlaying()
            }
            else
            {
                Task
                {
                    do
                    {
                        try await player.play()
                    }
                    catch
                    {
                        print("Failed to resume playing with error: \(error).")
                    }
                }
            }
        }
        else
        {
            player.pause()
        }
    }
    
    /// A convenience method for beginning music playback.
    ///
    /// Call this instead of `MusicPlayer`’s `play()`
    /// method whenever the playback queue is reset.
    private func beginPlaying()
    {
        Task
        {
            do
            {
                try await player.play()
            }
            catch
            {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
    
    func loadNextSong()
    {
        if !songsQueue.songArray.isEmpty
        {
            songsQueue.currentSong = songsQueue.songArray.remove(at: 0)
            //player.queue = ApplicationMusicPlayer.Queue(arrayLiteral: songsQueue.currentSong!)
            //player.queue.currentEntry = player.queue.entries.removeFirst()
            //player.queue.currentEntry = ApplicationMusicPlayer.Queue.Entry(songsQueue.currentSong!)
            //player.queue = ApplicationMusicPlayer.Queue(player.queue.entries)
            
            printPlayerQueueEntries()
            
            if bluetoothCentral.isHosting
            {
                var textArray: [String] = []
                var songIdString = "AddNP"
                
                if let song = songsQueue.currentSong
                {
                    songIdString.append(song.id.description)
                    textArray = [songIdString]
                    
                    for peri in bluetoothCentral.connectedPeripherals.keys
                    {
                        for tc in bluetoothCentral.transferCharacteristics
                        {
                            if tc.service?.peripheral?.identifier != peri.identifier
                            {
                                continue
                            }
                            
                            let data = try! JSONEncoder().encode(textArray)
                            peri.writeValue(data, for: tc, type: .withoutResponse)
                            
                            break
                        }
                    }
                    
                    textArray = []
                    songIdString = "AddNP"
                }
            }
        }
    }
    
    func replaySong()
    {
        if songsQueue.currentSong == nil
        {
            return
        }
        
        if bluetoothPeripheral.isPeering
        {
            bluetoothPeripheral.updateText(with: "Rewind")
            return
        }
        
        if songsQueue.history.isEmpty
        {
            player.playbackTime = 0
        }
        else
        {
            //player.playbackTime = 0
            
            songsQueue.songArray.insert(songsQueue.currentSong, at: 0)
            songsQueue.currentSong = songsQueue.history.removeLast()
            
            if !songsQueue.currentEntryChangedFromControlCenter
            {
                Task
                {
                    try await ApplicationMusicPlayer.shared.skipToPreviousEntry()
                    songsQueue.currentEntryChangedFromInApp = true
                }
            }
            else
            {
                songsQueue.currentEntryChangedFromControlCenter = false
            }
            
//            if isPlaying
//            {
//                songsQueue.songArray.insert(songsQueue.currentSong, at: 0)
//                player.stop()
//                songsQueue.currentSong = songsQueue.history.removeLast()
//                player.queue = ApplicationMusicPlayer.Queue(arrayLiteral: songsQueue.currentSong!)
//
//                Task
//                {
//                    do
//                    {
//                        try await player.play()
//                    }
//                    catch
//                    {
//                        print("Failed to resume playing with error: \(error).")
//                    }
//                }
//            }
//            else
//            {
//                songsQueue.songArray.insert(songsQueue.currentSong, at: 0)
//                player.stop()
//                songsQueue.currentSong = songsQueue.history.removeLast()
//                player.queue = ApplicationMusicPlayer.Queue(arrayLiteral: songsQueue.currentSong!)
//            }
        }
        
        if bluetoothCentral.isHosting
        {
            var textArray: [String] = []
            var songIdString = "AddPS"
            
            if let song = songsQueue.currentSong
            {
                songIdString.append(song.id.description)
                textArray = [songIdString]
                
                for peri in bluetoothCentral.connectedPeripherals.keys
                {
                    for tc in bluetoothCentral.transferCharacteristics
                    {
                        if tc.service?.peripheral?.identifier != peri.identifier
                        {
                            continue
                        }
                        
                        let data = try! JSONEncoder().encode(textArray)
                        peri.writeValue(data, for: tc, type: .withoutResponse)
                        
                        break
                    }
                }
                
                textArray = []
                songIdString = "AddPS"
            }
        }
        
        //bluetoothCentral.queueImportedArray = []
    }
    
    func playAndPauseSong()
    {
        if bluetoothPeripheral.isPeering
        {
            if songsQueue.currentSong == nil && songsQueue.songArray.isEmpty
            {
                return
            }
            
            print("hostIsPlaying == \(bluetoothPeripheral.hostIsPlaying)")
            switch bluetoothPeripheral.hostIsPlaying
            {
            case true:
                bluetoothPeripheral.updateText(with: "Pause")
            case false:
                bluetoothPeripheral.updateText(with: "Play")
            }
        }
        else
        {
            if songsQueue.currentSong == nil && songsQueue.songArray.isEmpty
            {
                return
            }
            else if songsQueue.currentSong == nil
            {
                //return
                loadNextSong()
                player.queue = ApplicationMusicPlayer.Queue(player.queue.entries)
                //print("-.- player.queue set -.-")
            }
            if !isPlaying
            {
                Task
                {
                    do
                    {
                        try await player.play()
                    }
                    catch
                    {
                        print("Failed to resume playing with error: \(error).")
                    }
                }
            }
            else
            {
                player.pause()
            }
        }
        
//        if bluetoothCentral.isHosting
//        {
//            switch isPlaying
//            {
//            case true:
//                //bluetoothCentral.text = "Play"
//                for peri in bluetoothCentral.connectedPeripherals
//                {
//                    for tc in bluetoothCentral.transferCharacteristics
//                    {
//                        peri.key.writeValue("Play".data(using: .utf8)!, for: tc, type: .withoutResponse)
//                    }
//                }
//                print("Player is playing.")
//            case false:
//                //bluetoothCentral.text = "Pause"
//                for peri in bluetoothCentral.connectedPeripherals
//                {
//                    for tc in bluetoothCentral.transferCharacteristics
//                    {
//                        peri.key.writeValue("Pause".data(using: .utf8)!, for: tc, type: .withoutResponse)
//                    }
//                }
//                print("Player is NOT playing.")
//            }
//        }
    }
    
    func skipSong()
    {
        if songsQueue.currentSong == nil
        {
            return
        }
        
        if bluetoothPeripheral.isPeering
        {
            bluetoothPeripheral.updateText(with: "Skip")
            return
        }
        
        if songsQueue.songArray.isEmpty
        {
            if playerState.playbackStatus == .playing
            {
                player.pause()
            }
            
            ApplicationMusicPlayer.shared.queue.currentEntry = ApplicationMusicPlayer.shared.queue.entries.first
            return
        }
        
        songsQueue.history.append(songsQueue.currentSong)
        
        if bluetoothCentral.isHosting
        {
            var textArray: [String] = []
            var songIdString = "AddH"
            
            if let song = songsQueue.currentSong
            {
                songIdString.append(song.id.description)
                textArray = [songIdString]
                
                for peri in bluetoothCentral.connectedPeripherals.keys
                {
                    for tc in bluetoothCentral.transferCharacteristics
                    {
                        if tc.service?.peripheral?.identifier != peri.identifier
                        {
                            continue
                        }
                        
                        let data = try! JSONEncoder().encode(textArray)
                        peri.writeValue(data, for: tc, type: .withoutResponse)
                        
                        break
                    }
                }
                
                textArray = []
                songIdString = "AddH"
            }
        }
        
        if songsQueue.songArray.isEmpty
        {
            player.stop()
            //songsQueue.songArray = songsQueue.history
            //songsQueue.history = []
            //loadNextSong()
            
            songsQueue.currentSong = nil
            
            if bluetoothCentral.isHosting
            {
                let textArray: [String] = ["ClearNP"]
                
                for peri in bluetoothCentral.connectedPeripherals.keys
                {
                    for tc in bluetoothCentral.transferCharacteristics
                    {
                        if tc.service?.peripheral?.identifier != peri.identifier
                        {
                            continue
                        }
                        
                        let data = try! JSONEncoder().encode(textArray)
                        peri.writeValue(data, for: tc, type: .withoutResponse)
                        
                        break
                    }
                }
            }
        }
        else
        {
            //player.playbackTime = 0
            
            loadNextSong()
            
            if !songsQueue.currentEntryChangedFromControlCenter
            {
                Task
                {
                    try await ApplicationMusicPlayer.shared.skipToNextEntry()
                    songsQueue.currentEntryChangedFromInApp = true
                }
            }
            else
            {
                songsQueue.currentEntryChangedFromControlCenter = false
            }
            
//            if isPlaying
//            {
//                Task
//                {
//                    do
//                    {
//                        try await player.play()
//                    }
//                    catch
//                    {
//                        print("Failed to resume playing with error: \(error).")
//                    }
//                }
//            }
            
        }
        
        
//        Task
//        {
//            do
//            {
//                try await player.skipToNextEntry()
//            }
//            catch
//            {
//                print("Failed to resume playing with error: \(error).")
//            }
//        }
        
        //bluetoothCentral.queueImportedArray = []
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

struct MusicControlsView_Previews: PreviewProvider
{
    static var previews: some View
    {
        MusicControlsView(songsQueue: SongsQueue.shared, bluetoothCentral: BluetoothCentral(), bluetoothPeripheral: BluetoothPeripheral(), user: User())
    }
}
