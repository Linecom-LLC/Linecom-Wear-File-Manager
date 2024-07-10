//
//  ContentView.swift
//  Linecom Wear Music Watch App
//
//  Created by 澪空 on 2024/2/25.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var viewModel = FileManagerViewModel()
    @State private var isRenameSheetPresented = false
    @State private var isDeleteAlertPresented = false
    @State private var isFilePreviewSheetPresented = false
    @State private var isDownloadFileSheetPresented = false
    @State private var isAboutSheetPresented = false
    @State private var newFileName = ""
    @State private var selectedFileIndex: Int?
    @State private var fileToDeleteIndex: Int?
    @State private var fileContent: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(Array(viewModel.files.enumerated()), id: \.offset) { index, file in
                        HStack {
                            if viewModel.isVideoFile(at: index) {
                                NavigationLink(destination: VideoPlayerView(videoURL: viewModel.getFileURL(at: index)!)) {
                                    Text(file)
                                }
                            } else if viewModel.isImageFile(at: index) {
                                NavigationLink(destination: ImageView(imageURL: viewModel.getFileURL(at: index)!)) {
                                    Text(file)
                                }
                            } else if viewModel.isAudioFile(at: index) {
                                NavigationLink(destination: AudioPlayerView(audioURL: viewModel.getFileURL(at: index)!)) {
                                    Text(file)
                                }
                            } else {
                                Text(file)
                                    .onTapGesture {
                                        if let content = viewModel.readFileContent(at: index) {
                                            fileContent = content
                                            isFilePreviewSheetPresented = true
                                        }
                                    }
                            }
                            Spacer()
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                fileToDeleteIndex = index
                                isDeleteAlertPresented = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                selectedFileIndex = index
                                newFileName = file
                                isRenameSheetPresented = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .onAppear {
                    viewModel.listFiles()
                }
                .sheet(isPresented: $isRenameSheetPresented) {
                    RenameFileSheet(
                        isPresented: $isRenameSheetPresented,
                        newFileName: $newFileName,
                        onRename: {
                            if let index = selectedFileIndex {
                                viewModel.renameFile(at: index, to: newFileName)
                            }
                        }
                    )
                }
                .sheet(isPresented: $isFilePreviewSheetPresented) {
                    FilePreviewSheet(fileContent: $fileContent)
                }
                .sheet(isPresented: $isDownloadFileSheetPresented) {
                                    DownloadFileView()
                                        .environmentObject(viewModel)
                                }
                .sheet(isPresented: $isAboutSheetPresented) {
                    AboutView()
                }
                .alert(isPresented: $isDeleteAlertPresented) {
                    Alert(
                        title: Text("删除确认"),
                        message: Text("您是否要删除此文件？"),
                        primaryButton: .destructive(Text("删除")) {
                            if let index = fileToDeleteIndex {
                                viewModel.deleteFile(atOffsets: IndexSet(integer: index))
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationTitle("文件")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                                Button(action: {
                                    isDownloadFileSheetPresented = true
                                }) {
                                    Image(systemName: "square.and.arrow.down")
                                }
                            }
                ToolbarItem(placement: .topBarTrailing) {
                                Button(action: {
                                    isAboutSheetPresented = true
                                }) {
                                    Image(systemName: "info.circle")
                                }
                            }
                        }
        }
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

