//
//  LibraryPlaylistCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 8/2/23.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistCell: View
{
    let playlist: Playlist
    
    var body: some View
    {
        HStack
        {
            MusicItemCell(
                artwork: playlist.artwork,
                title: playlist.name,
                subtitle: playlist.curatorName ?? ""
            )
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
    }
}

//struct LibraryPlaylistCell_Previews: PreviewProvider {
//    static var previews: some View {
//        LibraryPlaylistCell()
//    }
//}
