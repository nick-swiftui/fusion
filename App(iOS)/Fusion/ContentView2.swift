//
//  ContentView2.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/9/23.
//

import MusicKit
import SwiftUI

struct ContentView2: View
{
    @State var isAuthorizedForMusicKit = false
    @State var musicSubscription: MusicSubscription?
    
    private let player = ApplicationMusicPlayer.shared
    
    var body: some View
    {
        Text("Hello, world!")
//        VStack
//        {
//            HStack
//            {
//                Image(<#T##name: String##String#>)
//                VStack
//                {
//                    Text(<#T##attributedContent: AttributedString##AttributedString#>)
//                    Text(<#T##attributedContent: AttributedString##AttributedString#>)
//                }
//            }
//
//            Button(action: handlePlayButtonSelected)
//            {
//                Image(systemName: "play.fill")
//            }
//            .disabled(!(musicSubscription?.canPlayCatalogContent ?? false))
//            .task
//            {
//                for await subscription in MusicSubscription.subscriptionUpdates
//                {
//                    musicSubscription = subscription
//                }
//            }
//        }
    }
    
    func requestMusicAuthorization()
    {
        Task.detached
        {
            let authorizationStatus = await MusicAuthorization.request()
            if authorizationStatus == .authorized
            {
                isAuthorizedForMusicKit = true
            }
            else
            {
                // User denied permission.
            }
        }
    }
    
    func handlePlayButtonSelected()
    {
        
    }
}

struct ContentView2_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView2()
    }
}
