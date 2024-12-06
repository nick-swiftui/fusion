//
//  LibraryPlaylistDetailView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 8/2/23.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistDetailView: View
{
    init(_ playlist: Playlist, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User)
    {
        self.playlist = playlist
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
    }
    
    let playlist: Playlist
    
    @State var tracks: MusicItemCollection<Track>?
    @State var entries: MusicItemCollection<Playlist.Entry>?
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    var body: some View
    {
        List
        {
            Section(header: header, content: {})
                .textCase(nil)
            
            if let loadedTracks = tracks, !loadedTracks.isEmpty
            {
                Section(header: Text("Tracks"))
                {
                    ForEach(loadedTracks)
                    { track in
//                        if track.albums != nil
//                        {
//                            TrackCell(track, from: track.albums![0], songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral)
//                            {
//                                print("Track ID: \(track.id)")
//                            }
//                        }
//                        Text("Track")
//                            .onTapGesture
//                            {
//                                print("Track ID: \(track.id)")
//                            }
                        LibraryPlaylistTrackCell(track, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral)
                        {
                            print("Track ID: \(track.id)")
                            print("Album: \(track.albumTitle ?? "nil")")
                            print("Albums: \(String(describing: track.albums))")
                            print("Entry: \(String(describing: entries![0].albumTitle))")
                            print("Entry ID: \(entries![0].id)")
                            //print("Tracks: \(tracks)")
                            print("Playlist: \(playlist.id)")
                        }
                    }
                }
            }
        }
        .task
        {
            try? await loadTracks()
        }
    }
    
    private var header: some View
    {
        VStack
        {
            if let artwork = playlist.artwork
            {
                HStack
                {
                    Spacer()
                    ArtworkImage(artwork, height: 300)
                        .cornerRadius(6)
                    Spacer()
                }
                
                HStack
                {
                    Spacer()
                    Text(playlist.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(user.appearance == "Light" ? .black : .white)
                    Spacer()
                }
                
                HStack
                {
                    Spacer()
                    Text(playlist.curatorName ?? "")
                        .font(.title3)
                        .foregroundColor(Color.primary)
                    Spacer()
                }
                
                HStack
                {
                    Spacer()
                    Text(setLastModifiedString(with:calculateSecondsAgo(from: playlist.lastModifiedDate)).uppercased())
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
        }
    }
    
    // Function to calculate how many seconds ago a date was.
    func calculateSecondsAgo(from date: Date?) -> Int
    {
        guard let date = date else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second], from: date, to: Date())
        return components.second ?? 0
    }
    
    func setLastModifiedString(with seconds: Int) -> String
    {
        if seconds == 0
        {
            return "Last Update Unknown"
        }
        else if seconds < 86_400
        {
            return "Updated Today"
        }
        else if seconds < 172_800
        {
            return "Updated Yesterday"
        }
        else if seconds < 259_200
        {
            return "Updated 2 Days Ago"
        }
        else if seconds < 345_600
        {
            return "Updated 3 Days Ago"
        }
        else if seconds < 432_000
        {
            return "Updated 4 Days Ago"
        }
        else if seconds < 518_400
        {
            return "Updated 5 Days Ago"
        }
        else if seconds < 604_800
        {
            return "Updated 6 Days Ago"
        }
        else if seconds < 1_209_600
        {
            return "Updated 1 Week Ago"
        }
        else if seconds < 1_814_400
        {
            return "Updated 2 Weeks Ago"
        }
        else if seconds < 2_419_200
        {
            return "Updated 3 Weeks Ago"
        }
        else
        {
            return "Updated Over A Month Ago"
        }
    }
    
    private func loadTracks() async throws
    {
        let detailedPlaylist = try await playlist.with([.tracks, .entries])
        
//        let playlistRequest = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: playlist.id)
//        let playlistResponse = try? await playlistRequest.response()
//
//        if let playlist = playlistResponse?.items.first
//        {
//            print("Here is the playlist: \(playlist)")
//        }
//        else
//        {
//            print("Couldn't find playlist.")
//        }
        
        await update(tracks: detailedPlaylist.tracks, entries: detailedPlaylist.entries)
    }
    
    @MainActor
    private func update(tracks: MusicItemCollection<Track>?, entries: MusicItemCollection<Playlist.Entry>?)
    {
        withAnimation
        {
            self.tracks = tracks
            self.entries = entries
        }
    }
}

//struct LibraryPlaylistDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        LibraryPlaylistDetailView()
//    }
//}
