//
//  ImageView.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import SwiftUI

struct ImageView: View {
    var imageURL: URL
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @FocusState private var isImageZoomFocused: Bool

    var body: some View {
        VStack {
            if let imageData = try? Data(contentsOf: imageURL),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                offset.width += value.translation.width
                                offset.height += value.translation.height
                            }
                    )
                    .focusable(true)
                    .digitalCrownRotation($scale, from: 1.0, through: 5.0, by: 0.1, sensitivity: .medium, isHapticFeedbackEnabled: true)
                    .padding()
            } else {
                Text("Unable to load image")
            }
        }
        .navigationTitle("图像预览")
        .navigationBarTitleDisplayMode(.inline)
    }
}

