//
//  ArtistAlbumCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 6/21/23.
//

import SwiftUI
import MusicKit

struct ArtistAlbumCell: View
{
    let artwork: Artwork?
    let title: String
    let releaseDate: Date?
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

                    if let date = releaseDate
                    {
                        Text(Calendar.current.dateComponents([.year], from: date).year!.description)
                            .foregroundColor(Color.gray)
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

//struct ArtistAlbumCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtistAlbumCell()
//    }
//}





//HStack
//{
//    VStack(alignment: .leading)
//    {
//        HStack
//        {
//            Text(title)
//                .lineLimit(1)
//
//            if let rating = contentRating
//            {
//                if rating == .explicit
//                {
//                    Text("🅴")
//                }
//            }
//        }
//
//        if let date = releaseDate
//        {
//            Text(Calendar.current.dateComponents([.year], from: date).year!.description)
//                .foregroundColor(Color.gray)
//        }
//    }
//    //.frame(width: 150)
//
//    Spacer()
//}
//.frame(width: 150)
