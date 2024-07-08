//
//  RenameFileSheet.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import SwiftUI

struct RenameFileSheet: View {
    @Binding var isPresented: Bool
    @Binding var newFileName: String
    var onRename: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Rename File")
                .font(.headline)
            TextField("New file name", text: $newFileName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Button("Rename") {
                    isPresented = false
                    onRename()
                }
            }
            .padding()
        }
        .padding()
    }
}


