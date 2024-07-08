//
//  ImageView.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import SwiftUI

struct ImageView: View {
    var imageURL: URL

    var body: some View {
        VStack {
            if let imageData = try? Data(contentsOf: imageURL),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .navigationTitle("图像预览")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("无法加载图像")
            }
        }
    }
}

