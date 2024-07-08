//
//  AudioPlayerView.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import SwiftUI
import AVKit
import AVFoundation

struct AudioPlayerView: View {
    var audioURL: URL
    @Environment(\.presentationMode) var presentationMode
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isEditingSlider = false
    @State private var songTitle: String = "Unknown Title"
    @State private var songArtist: String = "Unknown Artist"
    @State private var albumName: String = "Unknown Album"

    var body: some View {
        VStack {
            if let player = player {
                VStack {
                    if let artwork = getArtwork() {
                        Image(uiImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding()
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                            .padding()
                    }

                    //Text("Audio Preview")
                    //    .font(.title)
                    //    .padding(
                    Text("\(songTitle)")
                    Text("\(songArtist)")
                        .font(.custom("112",size: 11))
                    Text("\(formattedTime(currentTime)) / \(formattedTime(duration))")
                        .font(.custom("11",size: 10))

                    HStack {
                        Button(action: {
                            seek(by: -5)
                        }) {
                            Image(systemName: "gobackward.5")
                        }
                        .frame(width: 30, height: 30)
                        //.background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                        
                        
                        
                        Button(action: {
                            if isPlaying {
                                player.pause()
                            } else {
                                player.play()
                            }
                            isPlaying.toggle()
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        
                        Button(action: {
                            seek(by: 5)
                        }) {
                            Image(systemName: "goforward.5")
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    }
                    .padding()
                }
                //.navigationTitle("Audio Preview")
                //.navigationBarTitleDisplayMode(.inline)
            } else {
                Text("Unable to load audio")
                    .onAppear {
                        do {
                            player = try AVAudioPlayer(contentsOf: audioURL)
                            duration = player?.duration ?? 0
                            player?.prepareToPlay()
                            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                if !isEditingSlider {
                                    currentTime = player?.currentTime ?? 0
                                }
                            }
                            fetchSongInfo()
                        } catch {
                            print("Error loading audio file: \(error)")
                        }
                        
                    }
            }
        }
    }

    func seek(by seconds: TimeInterval) {
        guard let player = player else { return }
        let newTime = player.currentTime + seconds
        if newTime < 0 {
            player.currentTime = 0
        } else if newTime > player.duration {
            player.currentTime = player.duration
        } else {
            player.currentTime = newTime
        }
        currentTime = player.currentTime
    }

    func getArtwork() -> UIImage? {
        let asset = AVAsset(url: audioURL)
        for metadataItem in asset.commonMetadata {
            if metadataItem.commonKey == .commonKeyArtwork, let data = metadataItem.value as? Data, let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }

    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    func fetchSongInfo() {
            let asset = AVAsset(url: audioURL)
            for metadataItem in asset.commonMetadata {
                switch metadataItem.commonKey {
                case .commonKeyTitle:
                    songTitle = metadataItem.stringValue ?? "Unknown Title"
                case .commonKeyArtist:
                    songArtist = metadataItem.stringValue ?? "Unknown Artist"
                case .commonKeyAlbumName:
                    albumName = metadataItem.stringValue ?? "Unknown Album"
                default:
                    break
                }
            }
        }
}
