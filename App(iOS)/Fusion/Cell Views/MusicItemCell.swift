//
//  MusicItemCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/9/23.
//

import MusicKit
import SwiftUI

/// `MusicItemCell` is a view to use in a SwiftUI `List` to represent a `MusicItem`.
struct MusicItemCell: View
{
    // MARK: - Properties
    
    let artwork: Artwork?
    let title: String
    let subtitle: String
    
    // MARK: - View
    
    var body: some View
    {
        HStack
        {
            if let existingArtwork = artwork
            {
                VStack
                {
                    Spacer()
                    ArtworkImage(existingArtwork, width: 60, height: 60)
                        .cornerRadius(6)
                    Spacer()
                }
            }
            
            VStack(alignment: .leading)
            {
                Text(title)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                if !subtitle.isEmpty
                {
                    Text(subtitle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .padding(.top, -4.0)
                }
            }
        }
    }
}

//struct MusicItemCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        MusicItemCell()
//    }
//}
