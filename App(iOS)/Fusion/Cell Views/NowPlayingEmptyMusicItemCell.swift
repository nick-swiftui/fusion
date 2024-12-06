//
//  NowPlayingEmptyMusicItemCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 6/16/23.
//

import SwiftUI

struct NowPlayingEmptyMusicItemCell: View
{
    @ObservedObject var user: User
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Spacer()
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 240)
                Spacer()
            }
            
            HStack
            {
                VStack(alignment: .leading)
                {
                    Text("Not Playing")
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(user.appearance == "Light" ? .black : .white)
                    Text(" ")
                        .font(.title3)
                        .lineLimit(1)
                        .foregroundColor(user.appearance == "Light" ? .black : .white)
                        .opacity(0.5)
                        .padding(.top, -4.0)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

//struct NowPlayingEmptyMusicItemCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        NowPlayingEmptyMusicItemCell()
//    }
//}
