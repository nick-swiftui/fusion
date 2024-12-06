//
//  FeaturedAlbumCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 6/21/23.
//

import SwiftUI
import MusicKit

struct FeaturedAlbumCell: View
{
    // MARK: - Properties
    
    let artwork: Artwork?
    let title: String
    
    var body: some View
    {
        HStack
        {
            if let existingArtwork = artwork
            {
                VStack
                {
                    Spacer()
                    ArtworkImage(existingArtwork, width: 120, height: 120)
                        .cornerRadius(6)
                    Spacer()
                }
            }
            
            VStack(alignment: .leading)
            {
                Text("FEATURED ALBUM")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                Text(title)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}

//struct FeaturedAlbumCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        FeaturedAlbumCell()
//    }
//}
