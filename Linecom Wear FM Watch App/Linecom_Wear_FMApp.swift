//
//  Linecom_Wear_MusicApp.swift
//  Linecom Wear Music Watch App
//
//  Created by 澪空 on 2024/2/25.
//

import SwiftUI

@main
struct Linecom_Wear_FM_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



struct TextFieldAlert<Presenting>: View where Presenting: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            if isPresented {
                presenting
                    .blur(radius: 2)
                VStack(spacing: 20) {
                    Text(title)
                        .font(.headline)
                    TextField("", text: $text)
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
                            onConfirm()
                        }
                    }
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .frame(maxWidth: 300)
            } else {
                presenting
            }
        }
    }
}
