//
//  LibraryAlbumCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/28/23.
//

import SwiftUI
import MusicKit

struct LibraryAlbumCell: View
{
    @ObservedObject var user: User
    
    let artwork: Artwork?
    let title: String
    let artistName: String?
    let contentRating: ContentRating?
    
    var body: some View
    {
        VStack
        {
            if let existingArtwork = artwork
            {
                ArtworkImage(existingArtwork, width: 150)
                    .cornerRadius(6)
            }
            
            HStack
            {
                VStack(alignment: .leading)
                {
                    HStack
                    {
                        Text(title)
                            .lineLimit(1)

                        if let rating = contentRating
                        {
                            if rating == .explicit
                            {
                                Text("🅴")
                            }
                        }
                    }

                    if let artistName = artistName
                    {
                        Text(artistName)
                            .foregroundColor(user.appearance == "Light" ? .black : .white)
                            .opacity(0.5)
                            //.foregroundColor(Color.gray)
                            .lineLimit(1)
                    }
                    else
                    {
                        Text("n/a")
                            .foregroundColor(Color.gray)
                    }
                }
                //.frame(width: 150)

                Spacer()
            }
            .frame(width: 150)
        }
    }
}

//struct LibraryAlbumCell_Previews: PreviewProvider {
//    static var previews: some View {
//        LibraryAlbumCell()
//    }
//}
