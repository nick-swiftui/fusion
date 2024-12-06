//
//  SongProgressView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/20/23.
//

import SwiftUI
import MusicKit

struct SongProgressView: View
{
    @State private var progressAmount = 0.0
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    private let player = ApplicationMusicPlayer.shared
    
    let song: Song?
    
    @State private var currentTime: TimeInterval = 0
    
    var body: some View
    {
        if let currentSong = song
        {
            let secondsLeft = Int(currentSong.duration! - player.playbackTime) % 60
            let minutesLeft = Int(currentSong.duration! - player.playbackTime) / 60
            let secondsPassed = Int(player.playbackTime) % 60
            let minutesPassed = Int(player.playbackTime) / 60
            
            VStack
            {
                ProgressView(
                    "",
                    value: progressAmount,
                    total: currentSong.duration!
                )
                .onReceive(
                    timer,
                    perform:
                        {_ in
                            progressAmount = player.playbackTime// / currentSong.duration!
                        }
                )
                //.animation(.default, value: <#T##Equatable#>)
                
                //Slider(value: $currentTime, in: 0...300)
                
                HStack
                {
                    Text("\(minutesPassed):\(secondsPassed < 10 ? "0\(secondsPassed)" : "\(secondsPassed)")")
                    Spacer()
                    Text("-\(minutesLeft):\(secondsLeft < 10 ? "0\(secondsLeft)" : "\(secondsLeft)")")
                }
            }
        }
        else
        {
            VStack
            {
                ProgressView("", value: 0)
                
                //Slider(value: $currentTime, in: 0...300)
                
                HStack
                {
                    Text("--:--")
                    Spacer()
                    Text("--:--")
                }
            }
        }
    }
}

struct SongProgressView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SongProgressView(song: nil)
    }
}





//struct NoKnobSliderStyle: SliderStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        VStack {
//            SliderTrack(configuration: configuration)
//        }
//    }
//
//    private struct SliderTrack: View {
//        let configuration: NoKnobSliderStyle.Configuration
//
//        @Environment(\.isEnabled) private var isEnabled
//
//        var body: some View {
//            ZStack {
//                Capsule()
//                    .fill(Color.secondary.opacity(0.3))
//                if isEnabled {
//                    Capsule()
//                        .fill(Color.accentColor)
//                        .frame(width: configuration.width * CGFloat(configuration.normalizedValue))
//                }
//            }
//            .frame(height: 4)
//        }
//    }
//}
