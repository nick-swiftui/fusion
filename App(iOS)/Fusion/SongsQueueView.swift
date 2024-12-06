//
//  SongsQueueView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/11/23.
//

import MusicKit
import SwiftUI

struct SongsQueueView: View
{
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var user: User
    
    @State private var songTitle = "None selected"
    //@State private var song: Song?
    
    @State private var ctr = 0
    
    @State private var emptySongsTitleArray = ["Queue is empty."]
    
    @ObservedObject var queue = ApplicationMusicPlayer.shared.queue
    
    var body: some View
    {
        VStack
        {
            //Text(songsQueue.array.last ?? "SongsQueue.array empty")
            HStack
            {
                Text("Playing Next")
                    .font(.title3)
                    .foregroundColor(user.appearance == "Light" ? .black : .white)
                Spacer()
            }
            .padding(.leading)
            
            if !songsQueue.songArray.isEmpty
            {
                HStack
                {
                    Spacer()
                    
//                    List($queue.entries, id: \.self, editActions: .all)
//                    { $entry in
//                        HStack
//                        {
//                            MusicItemCell(
//                                artwork: entry.artwork,
//                                title: entry.title,
//                                subtitle: entry.subtitle ?? "N/A"
//                            )
//
//                            Spacer()
//
//                            Image(systemName: "line.3.horizontal")
//                        }
//                        .frame(height: 50)
//                    }
//                    .scrollContentBackground(.hidden)
                    List($songsQueue.songArray, id: \.self, editActions: .all)
                    { $song in
                        HStack
                        {
                            MusicItemCell(
                                artwork: song?.artwork,
                                title: song?.title ?? "N/A",
                                subtitle: song?.artistName ?? "N/A"
                            )

                            Spacer()

                            Image(systemName: "line.3.horizontal")
                        }
                        .frame(height: 50)
                        //.listRowBackground(Color.clear)
                        // Tried this to address list ui problem
                        //.id(song?.id)
                    }
                    //.listRowBackground(Color.red)
                    .scrollContentBackground(.hidden)
                    .onChange(of: songsQueue.songArray)
                    { newValue in
                        for song in newValue
                        {
                            print(song?.title ?? "Song is nil")
                        }
                    }
//                    List
//                    {
//                        ForEach($songsQueue.songArray, id: \.self, editActions: .all)
//                        { $song in
//                            HStack
//                            {
//                                MusicItemCell(
//                                    artwork: song?.artwork,
//                                    title: song?.title ?? "N/A",
//                                    subtitle: song?.artistName ?? "N/A"
//                                )
//
//                                Spacer()
//
//                                Image(systemName: "line.3.horizontal")
//                            }
//                            .frame(height: 50)
//                            // Tried this to address list ui problem
//                            //.id(song?.id)
//                        }
//                        .onMove(perform: move)
//                    }
//                    .onChange(of: songsQueue.songArray)
//                    { newValue in
//                        for song in newValue
//                        {
//                            print(song?.title ?? "Song is nil")
//                        }
//                    }
                    
                    Spacer()
                }
            }
            else
            {
                HStack
                {
                    Spacer()
                    
                    List($emptySongsTitleArray, id: \.self)
                    { $title in
                        HStack
                        {
                            Spacer()
                            Text(title)
                                .frame(height: 50)
                            Spacer()
                        }
                        //.listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    //.listRowBackground(.none)
                    //.listStyle(.plain)
                    //.background(Color.purple)
                    .disabled(true)
                    
                    Spacer()
                }
            }
            
            Spacer()
//            List($songsArray, id: \.self, editActions: .all)
//            { $song in
//                MusicItemCell(
//                    artwork: song?.artwork,
//                    title: song?.title ?? "N/A",
//                    subtitle: song?.artistName ?? "N/A"
//                )
//            }
//            .task
//            {
//                for songID in songsQueue.array
//                {
//                    songsArray.append(await (fetchSong(with: songID)))
//                }
//                //song = await (fetchSong(with: songID))
//                ctr += 1
//                print("Task executed count: \(ctr).")
//            }
//            .onChange(of: songsArray)
//            { newValue in
//                for song in newValue
//                {
//                    print(song?.title ?? "Song is nil")
//                }
//            }
//            Button("Tap me")
//            {
//                Task
//                {
//                    song = await fetchSong()
//                }
//            }
        }
        //.background(Color.gray)
//        .onAppear
//        {
//            Task
//            {
//                let fetchedSong = await fetchSong(with:"1452873021")
//                print(fetchedSong ?? "Couldn't fetch song")
//            }
//        }
    }
    
    func fetchSong(with id: String) async -> Song?
    {
        let songRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(rawValue: id))
        // 1067444894
        // 1065973707
        
        let songResponse = try? await songRequest.response()
        if let song = songResponse?.items.first
        {
            print("Found \(song).")
            //return song.title
            return song
        }
        print("Could not find song.")
        //return "Could not find song."
        return nil
    }
    
//    func move(from source: IndexSet, to destination: Int)
//    {
//        ApplicationMusicPlayer.shared.queue.entries.move(fromOffsets: source, toOffset: destination)
//
//        print("onMove stuff -> \(source) - \(destination)")
//    }
}

//struct SongsQueueView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        SongsQueueView(songsQueue: SongsQueue.shared, user: User())
//    }
//}




//ScrollView
//{
//    VStack
//    {
//        ForEach(0..<20)
//        {
//            Text("Row \($0)")
//                .frame(width: 300, height: 50)
//        }
//    }
//}




//List(ApplicationMusicPlayer.shared.queue.entries)
//{ song in
//    MusicItemCell(
//        artwork: song.artwork,
//        title: song.title,
//        subtitle: song.subtitle ?? ""
//    )
//}




//let aSong =
//{ () -> Song? in
//    var aSong2: Song?
//    Task
//    { () -> () in
//        aSong2 = await (fetchSong(with: songID))
//    }
//    return aSong2
//}





//List
//{
//    ForEach($songsQueue.songArray, id: \.?.id, editActions: .all)
//    { $song in
//        HStack
//        {
//            MusicItemCell(
//                artwork: song?.artwork,
//                title: song?.title ?? "N/A",
//                subtitle: song?.artistName ?? "N/A"
//            )
//
//            Spacer()
//
//            Image(systemName: "line.3.horizontal")
//        }
//        .frame(height: 50)
//        // Tried this to address list ui problem
//        .id(song?.id)
//    }
//    .onMove(perform: { indices, newOffset in
//        songsQueue.songArray.move(fromOffsets: indices, toOffset: newOffset)
//            })
//}
