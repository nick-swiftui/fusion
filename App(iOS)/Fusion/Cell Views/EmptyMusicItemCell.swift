//
//  EmptyMusicItemCell.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/19/23.
//

import SwiftUI

struct EmptyMusicItemCell: View
{
    var body: some View
    {
        HStack
        {
            VStack
            {
                Spacer()
                Image(systemName: "questionmark.app")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(6)
                Spacer()
            }
            
            VStack(alignment: .leading)
            {
                Text("Not Playing")
                    .lineLimit(1)
                    .foregroundColor(.primary)
                Text(" ")
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                    .padding(.top, -4.0)
            }
            
            Spacer()
        }
    }
}

//struct EmptyMusicItemCell_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        EmptyMusicItemCell()
//    }
//}
