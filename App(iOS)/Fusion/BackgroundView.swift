//
//  BackgroundView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 6/26/23.
//

import SwiftUI

import ColorKit

struct BackgroundView: View
{
    @ObservedObject var user: User
    @ObservedObject var songsQueue: SongsQueue
    
    @State private var colors: [Color]
    @State private var newColors: [Color]
    @State private var progress: CGFloat = 0
        
    init(user: User, songsQueue: SongsQueue)
    {
        self.user = user
        self.songsQueue = songsQueue
        self.colors = songsQueue.colors
        self.newColors = songsQueue.newColors
    }
    
    var body: some View
    {
        if user.appearance == "Light"
        {
            Rectangle()
                .animatableGradient(fromGradient: Gradient(colors: [.white, .white]), toGradient: Gradient(colors: [.white, .white]), progress: progress)
                .ignoresSafeArea()
                .onChange(of: newColors)
                { newValue in
                    withAnimation
                    {
                        self.progress = 1.0
                    }
                }
        }
        else if user.appearance == "Dark"
        {
            Rectangle()
                .animatableGradient(fromGradient: Gradient(colors: [.black, .black]), toGradient: Gradient(colors: [.black, .black]), progress: progress)
                .ignoresSafeArea()
                .onChange(of: newColors)
                { newValue in
                    withAnimation
                    {
                        self.progress = 1.0
                    }
                }
        }
        else if user.appearance == "Dynamic"
        {
            Rectangle()
                .animatableGradient(fromGradient: Gradient(colors: colors), toGradient: Gradient(colors: newColors), progress: progress)
                .ignoresSafeArea()
                .onChange(of: newColors)
                { newValue in
                    withAnimation
                    {
                        self.progress = 1.0
                    }
                }
                .onChange(of: songsQueue.currentSong)
                { newValue in
                    if let artwork = songsQueue.currentSong?.artwork
                    {
                        Task
                        {
                            do
                            {
                                guard let artworkURL = artwork.url(width: 640, height: 640) else { return }
                                
                                let (imageData, _) = try await URLSession.shared.data(from: artworkURL)
                                                    
                                guard let image = UIImage(data: imageData) else { return }
                                
                                let colors = try image.dominantColors(algorithm: .iterative).map {Color(uiColor: $0)}
                                
                                var tempColors: [Color] = []
                                
                                if colors.count > 1
                                {
                                    for i in 0..<2
                                    {
                                        tempColors.append(colors[i])
                                    }
                                }
                                else
                                {
                                    tempColors.append(colors.first!)
                                    tempColors.append(colors.first!)
                                }

                                self.colors = newColors
                                self.progress = 0.0
                                self.newColors = tempColors
                                
                                self.songsQueue.colors = tempColors
                                self.songsQueue.newColors = tempColors
                            }
                            catch
                            {
                                print(error)
                            }
                        }
                    }
                    else
                    {
                        self.colors = [.black, .black]
                        self.progress = 0.0
                        self.newColors = [.black, .black]
                        
                        self.songsQueue.colors = [.black, .black]
                        self.songsQueue.newColors = [.black, .black]
                    }
                }
                .onAppear
                {
                    print("BackgroundView appeared!")
                }
        }
    }
}

//struct BackgroundView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        BackgroundView(user: User(), songsQueue: SongsQueue())
//    }
//}





struct AnimatableGradientModifier: AnimatableModifier {
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0
 
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
 
    func body(content: Content) -> some View {
        var gradientColors = [Color]()
 
        for i in 0..<fromGradient.stops.count {
            let fromColor = UIColor(fromGradient.stops[i].color)
            let toColor = UIColor(toGradient.stops[i].color)
 
            gradientColors.append(colorMixer(fromColor: fromColor, toColor: toColor, progress: progress))
        }
 
        return LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
    }
 
    func colorMixer(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color {
        guard let fromColor = fromColor.cgColor.components else { return Color(fromColor) }
        guard let toColor = toColor.cgColor.components else { return Color(toColor) }
 
        let red = fromColor[0] + (toColor[0] - fromColor[0]) * progress
        let green = fromColor[1] + (toColor[1] - fromColor[1]) * progress
        let blue = fromColor[2] + (toColor[2] - fromColor[2]) * progress
 
        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

extension View {
    func animatableGradient(fromGradient: Gradient, toGradient: Gradient, progress: CGFloat) -> some View {
        self.modifier(AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress))
    }
}
