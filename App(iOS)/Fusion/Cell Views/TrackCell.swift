//
//  TrackCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/9/23.
//

import MusicKit
import SwiftUI

/// `TrackCell` is a view to use in a SwiftUI `List` to represent a `Track`.
struct TrackCell: View
{
    // MARK: - Object lifecycle
    
    init(_ track: Track, from album: Album, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, action: @escaping () -> Void)
    {
        self.track = track
        self.album = album
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.action = action
    }
    
    // MARK: - Properties
    
    let track: Track
    let album: Album
    let action: () -> Void
    
    private var subtitle: String
    {
        var subtitle = ""
        if track.artistName != album.artistName
        {
            subtitle = track.artistName
        }
        return subtitle
    }
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @State private var isDuplicate = false
    
    //let song: Song?
    
//    let songs100 = ["1065973702", "1065973704", "1065973705", "1065973706", "1065973707", "1065973708", "1065973709", "1065973710", "1065973711", "1065973712", "1065975634", "1065975635", "1065975636", "1065975637", "1065975638", "1065976152", "1065976153", "1065976154", "1065976155", "1065976159", "1065976160", "1065976161", "1065976162", "1065976163", "1065976164", "1065976165", "1065976166", "1065976167", "1065976170", "1065976171", "1065976172", "1065976173", "1065976174", "1065976175", "1065976176", "1065976177", "1065973977", "1065973978", "1065973979", "1065973980", "1065973981", "1065975104", "1065975105", "1065975107", "1065975108", "1065975109", "1065976564", "1065976566", "1065976567", "1065976568", "1065976569", "1065976570", "1065976901", "1065976902", "1065976903", "1065976906", "1065976907", "1065973615", "1065973616", "1065973617", "1065973618", "1065973619", "1065973623", "1065974934", "1065974935", "1065974936", "1065974937", "1065974938", "1065974940", "1065974941", "1065974942", "1065974943", "1065974944", "1065974945", "1065977146", "1065977147", "1065977150", "1065977151", "1065977152", "1065977153", "1065977154", "1065977155", "1065977156", "1065977160", "1065977161", "1065977162", "1065977163", "1065974497", "1065974498", "1065974499", "1065974500", "1065974591", "1065974592", "1065974593", "1065974594", "1065974595", "1065974596", "1065974597", "1490675343", "1490675344"]
    
    // MARK: - View
    
    var body: some View
    {
        Button(action: action)
        {
            HStack
            {
                if let trackNumber = track.trackNumber
                {
                    Text("\(trackNumber)")
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        //.padding(.trailing)
                        .frame(width: 30.0)
                }
                
                MusicItemCell(
                    artwork: nil,
                    title: track.title,
                    subtitle: subtitle
                )
                //.frame(minHeight: 50)
                
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
//                    Button(action: addAllSongsToQueueLast)
//                    {
//                        Text("Add songs")
//                    }
                }
            label:
                {
                    Label("", systemImage: "ellipsis")
                }
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
    
    func addSongToQueueNext()
    {
        Task
        {
            let song: Song? = await fetchSong(with: track.id.description)
            
            if song == nil
            {
                return
            }
            
            isDuplicate = false
            isDuplicate = checkForDuplicateSong(song: song!)
            
            if isDuplicate
            {
                return
            }
            
            print("No duplicate here.")
            
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
            songsQueue.queueNext = true
            
            if songsQueue.songArray.isEmpty
            {
                songsQueue.songArray.append(song)
            }
            else
            {
                songsQueue.songArray.insert(song, at: 0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
            {
                printPlayerQueueEntries()
            }
            print("The song id: \(song!.id)")
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
                try await ApplicationMusicPlayer.shared.queue.insert(song!, position: .afterCurrentEntry)
            }
        }
    }
    
    func addSongToQueueLast()
    {
        Task
        {
            let song: Song? = await fetchSong(with: track.id.description)
            
            if song == nil
            {
                return
            }
            
            isDuplicate = false
            isDuplicate = checkForDuplicateSong(song: song!)
            
            if isDuplicate
            {
                return
            }
            
            print("No duplicate here.")
            
            songsQueue.queueLast = true
            
            //ApplicationMusicPlayer.shared.queue.entries.append(MusicPlayer.Queue.Entry(song))
            songsQueue.songArray.append(song)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
            {
                printPlayerQueueEntries()
            }
            
            Task
            {
                try await ApplicationMusicPlayer.shared.queue.insert(song!, position: .tail)
            }
            
//            var songIdArray: [String] = []
//            for song in songsQueue.songArray
//            {
//                if let song = song
//                {
//                    songIdArray.append(song.id.description)
//                }
//            }
//            print("songIdArray(\(songIdArray.count)): \(songIdArray)")
        }
    }
    
//    func addAllSongsToQueueLast()
//    {
//        Task
//        {
//            for id in songs100
//            {
//                let song: Song? = await fetchSong(with: id)
//
//                if song == nil
//                {
//                    return
//                }
//
//                isDuplicate = false
//                isDuplicate = checkForDuplicateSong(song: song!)
//
//                if isDuplicate
//                {
//                    return
//                }
//
//                print("No duplicate here.")
//
//                songsQueue.queueLast = true
//
//                //ApplicationMusicPlayer.shared.queue.entries.append(MusicPlayer.Queue.Entry(song))
//                songsQueue.songArray.append(song)
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
//                {
//                    printPlayerQueueEntries()
//                }
//
//                Task
//                {
//                    try await ApplicationMusicPlayer.shared.queue.insert(song!, position: .tail)
//                }
//            }
//
////            var songIdArray: [String] = []
////            for song in songsQueue.songArray
////            {
////                if let song = song
////                {
////                    songIdArray.append(song.id.description)
////                }
////            }
////            print("songIdArray(\(songIdArray.count)): \(songIdArray)")
//        }
//    }
    
    func printPlayerQueueEntries()
    {
        print("Test: \(ApplicationMusicPlayer.shared.queue.entries)")
        if !ApplicationMusicPlayer.shared.queue.entries.isEmpty
        {
            print("Test:\nTitle: \(ApplicationMusicPlayer.shared.queue.entries[0].title)")
            print("Artist: \(ApplicationMusicPlayer.shared.queue.entries[0].subtitle ?? "N/A")")
        }
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
}

//struct TrackCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        TrackCell()
//    }
//}
