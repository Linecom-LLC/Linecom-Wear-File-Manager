//
//  AudioPlayerView.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import SwiftUI
import AVKit
import MediaPlayer

struct AudioPlayerView: View {
    var audioURL: URL
    @Environment(\.presentationMode) var presentationMode
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var timer: Timer?
    //@State private var scrollTimer: Timer?
    @State private var lrcContent: String = ""
    @State private var lrcLines: [LRCLine] = []
    @State private var currentLrcLineIndex: Int = 0

    @State private var songTitle: String = "未知标题"
    @State private var songArtist: String = "未知艺术家"
    @State private var albumName: String = "未知专辑"

    var body: some View {
        TabView {
            VStack {
                if let player = player {
                    VStack {
                        ZStack {
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
                            VolumeControlView().scaleEffect(0.5).position(x: 170, y: 50)
                        }

                        Text("\(songTitle)")
                        Text("\(songArtist) - \(albumName)")
                            .font(.custom("112", size: 11))
                        Text("\(formattedTime(currentTime)) / \(formattedTime(duration))")
                            .font(.custom("11", size: 10))

                        HStack {
                            Spacer()
                            Button(action: {
                                seek(by: -5)
                            }) {
                                Image(systemName: "gobackward.5")
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            Spacer()
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
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            Spacer()
                            Button(action: {
                                seek(by: 5)
                            }) {
                                Image(systemName: "goforward.5")
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            Spacer()
                        }
                    }
                    //.navigationTitle("Audio Preview")
                    //.navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        setupRemoteTransportControls()
                        setupNowPlaying()
                        loadLRCContent()
                        do {
                                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                                try AVAudioSession.sharedInstance().setActive(true)
                            } catch {
                                print(error)
                            }
                    }
                } else {
                    Text("Unable to load audio")
                        .onAppear {
                            let playerItem = AVPlayerItem(url: audioURL)
                            player = AVPlayer(playerItem: playerItem)
                            duration = CMTimeGetSeconds(playerItem.asset.duration)
                            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                currentTime = CMTimeGetSeconds(player?.currentTime() ?? CMTime.zero)
                                updateCurrentLRCLine()
                            }
                            fetchSongInfo()
                        }
                }
            }
            .tabItem {
                Label("Player", systemImage: "music.note")
            }

            VStack {
                if lrcLines.isEmpty {
                    Text("无可用歌词")
                        .padding()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack {
                                ForEach(Array(lrcLines.enumerated()), id: \.offset) { index, line in
                                    if index == currentLrcLineIndex {
                                    Text(line.text)
                                        .foregroundColor(.blue)
                                        .id(index)
                                        .font(.custom("LRCTextOn", size: 20))
                                        .onTapGesture {
                                            seekToTime(time: line.time)
                                        }
                                    } else {
                                        Text(line.text)
                                            .foregroundColor(.white)
                                            .id(index)
                                            .onTapGesture {
                                                seekToTime(time: line.time)
                                            }
                                    }
                                }
                            }
                        }
                        .onChange(of: currentLrcLineIndex) { index in
                            withAnimation {
                                proxy.scrollTo(index, anchor: .center)
                            }
                            //scrollTimer?.invalidate()
                            //scrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                            //    if currentLrcLineIndex < lrcLines.count {
                            //        seekToTime(time: lrcLines[currentLrcLineIndex].time)
                            //    }
                            //}
                        }
                    }
                }
            }
            .tabItem {
                Label("歌词", systemImage: "text.quote")
            }
        }
        .onDisappear(){
            player?.pause()
        }
    }

    func seek(by seconds: TimeInterval) {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + seconds
        let time = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: time)
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
    
    func fetchSongInfo() {
        let asset = AVAsset(url: audioURL)
        for metadataItem in asset.commonMetadata {
            switch metadataItem.commonKey {
            case .commonKeyTitle:
                songTitle = metadataItem.stringValue ?? "未知标题"
            case .commonKeyArtist:
                songArtist = metadataItem.stringValue ?? "未知艺术家"
            case .commonKeyAlbumName:
                albumName = metadataItem.stringValue ?? "未知专辑"
            default:
                break
            }
        }
    }
    
    func seekToTime(time: TimeInterval) {
            guard let player = player else { return }
            let cmTime = CMTime(seconds: time, preferredTimescale: 600)
            player.seek(to: cmTime)
            currentTime = time
        }

    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [self] event in
            if player?.rate == 0.0 {
                player?.play()
                isPlaying = true
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [self] event in
            if player?.rate == 1.0 {
                player?.pause()
                isPlaying = false
                return .success
            }
            return .commandFailed
        }

        commandCenter.skipForwardCommand.addTarget { [self] event in
            seek(by: 15)
            return .success
        }

        commandCenter.skipBackwardCommand.addTarget { [self] event in
            seek(by: -15)
            return .success
        }
    }

    func setupNowPlaying() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songTitle
        nowPlayingInfo[MPMediaItemPropertyArtist] = songArtist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = albumName

        if let artwork = getArtwork() {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { size in
                return artwork
            }
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func loadLRCContent() {
        if let lrcContent = FileManagerViewModel().getLrcContent(for: audioURL) {
            self.lrcContent = lrcContent
            self.lrcLines = LRCParser.parse(lrcContent)
        }
    }

    func updateCurrentLRCLine() {
        for (index, line) in lrcLines.enumerated() {
            if currentTime < line.time {
                currentLrcLineIndex = max(0, index - 1)
                break
            }
        }
    }
}

public struct VolumeControlView: WKInterfaceObjectRepresentable {
    public init() {
        
    }
    
    public typealias WKInterfaceObjectType = WKInterfaceVolumeControl
    
    public func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<VolumeControlView>) -> WKInterfaceVolumeControl {
        // Return the interface object that the view displays.
        return WKInterfaceVolumeControl(origin: .local)
    }
    
    public func updateWKInterfaceObject(_ map: WKInterfaceVolumeControl, context: WKInterfaceObjectRepresentableContext<VolumeControlView>) {
        
    }
}
