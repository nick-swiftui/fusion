//
//  NowPlayingMusicItemCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 6/16/23.
//

import SwiftUI
import MusicKit

struct NowPlayingMusicItemCell: View
{
    // MARK: - Properties
    
    let artwork: Artwork?
    let title: String
    let subtitle: String
    
    @ObservedObject var user: User
    
    // MARK: - View
    
    var body: some View
    {
        VStack
        {
            if let existingArtwork = artwork
            {
                HStack
                {
                    Spacer()
                    ArtworkImage(existingArtwork, width: 240, height: 240)
                        .cornerRadius(6)
                    Spacer()
                }
            }
            
            HStack
            {
                VStack(alignment: .leading)
                {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(user.appearance == "Light" ? .black : .white)
                    if !subtitle.isEmpty
                    {
                        Text(subtitle)
                            .font(.title3)
                            .lineLimit(1)
                            .foregroundColor(user.appearance == "Light" ? .black : .white)
                            .opacity(0.5)
                            .padding(.top, -4.0)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

//struct NowPlayingMusicItemCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        NowPlayingMusicItemCell()
//    }
//}
