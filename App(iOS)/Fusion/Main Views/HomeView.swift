//
//  HomeView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/20/23.
//

import SwiftUI
import MusicKit

struct HomeView: View
{
    // MARK: - Properties
    
    @ObservedObject var songsQueue: SongsQueue
    
    @ObservedObject var user: User
    @ObservedObject var bluetoothCentral: BluetoothCentral
    @ObservedObject var bluetoothPeripheral: BluetoothPeripheral
    
    @ObservedObject var library: Library
    
    @State private var showingSheet = false
    
    //@State private var discoveredPeripheralName = ""
    
//    @State private var colors: [Color] = [.primary, .primary]
//    @State private var newColors: [Color] = [.primary, .primary]
//    @State private var progress: CGFloat = 0
    // MARK: - View
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
//                LinearGradient(gradient: Gradient(colors: songsQueue.currentSong != nil ? colors : [.white, .white]), startPoint: .top, endPoint: .bottom)
//                    .ignoresSafeArea()
//                    .animatedLinearGradient(fromColors: colors, toColors: newColors)
//                    .onChange(of: newColors)
//                    { newValue in
//                        colors = newValue
//                    }
                    //.animation(.linear(duration: 1), value: colors)
                
//                Rectangle()
//                    .fill(.clear)
//                    .ignoresSafeArea()
//                    //.animatedLinearGradient(fromColors: colors, toColors: newColors)
//                    .onChange(of: newColors)
//                    { newValue in
//                        colors = newValue
//                    }
                
                BackgroundView(user: user, songsQueue: songsQueue)
                    
                
                VStack
                {
                    VStack
                    {
                        Spacer()
                        
                        MusicControlsView(songsQueue: songsQueue, bluetoothCentral: bluetoothCentral, bluetoothPeripheral: bluetoothPeripheral, user: user)
                            .padding()
                            .frame(width: 350, height: 400)
                            .background(Color.gray.opacity(0.25))
                            .cornerRadius(6)
                        
                        AccessoriesView(songsQueue: songsQueue, user: user, bluetoothCentral: bluetoothCentral, bluetoothPeripheral: bluetoothPeripheral, library: library)
                        
                        SongsQueueView(songsQueue: songsQueue, user: user)
                            //.padding()
                            .frame(width: 350, height: 175)
                            .background(Color.gray.opacity(0.25))
                            .cornerRadius(6)
                            //.background(Color.red)
                            .disabled(bluetoothPeripheral.isPeering && !bluetoothPeripheral.permissions.contains("QO"))
                    }
                    
                    Spacer()
                }
                .ignoresSafeArea(.keyboard)
                .toolbar
                {
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                        Button(action: toggleShowingSheet)
                        {
                            Image(systemName: "magnifyingglass")
                        }
                        .sheet(isPresented: $showingSheet)
                        {
                            MusicSearchView(songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, user: user, bluetoothCentral: bluetoothCentral)
                                .alert(isPresented: $bluetoothPeripheral.showingAlert)
                                {
                                    Alert(
                                        title: Text("Disconnected"),
                                        message: Text("The central has disconnected from you."),
                                        dismissButton: .default(Text("Okay"))
                                        {
                                            bluetoothPeripheral.showingAlert = false
                                        }
                                    )
                                }
                                .alert("\(bluetoothCentral.discoveredPeripheralNameCheckedIn) wants to connect.", isPresented: $bluetoothCentral.showingConnectingAlert)
                                {
                                    //let peer = bluetoothCentral.discoveredPeripheralName
                                    //let peri = bluetoothCentral.discoveredPeripheral
                                    let peri = bluetoothCentral.currentCheckedInPeri
                                    
                                    var tempArray: [String] = []
                                    //var tempString: String = ""
                                    
                                    Button("Allow", role: .cancel)
                                    {
                                        // First, send permissions.
                                        //bluetoothCentral.sendPermissions(to: peer)
                                        bluetoothCentral.sendPermissions(to: peri!)
                                        
                                        // Second, send history.
                                        tempArray = []
                                        
                                        for aSong in songsQueue.history
                                        {
                                            if let song = aSong
                                            {
                                                tempArray.append(song.id.description)
                                                
                                                if tempArray.count == 40
                                                {
                                                    // Send to peer
                                                    //bluetoothCentral.sendHistory(to: peer, with: tempArray, count: songsQueue.history.count)
                                                    bluetoothCentral.sendHistory(to: peri!, with: tempArray, count: songsQueue.history.count)
                                                    
                                                    tempArray = []
                                                }
                                            }
                                        }
                                        
                                        if !tempArray.isEmpty
                                        {
                                            //bluetoothCentral.sendHistory(to: peer, with: tempArray, count: songsQueue.history.count)
                                            bluetoothCentral.sendHistory(to: peri!, with: tempArray, count: songsQueue.history.count)
                                        }
                                        
                                        // Third, send current song.
                                        if let song = songsQueue.currentSong
                                        {
                                            //bluetoothCentral.sendCurrentSong(to: peer, with: song.id.description)
                                            bluetoothCentral.sendCurrentSong(to: peri!, with: song.id.description)
                                        }
                                        
                                        // Fourth, send queue.
                                        tempArray = []
                                        
                                        // This removes progress view from peri
                                        // when .songArray is empty
                                        if songsQueue.songArray.isEmpty
                                        {
                                            bluetoothCentral.sendQueue(to: peri!, queueIDs: [], count: 0)
                                        }
                                        
                                        for aSong in songsQueue.songArray
                                        {
                                            if let song = aSong
                                            {
                                                tempArray.append(song.id.description)
                                                
                                                if tempArray.count == 40
                                                {
                                                    // Send to peer
                                                    //bluetoothCentral.sendQueue(to: peer, queueIDs: tempArray, count: songsQueue.songArray.count)
                                                    bluetoothCentral.sendQueue(to: peri!, queueIDs: tempArray, count: songsQueue.songArray.count)
                                                    
                                                    tempArray = []
                                                }
                                            }
                                        }
                                        
                                        if !tempArray.isEmpty
                                        {
                                            //bluetoothCentral.sendQueue(to: peer, queueIDs: tempArray, count: songsQueue.songArray.count)
                                            bluetoothCentral.sendQueue(to: peri!, queueIDs: tempArray, count: songsQueue.songArray.count)
                                        }
                                        
                                        // Fifth, send peers.
                                        tempArray = []
                                        
                                        if !bluetoothCentral.connectedPeripherals.isEmpty
                                        {
                                            for peri in bluetoothCentral.connectedPeripherals.values
                                            {
                                                tempArray.append(peri)
                                            }
                                            
                                            bluetoothCentral.sendPeers(to: peri!, peers: tempArray)
                                        }
                                        
                                        // Finish up
                                        bluetoothCentral.showingAlert = false
                                        
                                        bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                                        print(bluetoothCentral.peripheralCheckInLine.count)
                                    }
                                    Button("Deny", role: .none)
                                    {
                        //                    for peri in bluetoothCentral.connectedPeripherals.keys
                        //                    {
                        //                        if bluetoothCentral.connectedPeripherals[peri] == peer
                        //                        {
                        //                            bluetoothCentral.disconnect(peripheral: peri)
                        //                            break
                        //                        }
                        //                    }
                        //                    bluetoothCentral.showingAlert = false
                        //
                        //                    bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                                        
                                        bluetoothCentral.disconnect(peripheral: peri!)
                                        bluetoothCentral.showingAlert = false
                                        
                                        bluetoothCentral.peripheralCheckInLine.remove(at: 0)
                                    }
                                }
                        }
                    }
                }
            }
        }
        
        
//        .onChange(of: songsQueue.currentSong)
//        { _ in
//            withAnimation
//            {
//                self.colors = [.white, .black]
//            }
//        }
        
        // Display the welcome view when appropriate.
        //.welcomeSheet(user: user)
    }
    
    // MARK: - Methods
    
    func toggleShowingSheet()
    {
        showingSheet.toggle()
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
}

struct HomeView_Previews: PreviewProvider
{
    static var previews: some View
    {
        HomeView(songsQueue: SongsQueue.shared, user: User(), bluetoothCentral: BluetoothCentral(), bluetoothPeripheral: BluetoothPeripheral(), library: Library())
    }
}





//struct AnimatedLinearGradient: ViewModifier
//{
//    var fromColors: [Color]
//    var toColors: [Color]
//    @State private var currentColors: [Color]
//
//    init(fromColors: [Color], toColors: [Color])
//    {
//        self.fromColors = fromColors
//        self.toColors = toColors
//        self._currentColors = State(initialValue: fromColors)
//    }
//
//    func body(content: Content) -> some View
//    {
//        content
//            .overlay(
//                LinearGradient(
//                    gradient: Gradient(colors: currentColors),
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//                .animation(.easeInOut(duration: 1.0)) // Adjust the animation duration as desired
//            )
//            .onAppear
//            {
//                animateColors()
//            }
//    }
//
//    private func animateColors()
//    {
//        withAnimation
//        {
//            self.currentColors = toColors
//        }
//    }
//}
//
//extension View
//{
//    func animatedLinearGradient(fromColors: [Color], toColors: [Color]) -> some View
//    {
//        self.modifier(AnimatedLinearGradient(fromColors: fromColors, toColors: toColors))
//    }
//}





//@State private var backgroundColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 0)
//@State private var artwork: Artwork? = nil
//                if artwork != nil
//                {
//                    GeometryReader
//                    { geometry in
//                        ArtworkImage(artwork!, width: geometry.size.width, height: geometry.size.height + 200)
//                            .ignoresSafeArea()
//                    }
//
//                }
//                Color(backgroundColor)
//                    .onChange(of: songsQueue.currentSong)
//                    { newValue in
//                        print("Color should change.")
//                        withAnimation
//                        {
//                            backgroundColor = newValue?.artwork?.backgroundColor ?? CGColor.init(red: 0, green: 0, blue: 0, alpha: 0)
//                            //backgroundColor = ApplicationMusicPlayer.shared.queue.currentEntry?.artwork?.backgroundColor ?? CGColor.init(red: 0, green: 0, blue: 0, alpha: 0)
//                        }
//                    }
//    .onChange(of: songsQueue.currentSong)
//    { newValue in
//        withAnimation
//        {
//            artwork = songsQueue.currentSong?.artwork
//        }
//    }
