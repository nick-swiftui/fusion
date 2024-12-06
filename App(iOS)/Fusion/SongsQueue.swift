//
//  SongsQueue.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/13/23.
//

//import Foundation
import SwiftUI
import MusicKit

class SongsQueue: ObservableObject//, Equatable
{
//    static func == (lhs: SongsQueue, rhs: SongsQueue) -> Bool
//    {
//        lhs.songArray == rhs.songArray
//    }
    
    // MARK: - Object lifecycle
    
    /// The shared instance of `SongsQueue`.
    static let shared = SongsQueue()
    
    // MARK: - Properties
    
//    /// An array of `String` using `id` from `Song` to create a queue list.
//    @Published var array = ["1065973707", "1452873021"]
    
    @Published var songArray = [Song?]()
    
    @Published var history = [Song?]()
    
    //@Published var currentSong
    
    @Published var queueNext = false
    @Published var queueLast = false
    //@Published var queueOrder = false
    
    @Published var currentSong: Song? = nil
    
    @Published var currentEntryChangedFromControlCenter = false
    @Published var currentEntryChangedFromInApp = false
    
    //@Published var playerEntriesOrderUpdated = false
    
    @Published var colors: [Color] = [.black, .black]
    @Published var newColors: [Color] = [.black, .black]
    
    @Published var standbySongs: [MusicItemCollection<Song>.Element] = []
}
