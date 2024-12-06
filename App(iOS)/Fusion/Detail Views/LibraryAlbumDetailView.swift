//
//  LibraryAlbumDetailView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/28/23.
//

import MusicKit
import SwiftUI

/// `LibraryAlbumDetailView` is a view that presents detailed information about a specific `Album`.
struct LibraryAlbumDetailView: View
{
    // MARK: - Object lifecycle
    
    init(_ album: Album, songsQueue: SongsQueue, bluetoothPeripheral: BluetoothPeripheral, user: User)
    {
        self.album = album
        
        self.songsQueue = songsQueue
        self.bluetoothPeripheral = bluetoothPeripheral
        
        self.user = user
    }
    
    // MARK: - Properties
    
    /// The album that this view represents.
    let album: Album
    
    /// The tracks that belong to this album.
    @State var tracks: MusicItemCollection<Track>?
    
    /// A collection of related albums.
    @State var relatedAlbums: MusicItemCollection<Album>?
    
    /// The artist of the album.
    @State var artist: MusicItemCollection<Artist>.Element?
    
    @State var genre: MusicItemCollection<Genre>.Element?
    
    @ObservedObject var songsQueue: SongsQueue
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var user: User
    
    @State private var completeAlbum: Album?
    
    // MARK: - View
    
    var body: some View
    {
        List
        {
            Section(header: header, content: {})
                .textCase(nil)
//                .foregroundColor(.primary)
            
            // Add a list of tracks on the album.
            if let loadedTracks = tracks, !loadedTracks.isEmpty
            {
                Section(header: Text("Tracks"))
                {
                    ForEach(loadedTracks)
                    { track in
                        if let completeAlbum = completeAlbum
                        {
                            if let completeAlbumTracks = completeAlbum.tracks, let trackNumber = track.trackNumber
                            {
                                //let trackIndex = completeAlbum.tracks?.firstIndex(of: track)
                                let trackIndex = trackNumber - 1
                                TrackCell(completeAlbumTracks[trackIndex], from: album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral)
                                {
                                    //handleTrackSelected(track, loadedTracks: loadedTracks)
                                    print("Track ID: \(completeAlbumTracks[trackIndex].id)")
                                    print("Albums: \(completeAlbumTracks[trackIndex].albums)")
                                }
                            }
                            else
                            {
                                TrackCell(track, from: album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral)
                                {
                                    //handleTrackSelected(track, loadedTracks: loadedTracks)
                                    print("Track ID: \(track.id)")
                                }
                            }
                        }
                        else
                        {
                            TrackCell(track, from: album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral)
                            {
                                //handleTrackSelected(track, loadedTracks: loadedTracks)
                                print("Track ID: \(track.id)")
                            }
                        }
//                        TrackCell(track, from: album, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral)
//                        {
//                            //handleTrackSelected(track, loadedTracks: loadedTracks)
//                            print("Track ID: \(track.id)")
//                            print("Complete Album tracks: \(completeAlbum?.tracks)")
//                        }
                    }
                }
            }
            
            Section(header: Text("Editorial Notes"))
            {
                if let editorialNotes = album.editorialNotes
                {
                    Text(formatEditorialNotes())
                }
            }
        }
        // When the view appears, load tracks and related albums asynchronously.
        .task
        {
//            let libraryAlbum: Album? = await fetchAlbum(with: album.id.rawValue)
//
//            if libraryAlbum == nil
//            {
//                // Don't assign
//            }
//            else
//            {
//                self.album = libraryAlbum!
//            }
            completeAlbum = await fetchCompleteAlbum()
            
            print(album.artwork == nil ? "artwork nil" : "artwork not nil")
            try? await loadTracksRelatedAlbumsAndArtist()
            print(album.id)
            print(album.title)
        }
    }
    
    private var header: some View
    {
        VStack
        {
            if let artwork = album.artwork
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
                    Text(album.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(user.appearance == "Light" ? .black : .white)
                    Spacer()
                }
                
                HStack
                {
                    Spacer()
                    if let artist = self.artist
                    {
                        NavigationLink(destination: LibraryArtistDetailView(artist, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user))
                        {
                            Text(album.artistName)
                                .font(.title3)
                                .foregroundColor(Color.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    else
                    {
                        Text(album.artistName)
                            .font(.title3)
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                }
                
                HStack
                {
                    Spacer()
                    if completeAlbum != nil
                    {
                        Text(completeAlbum!.genreNames.first ?? "nil")
                    }
                    else
                    {
                        //Text(album.genreNames.first ?? "nill")
                        Text(genre?.name ?? "")
                    }
                    Text("•")
                    if let releaseDate = album.releaseDate
                    {
                        Text(Calendar.current.dateComponents([.year], from: releaseDate).year!.description)
                    }
                    else
                    {
                        Text("n/a")
                    }
                    Spacer()
                }
                
                //playShuffleButtonRow
                
//                if let editorialNotes = album.editorialNotes
//                {
//
//                    ZStack
//                    {
//                        Text(formatEditorialNotes())
//                            .lineLimit(2)
//                        VStack
//                        {
//                            Spacer()
//                            HStack
//                            {
//                                Spacer()
//                                Text("MORE")
//                                    .foregroundColor(Color.black)
//                                    .background(Color.white)
//                                    .blur(radius: 1)
//                            }
//                        }
//                    }
//                }
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
    
    // MARK: - Loading tracks, related albums and artist
    
    /// Loads tracks and related albums asynchronously.
    private func loadTracksRelatedAlbumsAndArtist() async throws {
        let detailedAlbum = try await album.with([.artists, .tracks, .genres])
        let artist = try await detailedAlbum.artists?.first?.with([.albums])
        let genre = detailedAlbum.genres?.first
        await update(tracks: detailedAlbum.tracks, relatedAlbums: artist?.albums, artist: artist, genre: genre)
    }
    
    /// Safely updates `tracks` and `relatedAlbums` properties on the main thread.
    @MainActor
    private func update(tracks: MusicItemCollection<Track>?, relatedAlbums: MusicItemCollection<Album>?, artist: MusicItemCollection<Artist>.Element?, genre: MusicItemCollection<Genre>.Element?) {
        withAnimation {
            self.tracks = tracks
            self.relatedAlbums = relatedAlbums
            self.artist = artist
            self.genre = genre
        }
    }
    
    // MARK: - Other methods
    
    private func handlePlayButtonSelected()
    {
        var tempSongArray: [Song] = []
        
        if let loadedTracks = tracks, !loadedTracks.isEmpty
        {
            Task
            {
                for track in loadedTracks
                {
                    if let completeAlbum = completeAlbum
                    {
                        if let completeAlbumTracks = completeAlbum.tracks, let trackNumber = track.trackNumber
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
                }
                
                for song in tempSongArray
                {
                    songsQueue.queueLast = true
                    songsQueue.songArray.append(song)
                    
                    Task
                    {
                        try await ApplicationMusicPlayer.shared.queue.insert(song, position: .tail)
                    }
                }
            }
        }
        else
        {
            print("Error playing album.")
        }
    }
    
    private func handleShuffleButtonSelected()
    {
        
    }
    
    func formatEditorialNotes() -> String
    {
        guard let data = album.editorialNotes?.standard?.data(using: .utf8)
        else
        {
            return ""
        }
        
        guard let attributedString = try? NSAttributedString(data: data,
                                                            options: [.documentType: NSAttributedString.DocumentType.html,
                                                                      .characterEncoding: String.Encoding.utf8.rawValue],
                                                            documentAttributes: nil)
        else
        {
            return ""
        }
        
//        print(album.editorialNotes?.standard!)
//        print(attributedString.string)
//        return attributedString.string
        
        var formattedString = attributedString.string
            
        // Add extra newline for every newline character
        formattedString = formattedString.replacingOccurrences(of: "\n", with: "\n\n")
        
        return formattedString
    }
    
    func fetchAlbum(with id: String) async -> Album?
    {
        let libraryRequest = MusicLibraryRequest<Album>()
        var filteredRequest = libraryRequest
        filteredRequest.filter(matching: \.id, equalTo: MusicItemID(rawValue: id))
        
        let filteredRequestResponse = try? await filteredRequest.response()
        if let album = filteredRequestResponse?.items.first
        {
            print("Found \(album).")
            //return song.title
            return album
        }
        
        print("Could not find album.")
        //return "Could not find album."
        return nil
    }
    
    func fetchCompleteAlbum() async -> Album?
    {
        let albumRequest = MusicCatalogSearchRequest(term: "\(self.album.title) \(self.album.artistName)", types: [Album.self])
        let albumResponse = try? await albumRequest.response()
        
        if let albumResponse = albumResponse
        {
            for album in albumResponse.albums
            {
                if album.title == self.album.title && album.artistName == self.album.artistName
                {
                    print("Found Complete Album: \(album)")
                    // Keepeye
                    return try? await album.with([.tracks, .genres])
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

//struct LibraryAlbumDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        LibraryAlbumDetailView()
//    }
//}
