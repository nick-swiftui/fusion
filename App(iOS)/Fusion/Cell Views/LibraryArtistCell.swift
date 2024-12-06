//
//  LibraryArtistCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/28/23.
//

import SwiftUI
import MusicKit

struct LibraryArtistCell: View
{
    let artist: Artist
    
    var body: some View
    {
        HStack
        {
            if let artwork = artist.artwork
            {
                VStack
                {
                    Spacer()
                    ArtworkImage(artwork, width: 45, height: 45)
                        .clipShape(Circle())
                    Spacer()
                }
            }
            
            Text(artist.name)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

//struct LibraryArtistCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        LibraryArtistCell()
//    }
//}
