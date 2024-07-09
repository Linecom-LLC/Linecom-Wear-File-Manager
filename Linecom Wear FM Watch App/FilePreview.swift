//
//  FilePreview.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import SwiftUI

struct FilePreviewSheet: View {
    @Binding var fileContent: String

    var body: some View {
        ScrollView {
            LazyVStack{
                Text(fileContent)
                    .padding()
            }
        }
        .navigationTitle("文本预览")
    }
}

