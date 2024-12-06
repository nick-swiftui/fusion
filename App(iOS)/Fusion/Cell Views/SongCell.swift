//
//  SongCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/11/23.
//

import MusicKit
import SwiftUI

/// `SongCell` is a view to use in a SwiftUI `List` to represent a `Song`.
struct SongCell: View
{
    // MARK: - Object lifecycle
    
    init(songsQueue: SongsQueue, _ song: Song, bluetoothPeripheral: BluetoothPeripheral)
    {
        self.songsQueue = songsQueue
        self.song = song
        
        self.bluetoothPeripheral = bluetoothPeripheral
    }
    
    // MARK: - Properties
    
    @ObservedObject var songsQueue: SongsQueue
    
    let song: Song
    
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @State private var isDuplicate = false
    
    // MARK: - View
    
    var body: some View
    {
        HStack
        {
            MusicItemCell(
                artwork: song.artwork,
                title: song.title,
                subtitle: song.artistName
            )
            
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
    
    func addSongToQueueNext()
    {
        isDuplicate = false
        isDuplicate = checkForDuplicateSong()
        
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
        }
    }
    
    func addSongToQueueLast()
    {
        isDuplicate = false
        isDuplicate = checkForDuplicateSong()
        
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
            try await ApplicationMusicPlayer.shared.queue.insert(song, position: .tail)
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
    
    func checkForDuplicateSong() -> Bool
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

//struct SongCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        SongCell()
//    }
//}





/*
 
 func songOptionsSelected()
 {
     print("Button tapped!")
 }
 
Button(action: songOptionsSelected)
{
    Image(systemName: "ellipsis")
}
.contextMenu
{
    Button
    {
        print("Playing Next")
    }
label:
    {
        Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
    }
}
*/
