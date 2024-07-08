//
//  VedioPreview.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    var videoURL: URL
    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL)){
        }
            .ignoresSafeArea()
            .frame(minHeight: 255)
            //.navigationTitle("Video Preview")
            //.navigationBarBackButtonHidden(true)
        Spacer()
    }
}

