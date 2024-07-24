//
//  CloudCodeView.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/24.
//

import SwiftUI

struct CloudCodeView: View {
    @EnvironmentObject var viewModel: FileManagerViewModel
    @State private var code: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView{
            VStack {
                TextField("键入传输码", text: $code)
                //.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("下载") {
                    if let url = URL(string: "https://api.linecom.net.cn/fmutils/file?code=\(code)") {
                        viewModel.downloadFile(from: url) { error in
                            if let error = error {
                                alertMessage = "传输失败: \(error.localizedDescription)"
                            } else {
                                alertMessage = "传输成功"
                            }
                            showAlert = true
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("传输状态通知"), message: Text(alertMessage), dismissButton: .default(Text("好")))
                }
                //if viewModel.downloadProgress > 0.0 && viewModel.downloadProgress < 1.0 {
                VStack {
                    ProgressView(value: viewModel.downloadProgress)
                        .padding()
                    Text("\(Int(viewModel.downloadProgress * 100))%")
                    Text("\(viewModel.downloadedBytes / 1_048_576) MB / \(viewModel.totalBytes / 1_048_576) MB")
                }
                //}
                Spacer()
            }
            .navigationTitle("传输文件")
        }
    }
}

#Preview {
    CloudCodeView()
}
