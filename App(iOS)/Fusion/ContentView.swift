//
//  ContentView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/9/23.
//

import MusicKit
import SwiftUI

import UserNotifications

struct ContentView: View
{
    // MARK: - Properties
    
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var songsQueue: SongsQueue
    //@StateObject var songsQueue = SongsQueue()
    //@ObservedObject var songsQueue = SongsQueue()
    
    @ObservedObject var user: User
    
    @ObservedObject var library: Library
    
    @StateObject var bluetoothCentral = BluetoothCentral()
    @StateObject var bluetoothPeripheral = BluetoothPeripheral()
    
//    @ObservedObject var playerSharedQueue = ApplicationMusicPlayer.shared.queue
    
    @State private var isDarkMode = false
    
    //@State private var discoveredPeripheralName = ""
    
    //@State private var scenePhaseCount = 0
    //@State private var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    //@State private var allowIcloudSave: Bool = false
    
    @State private var trialTimeLeft: TimeInterval = 86_400.0
    @State private var trialTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // MARK: - View
    
    var body: some View
    {
        TabView
        {
            HomeView(songsQueue: songsQueue, user: user, bluetoothCentral: bluetoothCentral, bluetoothPeripheral: bluetoothPeripheral, library: library)
                .tabItem
                {
                    Label("", systemImage: "house")
                }
            
            LibraryView(songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, library: library, user: user)
                .tabItem
                {
                    Label("", systemImage: "play.square.stack")
                }
            
            SocialView(user: user, songsQueue: songsQueue, bluetoothPeripheral: bluetoothPeripheral, bluetoothCentral: bluetoothCentral)
                .tabItem
                {
                    Label("", systemImage: "person.2")
                }
            
            ShopView(user: user)
                .tabItem
                {
                    Label("", systemImage: "bag")
                }
            
//            AlertsView()
//                .tabItem
//                {
//                    Label("", systemImage: "bell")
//                }
            
            AccountView(user: user, songsQueue: songsQueue)
                .tabItem
                {
                    Label("", systemImage: "person")
                }
        }
        .onAppear
        {
//            UITabBar.appearance().backgroundImage = UIImage()
//            UITabBar.appearance().shadowImage = UIImage()
        }
        // Must apply this alert where
        // .sheet() is being used.
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
        .onChange(of: bluetoothCentral.showingAlert)
        { newValue in
            print("onChange changed!")
            if newValue == true
            {
                print("onChange newValue is true!")
                bluetoothCentral.discoveredPeripheralNameCheckedIn = bluetoothCentral.connectedPeripherals[bluetoothCentral.peripheralCheckInLine[0]]!
                
                // New
                bluetoothCentral.currentCheckedInPeri = bluetoothCentral.peripheralCheckInLine[0]
                
                bluetoothCentral.showingConnectingAlert = true
                notifyHostOfConnectingDevice()
            }
            else if bluetoothCentral.peripheralCheckInLine.count != 0
            {
                bluetoothCentral.showingAlert = true
            }
        }
        .onChange(of: songsQueue.songArray)
        { newValue in
            songsQueueSongArrayUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothPeripheral.songsQueueIdArray)
        { newValue in
            bpSongsQueueIdArrayUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothCentral.songsQueueIdArray)
        { newValue in
            bcSongsQueueIdArrayUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothPeripheral.currentSongChanged)
        { newValue in
            bpCurrentSongChangedUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothPeripheral.historySongChanged)
        { newValue in
            bpHistorySongChangedUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothPeripheral.clearNowPlaying)
        { newValue in
            bpClearNowPlayingUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothPeripheral.previousSongChanged)
        { newValue in
            bpPreviousSongChangedUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothPeripheral.historyImported)
        { newValue in
            bpHistoryImportedUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothPeripheral.queueImported)
        { newValue in
            bpQueueImportedUpdate(newValue: newValue)
        }
        .onChange(of: bluetoothCentral.queueImported)
        { newValue in
            if newValue == true
            {
                let tempSongArray = songsQueue.songArray
                songsQueue.songArray = []
                
                for id in bluetoothCentral.songsQueueIdArray
                {
                    for aSong in tempSongArray
                    {
                        if let song = aSong
                        {
                            if song.id.description == id
                            {
                                songsQueue.songArray.append(song)
                                break
                            }
                            else
                            {
                                continue
                            }
                        }
                        else
                        {
                            break
                        }
                    }
                }
                
                bluetoothCentral.queueImportedArray = []
                bluetoothCentral.queueImported = false
            }
        }
        .onChange(of: bluetoothPeripheral.connectedCentral)
        { newValue in
            if newValue == nil
            {
                songsQueue.history = []
                songsQueue.currentSong = nil
                songsQueue.songArray = []
                
                bluetoothPeripheral.historyImportedArray = []
                bluetoothPeripheral.queueImportedArray = []
                bluetoothPeripheral.queueUpdateImportedArray = []
                
                bluetoothPeripheral.songsQueueIdArray = []
                
                bluetoothPeripheral.justConnected = false
                
                bluetoothPeripheral.peersArray = []
                bluetoothPeripheral.peersListOpacity = 0.0
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear
        {
            switch user.appearance
            {
            case "Light":
                isDarkMode = false
            case "Dark":
                isDarkMode = true
            case "Dynamic":
                isDarkMode = true
            default:
                isDarkMode = false
            }
        }
        .onChange(of: user.appearance)
        { appearance in
            switch appearance
            {
            case "Light":
                isDarkMode = false
            case "Dark":
                isDarkMode = true
            case "Dynamic":
                isDarkMode = true
            default:
                isDarkMode = false
            }
        }
        .onChange(of: scenePhase)
        { newPhase in
            if newPhase == .background //&& allowIcloudSave
            {
                print("Background: user.currentRecord is \(user.currentRecord != nil ? "not nil" : "nil")")
                if let record = user.currentRecord
                {
                    user.saveRecord(with: user.setRecordValues(record: record), database: user.database)
//                    allowIcloudSave = false
//                    timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
                }
            }
        }
//        .onReceive(timer)
//        { _ in
//            print("Timer fired!")
//            allowIcloudSave = true
//            timer.upstream.connect().cancel()
//        }
        .onChange(of: user.trialEndDate)
        { newValue in
            print("User trial end date changed.")
            
            trialTimer.upstream.connect().cancel()
            trialTimeLeft = getTimeDifference(from: .now, to: user.trialEndDate)
            trialTimer = Timer.publish(every: trialTimeLeft, on: .main, in: .common).autoconnect()
        }
        .onReceive(trialTimer)
        { _ in
            trialTimer.upstream.connect().cancel()
            
            trialTimeLeft = getTimeDifference(from: .now, to: user.trialEndDate)
            print(trialTimeLeft)
            
            if trialTimeLeft > 0.0
            {
                print("+tt")
                trialTimer = Timer.publish(every: trialTimeLeft, on: .main, in: .common).autoconnect()
            }
            else
            {
                print("-tt")
                
                // Check if Pro user
                if user.isPro && user.usedTrial
                {
                    user.update(isPro: false)
                    if user.appearance == "Dynamic"
                    {
                        user.update(appearance: "Dark")
                    }
                    if bluetoothCentral.isHosting
                    {
                        if !bluetoothCentral.connectedPeripherals.isEmpty
                        {
                            for peri in bluetoothCentral.connectedPeripherals.keys
                            {
                                bluetoothCentral.disconnect(peripheral: peri)
                            }
                        }
                    }
                }
            }
        }
//        .onChange(of: bluetoothCentral.connectedPeripherals)
//        { newValue in
//            let peri = bluetoothCentral.currentCheckedInPeri
//
//            bluetoothCentral.disconnect(peripheral: peri!)
//            bluetoothCentral.peripheralCheckInLine.remove(at: 0)
//        }
//        .onChange(of: ApplicationMusicPlayer.shared.queue.currentEntry)
//        { _ in
//            print("Current Entry changed. (Content)")
//        }
//        .onChange(of: playerSharedQueue)
//        { _ in
//            print("Current Entry changed. (Content)xxx")
//        }
//        .onAppear
//        {
//            print(ApplicationMusicPlayer.shared.queue.currentEntry)
//        }
//        .onReceive(ApplicationMusicPlayer.shared.queue.objectWillChange)
//        {
//            print("Object will change.")
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
    
    func updateMusicPlayerEntries()
    {
        var tempSongs: [Song?] = []
        var ctr: Int = 0
        var songsCount: Int = 0
        var tempEntries: [MusicPlayer.Queue.Entry] = []
        
        if !songsQueue.history.isEmpty
        {
            tempSongs += songsQueue.history
            songsCount += songsQueue.history.count
        }
        if songsQueue.currentSong != nil
        {
            tempSongs.append(songsQueue.currentSong)
            songsCount += 1
        }
        if !songsQueue.songArray.isEmpty
        {
            tempSongs += songsQueue.songArray
        }
        
        if ApplicationMusicPlayer.shared.queue.entries.count == tempSongs.count
        {
            for song in tempSongs
            {
                if ctr < songsCount
                {
                    ctr += 1
                    continue
                }
                
                for entry in ApplicationMusicPlayer.shared.queue.entries
                {
                    if song?.id == entry.item?.id
                    {
                        let index = ApplicationMusicPlayer.shared.queue.entries.firstIndex(of: entry)
                        tempEntries.append(ApplicationMusicPlayer.shared.queue.entries.remove(at: index!))
                        break
                    }
                }
            }
            
            ApplicationMusicPlayer.shared.queue.entries += tempEntries
        }
        else
        {
            var entryIndex: Int? = nil
            var tempEntries: [MusicPlayer.Queue.Entry] = []

            for entry in ApplicationMusicPlayer.shared.queue.entries
            {
                tempEntries.append(entry)
            }

            for song in tempSongs
            {
                if song?.id == tempEntries[0].item?.id
                {
                    tempEntries.removeFirst()
                    continue
                }
                else
                {
                    entryIndex = ApplicationMusicPlayer.shared.queue.entries.firstIndex(of: tempEntries[0])
                    break
                }
            }

            if entryIndex != nil
            {
                ApplicationMusicPlayer.shared.queue.entries.remove(at: entryIndex!)
                print("Delete succeeded!")
            }
            else
            {
                ApplicationMusicPlayer.shared.queue.entries.removeLast()
                print("Delete succeeded!")
            }
        }
    }
    
    func peerSongArrayUpdate1(newValue: [Song?])
    {
        print("bp1")
        
        if songsQueue.queueNext == true
        {
            var songIdString = "QNSQID"
            
            if let song = newValue[0]
            {
                songIdString.append(song.id.description)
            }
            
            bluetoothPeripheral.text = songIdString
            bluetoothPeripheral.dataToSend = bluetoothPeripheral.text.data(using: .utf8)!
            bluetoothPeripheral.sendDataIndex = 0
            bluetoothPeripheral.peripheralManagerIsReady(toUpdateSubscribers: bluetoothPeripheral.peripheralManager)
            
            bluetoothPeripheral.isQueueSender = true
            songIdString = "QNSQID"
            songsQueue.queueNext = false
        }
        else if songsQueue.queueLast == true
        {
            var songIdString = "QLSQID"
            
            if let aSong = newValue.last
            {
                if let song = aSong
                {
                    songIdString.append(song.id.description)
                    
                    bluetoothPeripheral.text = songIdString
                    bluetoothPeripheral.dataToSend = bluetoothPeripheral.text.data(using: .utf8)!
                    bluetoothPeripheral.sendDataIndex = 0
                    bluetoothPeripheral.peripheralManagerIsReady(toUpdateSubscribers: bluetoothPeripheral.peripheralManager)
                    
                    bluetoothPeripheral.isQueueSender = true
                    songIdString = "QLSQID"
                }
            }
            
            songsQueue.queueLast = false
        }
//                else
//                {
//                    // Don't store more than 40 song id's in string
//                    var songIdString = "SQID"
//                    print("May24 - 1")
//
//                    for aSong in newValue
//                    {
//                        if let song = aSong
//                        {
//                            songIdString.append("\(song.id.description),")
//                            print("\(songIdString)")
//                        }
//                    }
//
//                    if songIdString.last == ","
//                    {
//                        songIdString.removeLast()
//                    }
//
//                    bluetoothPeripheral.text = songIdString
//                    bluetoothPeripheral.dataToSend = bluetoothPeripheral.text.data(using: .utf8)!
//                    bluetoothPeripheral.sendDataIndex = 0
//                    bluetoothPeripheral.peripheralManagerIsReady(toUpdateSubscribers: bluetoothPeripheral.peripheralManager)
//
//                    bluetoothPeripheral.isQueueSender = true
//                    songIdString = "SQID"
//                }
        else
        {
            // Don't store more than 40 song id's in string
            //var songIdString = "SQID"
            print("May24 - 1")
            
            if bluetoothPeripheral.justConnected
            {
                print("bluetoothPeripheral.justConnected - Skipping this else statement.")
                bluetoothPeripheral.justConnected = false
                return
            }
            
            if bluetoothPeripheral.hadQueueImported
            {
                bluetoothPeripheral.hadQueueImported = false
                return
            }
            
            var tempArray: [String] = []
            
            for aSong in newValue
            {
                if let song = aSong
                {
//                            songIdString.append("\(song.id.description),")
//                            print("\(songIdString)")
                    
                    tempArray.append(song.id.description)
                    
//                    if tempArray.count == 40
//                    {
//                        bluetoothPeripheral.exportQueue(queueIDs: tempArray, count: newValue.count)
//                        tempArray = []
//                    }
                }
            }
            
            bluetoothPeripheral.exportQueueIDs = tempArray
            bluetoothPeripheral.exportQueueCount = tempArray.count
            
            bluetoothPeripheral.exportQueue()
            
//            if !tempArray.isEmpty
//            {
//                bluetoothPeripheral.exportQueue(queueIDs: tempArray, count: newValue.count)
//            }
//
//            if newValue.isEmpty
//            {
//                bluetoothPeripheral.exportQueue(queueIDs: [], count: 0)
//            }
            
//                    if songIdString.last == ","
//                    {
//                        songIdString.removeLast()
//                    }
//
//                    bluetoothPeripheral.text = songIdString
//                    bluetoothPeripheral.dataToSend = bluetoothPeripheral.text.data(using: .utf8)!
//                    bluetoothPeripheral.sendDataIndex = 0
//                    bluetoothPeripheral.peripheralManagerIsReady(toUpdateSubscribers: bluetoothPeripheral.peripheralManager)
//
            bluetoothPeripheral.isQueueSender = true
//                    songIdString = "SQID"
        }
    }
    
    func peerSongArrayUpdate2()
    {
        print("bp2")
        print("bluetoothPeripheral.queueOrder must be true")
        bluetoothPeripheral.queueNext = false
        bluetoothPeripheral.queueLast = false
        bluetoothPeripheral.queueOrder = false
    }
    
    func hostSongArrayUpdateQueueNext(newValue: [Song?])
    {
        var textArray: [String] = []
        var songIdString = "QNSQID"
        
        if let song = newValue[0]
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
            
            if bluetoothCentral.songsQueueIdArrayUpdatedByPeer
            {
                bluetoothCentral.songsQueueIdArrayUpdatedByPeer = false
            }
            else
            {
                // Need to force this to change
                bluetoothCentral.songsQueueIdArray.insert(song.id.description, at: 0)
                bluetoothCentral.songsQueueIdArrayForcedUpdated = true
            }
            
            textArray = []
            songIdString = "QNSQID"
        }
        
        songsQueue.queueNext = false
    }
    
    func hostSongArrayUpdateQueueLast(newValue: [Song?])
    {
        var textArray: [String] = []
        var songIdString = "QLSQID"
        
        if let aSong = newValue.last
        {
            if let song = aSong
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
                
                if bluetoothCentral.songsQueueIdArrayUpdatedByPeer
                {
                    bluetoothCentral.songsQueueIdArrayUpdatedByPeer = false
                }
                else
                {
                    // Need to force this to change
                    bluetoothCentral.songsQueueIdArray.append(song.id.description)
                    bluetoothCentral.songsQueueIdArrayForcedUpdated = true
                }
                
                textArray = []
                songIdString = "QLSQID"
            }
        }
        
        songsQueue.queueLast = false
    }
    
    func hostSongArrayUpdateQueueOrder(newValue: [Song?])
    {
        // Don't store more than 40 song id's in array
        //var textArray: [String] = []
        //var songIdString = "SQID"
        print("May24 - 2")
        //bluetoothCentral.queueImportedArray = []
        
        var tempArray: [String] = []
        
        for aSong in newValue
        {
            if let song = aSong
            {
                //songIdString.append("\(song.id.description),")
                //print("\(songIdString)")
                
                tempArray.append(song.id.description)
                
//                if tempArray.count == 40
//                {
//                    bluetoothCentral.updateQueue(queueIDs: tempArray, count: newValue.count)
//                    tempArray = []
//                }
            }
        }
        
        bluetoothCentral.updateQueueIDs = tempArray
        bluetoothCentral.updateQueueCount = tempArray.count
        
        bluetoothCentral.updateQueue()
        
//        if !tempArray.isEmpty
//        {
//            bluetoothCentral.updateQueue(queueIDs: tempArray, count: newValue.count)
//        }
//
//        if newValue.isEmpty
//        {
//            bluetoothCentral.updateQueue(queueIDs: [], count: 0)
//        }
        
        if bluetoothCentral.songsQueueIdArrayUpdatedByPeer
        {
            bluetoothCentral.songsQueueIdArrayUpdatedByPeer = false
        }
        else
        {
            // Need to force this to change
            bluetoothCentral.songsQueueIdArray = tempArray
            // Do NOT update this bool here.
            //bluetoothCentral.songsQueueIdArrayForcedUpdated = true
        }
        
        // May29 - Start
        updateMusicPlayerEntries()
        // May29 - Finish
        
        tempArray = []
        
        //songIdString = "SQID"
    }
    
    func bpSongsQueueIdArrayUpdate(newValue: [String])
    {
        if bluetoothPeripheral.queueNext == true
        {
            if newValue.isEmpty
            {
                return
            }
            Task
            {
                let aSong = await fetchSong(with: newValue[0])
                
                if let song = aSong
                {
                    songsQueue.songArray.insert(song, at: 0)
                }
            }
            
            //bluetoothPeripheral.queueNext = false
        }
        else if bluetoothPeripheral.queueLast == true
        {
            Task
            {
                if let lastSong = newValue.last
                {
                    let aSong = await fetchSong(with: lastSong)
                    if let song = aSong
                    {
                        songsQueue.songArray.append(song)
                    }
                }
            }
            
            //bluetoothPeripheral.queueLast = false
        }
        //else if bluetoothPeripheral.queueOrder == true
        else
        {
            if bluetoothPeripheral.queueUpdateImported
            {
                print("May24 - 3")
                let tempSongArray = songsQueue.songArray
                //print("tempSongArray - \(tempSongArray)")
                songsQueue.songArray = []
                
                //print("newValue - \(newValue)")
                
                for id in newValue
                {
                    for aSong in tempSongArray
                    {
                        if let song = aSong
                        {
                            if song.id.description == id
                            {
                                songsQueue.songArray.append(song)
                                break
                            }
                            else
                            {
                                continue
                            }
                        }
                        else
                        {
                            break
                        }
                    }
                }
                
                //print("songsQueue.songArray - \(songsQueue.songArray)")
                
                bluetoothPeripheral.queueUpdateImportedArray = []
                bluetoothPeripheral.queueUpdateImported = false
                
                //bluetoothPeripheral.queueOrder = false
                
                if tempSongArray == songsQueue.songArray
                {
                    bluetoothPeripheral.queueOrder = false
                }
            }
        }
//            else
//            {
//                songsQueue.songArray = []
//
//                for id in newValue
//                {
//                    Task
//                    {
//                        let aSong = await fetchSong(with: id)
//
//                        if let song = aSong
//                        {
//                            songsQueue.songArray.append(song)
//                        }
//                    }
//                }
//            }
    }
    
    func bcSongsQueueIdArrayUpdate(newValue: [String])
    {
        print(".onChange(of: bluetoothCentral.songsQueueIdArray) executed.")
        if bluetoothCentral.songsQueueIdArrayForcedUpdated
        {
//                var tempArray: [MusicPlayer.Queue.Entry] = []
//                for entry in ApplicationMusicPlayer.shared.queue.entries
//                {
//                    tempArray.append(entry)
//                }
//                ApplicationMusicPlayer.shared.queue.entries.
            
            print("bluetoothCentral.songsQueueIdArrayForcedUpdated == true")
            bluetoothCentral.songsQueueIdArrayForcedUpdated = false
            return
        }
        
        if bluetoothCentral.queueNext == true
        {
            Task
            {
                let aSong = await fetchSong(with: newValue[0])
                
                if let song = aSong
                {
                    songsQueue.songArray.insert(song, at: 0)
                    
                    Task
                    {
                        try await ApplicationMusicPlayer.shared.queue.insert(song, position: .afterCurrentEntry)
                    }
                    
                    // Keep, but seems to work without
                    songsQueue.queueNext = true
                }
            }
            
            bluetoothCentral.queueNext = false
        }
        else if bluetoothCentral.queueLast == true
        {
            Task
            {
                if let lastSong = newValue.last
                {
                    let aSong = await fetchSong(with: lastSong)
                    if let song = aSong
                    {
                        songsQueue.songArray.append(song)
                        
                        Task
                        {
                            try await ApplicationMusicPlayer.shared.queue.insert(song, position: .tail)
                        }
                        
                        // Keep, but seems to work without
                        songsQueue.queueLast = true
                    }
                }
            }
            
            bluetoothCentral.queueLast = false
        }
        else
        {
            print("As well as ...")
            
            print("As well as else.")
            let tempSongArray = songsQueue.songArray
            songsQueue.songArray = []
            
            for id in newValue
            {
                for aSong in tempSongArray
                {
                    if let song = aSong
                    {
                        if song.id.description == id
                        {
                            songsQueue.songArray.append(song)
                            break
                        }
                        else
                        {
                            continue
                        }
                    }
                    else
                    {
                        break
                    }
                }
            }
            
//            if bluetoothCentral.queueImported
//            {
//
//
//                //updateMusicPlayerEntries()
//
//                bluetoothCentral.queueImportedArray = []
//                bluetoothCentral.queueImported = false
//
//                //bluetoothCentral.queueOrder = false
//            }
        }
//        else
//        {
//            print("As well as ...")
//            if bluetoothCentral.queueImported
//            {
//                print("As well as else.")
//                let tempSongArray = songsQueue.songArray
//                songsQueue.songArray = []
//
//                for id in newValue
//                {
//                    for aSong in tempSongArray
//                    {
//                        if let song = aSong
//                        {
//                            if song.id.description == id
//                            {
//                                songsQueue.songArray.append(song)
//                                break
//                            }
//                            else
//                            {
//                                continue
//                            }
//                        }
//                        else
//                        {
//                            break
//                        }
//                    }
//                }
//
//                //updateMusicPlayerEntries()
//
//                bluetoothCentral.queueImportedArray = []
//                bluetoothCentral.queueImported = false
//
//                //bluetoothCentral.queueOrder = false
//            }
//        }
//            else
//            {
//                print("As well as else.")
//                let tempSongArray = songsQueue.songArray
//                songsQueue.songArray = []
//
//                for id in newValue
//                {
//                    for aSong in tempSongArray
//                    {
//                        if let song = aSong
//                        {
//                            if song.id.description == id
//                            {
//                                songsQueue.songArray.append(song)
//                                break
//                            }
//                            else
//                            {
//                                continue
//                            }
//                        }
//                        else
//                        {
//                            break
//                        }
//                    }
//                }
//
//                //bluetoothCentral.queueOrder = false
//            }
        
        bluetoothCentral.songsQueueIdArrayUpdatedByPeer = true
    }
    
    func bpCurrentSongChangedUpdate(newValue: Bool)
    {
        if newValue == true
        {
            Task
            {
                songsQueue.currentSong = await fetchSong(with: bluetoothPeripheral.currentSongID)
                bluetoothPeripheral.currentSongChanged = false
            }
        }
    }
    
    func bpHistorySongChangedUpdate(newValue: Bool)
    {
        if newValue == true
        {
            Task
            {
                songsQueue.history.append(await fetchSong(with: bluetoothPeripheral.historySongID))
                bluetoothPeripheral.historySongChanged = false
                
                print("History: \(songsQueue.history)")
            }
        }
    }
    
    func bpClearNowPlayingUpdate(newValue: Bool)
    {
        if newValue == true
        {
            songsQueue.currentSong = nil
            bluetoothPeripheral.clearNowPlaying = false
        }
    }
    
    func bpPreviousSongChangedUpdate(newValue: Bool)
    {
        if newValue == true
        {
            if bluetoothPeripheral.previousSongID == songsQueue.history.last??.id.description
            {
                songsQueue.songArray.insert(songsQueue.currentSong, at: 0)
                songsQueue.currentSong = songsQueue.history.removeLast()
                bluetoothPeripheral.previousSongChanged = false
                
                bluetoothPeripheral.queueOrder = true
            }
        }
    }
    
    func bpHistoryImportedUpdate(newValue: Bool)
    {
        if newValue == true
        {
            //songsQueue.history = []
            var tempArray: [Song?] = []
            
            Task
            {
                for songID in bluetoothPeripheral.historyImportedArray
                {
                    //songsQueue.history.append(await fetchSong(with: songID))
                    tempArray.append(await fetchSong(with: songID))
                }
                
                // songsQueue.history should change after work
                // is complete, not during.
                songsQueue.history = tempArray
                
                bluetoothPeripheral.historyImportedArray = []
                bluetoothPeripheral.historyImported = false
                print("History imported: \(songsQueue.history)")
                print("Last H song: \(songsQueue.history.last??.title ?? "nil")")
                bluetoothPeripheral.showingConnectingAlertBackup = false
            }
        }
    }
    
    func bpQueueImportedUpdate(newValue: Bool)
    {
        if newValue == true
        {
            //songsQueue.songArray = []
            var tempArray: [Song?] = []
            
            Task
            {
                for songID in bluetoothPeripheral.queueImportedArray
                {
                    //songsQueue.songArray.append(await fetchSong(with: songID))
                    tempArray.append(await fetchSong(with: songID))
                }
                
                // songsQueue.songArray should change after work
                // is complete, not during.
                songsQueue.songArray = tempArray
                
                bluetoothPeripheral.queueImportedArray = []
                bluetoothPeripheral.queueImported = false
                
                bluetoothPeripheral.showingConnectingAlert = false
                
                //bluetoothPeripheral.queueOrder = true
            }
        }
    }
    
    func songsQueueSongArrayUpdate(newValue: [Song?])
    {
        if bluetoothPeripheral.isPeering && !bluetoothPeripheral.queueNext && !bluetoothPeripheral.queueLast && !bluetoothPeripheral.queueOrder
        {
            print("Something is what you are on.")
            peerSongArrayUpdate1(newValue: newValue)
        }
        else if bluetoothPeripheral.isPeering
        {
            peerSongArrayUpdate2()
        }
        else if songsQueue.queueNext == true
        {
            hostSongArrayUpdateQueueNext(newValue: newValue)
        }
        else if songsQueue.queueLast == true
        {
            hostSongArrayUpdateQueueLast(newValue: newValue)
        }
        else
        {
            hostSongArrayUpdateQueueOrder(newValue: newValue)
        }
    }
    
    func notifyHostOfConnectingDevice()
    {
        let content = UNMutableNotificationContent()
        content.title = "Fusion"
        content.subtitle = "A device wants to connect."
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    func getTimeDifference(from startDate: Date, to endDate: Date) -> TimeInterval
    {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second], from: startDate, to: endDate)
        
        if let seconds = components.second
        {
            return TimeInterval(seconds)
        }
        else
        {
            return 0.0
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView(songsQueue: SongsQueue.shared, user: User(), library: Library())
    }
}







//print("songsQueue changed detected in ContentView")
//var idString = "SQID"
//for song in newValue
//{
//    idString.append("\(song!.id),")
//}
//if idString.last == ","
//{
//    idString.removeLast()
//}






//var songsArray: [Song] = []
//
//for aSong in newValue
//{
//    if let song = aSong
//    {
//        songsArray.append(song)
//    }
//}
//
//let jsonEncoder = JSONEncoder()
//if let jsonData = try? jsonEncoder.encode(songsArray)
//{
//    for peri in bluetoothCentral.connectedPeripherals.keys
//    {
//        for tc in bluetoothCentral.transferCharacteristics
//        {
//            peri.writeValue(jsonData, for: tc, type: .withoutResponse)
//            print("peri.writeValue executed")
//        }
//    }
//}
//
////            let data = try! JSONEncoder().encode(newValue)
////            let jsonString = String(data: data, encoding: .utf8)
////            print("Start here -> \(jsonString ?? "jsonString == nil")")
////            print("Start here 2 -> \(data)")
////
////            for peri in bluetoothCentral.connectedPeripherals.keys
////            {
////                for tc in bluetoothCentral.transferCharacteristics
////                {
////                    peri.writeValue(data, for: tc, type: .withoutResponse)
////                }
////            }







//else
//{
//    // Don't store more than 40 song id's in array
//    var textArray: [String] = []
//    var songIdString = "SQID"
//    print("May24 - 2")
//
//    var tempArray: [String] = []
//
//    for aSong in newValue
//    {
//        if let song = aSong
//        {
//            songIdString.append("\(song.id.description),")
//            print("\(songIdString)")
//
//            tempArray.append(song.id.description)
//        }
//    }
//
//    if songIdString.last == ","
//    {
//        songIdString.removeLast()
//    }
//
//    for peri in bluetoothCentral.connectedPeripherals.keys
//    {
//        for tc in bluetoothCentral.transferCharacteristics
//        {
//            textArray.append(songIdString)
//            let data = try! JSONEncoder().encode(textArray)
//            peri.writeValue(data, for: tc, type: .withoutResponse)
//
//            textArray = []
//        }
//    }
//
//    if bluetoothCentral.songsQueueIdArrayUpdatedByPeer
//    {
//        bluetoothCentral.songsQueueIdArrayUpdatedByPeer = false
//    }
//    else
//    {
//        // Need to force this to change
//        bluetoothCentral.songsQueueIdArray = tempArray
//        bluetoothCentral.songsQueueIdArrayForcedUpdated = true
//    }
//
//    // May29 - Start
//    var tempSongs: [Song?] = []
//    var ctr: Int = 0
//    var songsCount: Int = 0
//    var tempEntries: [MusicPlayer.Queue.Entry] = []
//
//    if !songsQueue.history.isEmpty
//    {
//        tempSongs += songsQueue.history
//        songsCount += songsQueue.history.count
//    }
//    if songsQueue.currentSong != nil
//    {
//        tempSongs.append(songsQueue.currentSong)
//        songsCount += 1
//    }
//    if !songsQueue.songArray.isEmpty
//    {
//        tempSongs += songsQueue.songArray
//    }
//
//    if ApplicationMusicPlayer.shared.queue.entries.count == tempSongs.count
//    {
//        for song in tempSongs
//        {
//            if ctr < songsCount
//            {
//                ctr += 1
//                continue
//            }
//
//            for entry in ApplicationMusicPlayer.shared.queue.entries
//            {
//                if song?.id == entry.item?.id
//                {
//                    let index = ApplicationMusicPlayer.shared.queue.entries.firstIndex(of: entry)
//                    tempEntries.append(ApplicationMusicPlayer.shared.queue.entries.remove(at: index!))
//                    break
//                }
//            }
//        }
//
//        ApplicationMusicPlayer.shared.queue.entries += tempEntries
//    }
//    else
//    {
//        var entryIndex: Int? = nil
//        var tempEntries: [MusicPlayer.Queue.Entry] = []
//
//        for entry in ApplicationMusicPlayer.shared.queue.entries
//        {
//            tempEntries.append(entry)
//        }
//
//        for song in tempSongs
//        {
//            if song?.id == tempEntries[0].item?.id
//            {
//                tempEntries.removeFirst()
//                continue
//            }
//            else
//            {
//                entryIndex = ApplicationMusicPlayer.shared.queue.entries.firstIndex(of: tempEntries[0])
//                break
//            }
//        }
//
//        if entryIndex != nil
//        {
//            ApplicationMusicPlayer.shared.queue.entries.remove(at: entryIndex!)
//            print("Delete succeeded!")
//        }
//        else
//        {
//            ApplicationMusicPlayer.shared.queue.entries.removeLast()
//            print("Delete succeeded!")
//        }
//    }
//    // May29 - Finish
//
////                var tempSongs: [Song?] = []
////                if !songsQueue.history.isEmpty
////                {
////                    tempSongs += songsQueue.history
////                }
////                if songsQueue.currentSong != nil
////                {
////                    tempSongs.append(songsQueue.currentSong)
////                }
////                if !songsQueue.songArray.isEmpty
////                {
////                    tempSongs += songsQueue.songArray
////                }
////
////                if ApplicationMusicPlayer.shared.queue.entries.count == tempSongs.count
////                {
////                    print("Count is equal")
////                    var entryIndex1: Int? = nil
////                    var entryIndex2: Int? = nil
////
////                    for entry in ApplicationMusicPlayer.shared.queue.entries
////                    {
////                        print("\(entry.item?.id) - \(tempSongs[0]?.id)")
////                        if entry.item?.id == tempSongs[0]?.id
////                        {
////                            tempSongs.removeFirst()
////                            continue
////                        }
////                        else
////                        {
////                            if entryIndex1 == nil
////                            {
////                                entryIndex1 = ApplicationMusicPlayer.shared.queue.entries.firstIndex(of: entry)
////                                tempSongs.removeFirst()
////                                continue
////                            }
////                            else
////                            {
////                                entryIndex2 = ApplicationMusicPlayer.shared.queue.entries.firstIndex(of: entry)
////                                break
////                            }
////                        }
////                    }
////
////                    if entryIndex1 != nil && entryIndex2 != nil
////                    {
////                        ApplicationMusicPlayer.shared.queue.entries.swapAt(entryIndex1!, entryIndex2!)
////                        print("Swap succeeded!")
////                    }
////                }
////                else
////                {
////                    var entryIndex: Int? = nil
////                    var tempEntries: [MusicPlayer.Queue.Entry] = []
////
////                    for entry in ApplicationMusicPlayer.shared.queue.entries
////                    {
////                        tempEntries.append(entry)
////                    }
////
////                    for song in tempSongs
////                    {
////                        if song?.id == tempEntries[0].item?.id
////                        {
////                            tempEntries.removeFirst()
////                            continue
////                        }
////                        else
////                        {
////                            entryIndex = ApplicationMusicPlayer.shared.queue.entries.firstIndex(of: tempEntries[0])
////                            break
////                        }
////                    }
////
////                    if entryIndex != nil
////                    {
////                        ApplicationMusicPlayer.shared.queue.entries.remove(at: entryIndex!)
////                        print("Delete succeeded!")
////                    }
////                    else
////                    {
////                        ApplicationMusicPlayer.shared.queue.entries.removeLast()
////                        print("Delete succeeded!")
////                    }
////                }
//
//    //ApplicationMusicPlayer.shared.queue.entries.mo
//
//    tempArray = []
//
//    songIdString = "SQID"
//}
