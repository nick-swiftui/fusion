//
//  FusionApp.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/9/23.
//

import SwiftUI

/// `MusicAlbumsApp` conforms to the SwiftUI `App` protocol, and configures the overall appearance of the app.
@main
struct FusionApp: App
{
    //@StateObject var songsQueue = SongsQueue.shared
    //@ObservedObject var songsQueue: SongsQueue
    @StateObject var songsQueue = SongsQueue()
    
    @StateObject var user = User()
    
    @StateObject var library = Library()
    
    var body: some Scene
    {
        WindowGroup
        {
            if user.readyToGo
            {
                //ContentView(songsQueue: songsQueue)
                ContentView(songsQueue: songsQueue, user: user, library: library)
                //SongsQueueView(songsQueue: songsQueue)
            }
            else
            {
                Text("Welcome Text")
                    .welcomeSheet(user: user)
            }
        }
    }
}


// MARK: - Notes

// Remember to uncomment .welcomeSheet() in HomeView
