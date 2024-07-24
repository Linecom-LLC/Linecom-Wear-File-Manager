//
//  MixedImportView.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/24.
//

import SwiftUI

struct MixedImportView: View {
    var body: some View {
        TabView {
            DownloadFileView()
            CloudCodeView()
        }
    }
}

#Preview {
    MixedImportView()
}
