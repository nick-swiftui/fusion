//
//  SongVolumeView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/20/23.
//

import SwiftUI
import MediaPlayer

struct SongVolumeView: View
{
    var body: some View
    {
        SongVolumeViewRepresentable()
    }
}

struct SongVolumeViewRepresentable: UIViewRepresentable
{
    func makeUIView(context: Context) -> MPVolumeView
    {
        let volumeView = MPVolumeView(frame: .zero)
        //volumeView.showsRouteButton = false
        return volumeView
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context)
    {
        
    }
}

struct SongVolumeView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SongVolumeView()
    }
}
