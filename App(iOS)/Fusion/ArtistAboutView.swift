//
//  ArtistAboutView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 6/21/23.
//

import SwiftUI
import MusicKit

struct ArtistAboutView: View
{
    // MARK: - Object lifecycle
    
    init(_ artist: Artist)
    {
        self.artist = artist
    }
    
    // MARK: - Properties
    
    /// The artist that this view represents.
    let artist: Artist
    
    // MARK: - View
    
    var body: some View
    {
        VStack
        {
            Text("About")
                .font(.title2)
                .fontWeight(.bold)
            
            if let editorialNotes = artist.editorialNotes
            {
                Text(editorialNotes.standard!)
            }
            else
            {
                Text("nil")
            }
        }
    }
}

//struct ArtistAboutView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        ArtistAboutView()
//    }
//}
