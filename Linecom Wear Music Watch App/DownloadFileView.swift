//
//  DownloadFileView.swift
//  Linecom Wear Music Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import SwiftUI

struct DownloadFileView: View {
    @EnvironmentObject var viewModel: FileManagerViewModel
    @State private var fileURL: String = "https://darock.storage.linecom.net.cn/darockbrowser/example/Shiroko.mp4"
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView{
            VStack {
                TextField("键入 URL", text: $fileURL)
                //.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("下载") {
                    if let url = URL(string: fileURL) {
                        viewModel.downloadFile(from: url) { error in
                            if let error = error {
                                alertMessage = "下载失败: \(error.localizedDescription)"
                            } else {
                                alertMessage = "下载成功"
                            }
                            showAlert = true
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("下载状态通知"), message: Text(alertMessage), dismissButton: .default(Text("好")))
                }
                //if viewModel.downloadProgress > 0.0 && viewModel.downloadProgress < 1.0 {
                VStack {
                    ProgressView(value: viewModel.downloadProgress)
                        .padding()
                    Text("\(Int(viewModel.downloadProgress * 100))%")
                    Text("\(viewModel.downloadedBytes / 1_048_576) MB / \(viewModel.totalBytes / 1_048_576) MB")
                }
                .padding()
                //}
                Spacer()
            }
            .padding()
            .navigationTitle("下载文件")
        }
    }
}




#Preview {
    DownloadFileView()
}
