//
//  FMViewMoudel.swift
//  Linecom Wear Music Watch App
//
//  Created by 澪空 on 2024/7/8.
//

import Foundation
import Alamofire

class FileManagerViewModel: ObservableObject {
    @Published var files: [String] = []
    @Published var downloadProgress: Double = 0.0
    @Published var downloadedBytes: Int64 = 0
    @Published var totalBytes: Int64 = 0

    private let fileManager = FileManager.default
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    func listFiles() {
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
            DispatchQueue.main.async {
                self.files = filePaths
            }
        } catch {
            print("Error listing files: \(error)")
        }
    }

    func deleteFile(atOffsets offsets: IndexSet) {
        for index in offsets {
            let file = files[index]
            let filePath = documentsDirectory.appendingPathComponent(file)
            do {
                try fileManager.removeItem(at: filePath)
                listFiles()
            } catch {
                print("Error deleting file: \(error)")
            }
        }
    }

    func renameFile(at index: Int, to newName: String) {
        let oldFileName = files[index]
        let oldFilePath = documentsDirectory.appendingPathComponent(oldFileName)
        let newFilePath = documentsDirectory.appendingPathComponent(newName)

        do {
            try fileManager.moveItem(at: oldFilePath, to: newFilePath)
            listFiles()
        } catch {
            print("Error renaming file: \(error)")
        }
    }

    func readFileContent(at index: Int) -> String? {
        let fileName = files[index]
        let filePath = documentsDirectory.appendingPathComponent(fileName)
        do {
            return try String(contentsOf: filePath, encoding: .utf8)
        } catch {
            print("Error reading file content: \(error)")
            return nil
        }
    }

    func getFileURL(at index: Int) -> URL? {
        let fileName = files[index]
        return documentsDirectory.appendingPathComponent(fileName)
    }
    func isTextFile(at index: Int) -> Bool {
        let fileName = files[index]
        let textExtenions = ["txt", "lrc", "htm", "html", "xml"]
        return textExtenions.contains { fileName.lowercased().hasSuffix($0) }
    }

    func isVideoFile(at index: Int) -> Bool {
        let fileName = files[index]
        let videoExtensions = ["mp4", "mov", "m4v"]
        return videoExtensions.contains { fileName.lowercased().hasSuffix($0) }
    }
    
    func isImageFile(at index: Int) -> Bool {
        let fileName = files[index]
        let imageExtensions = ["jpg", "jpeg", "png", "gif"]
        return imageExtensions.contains { fileName.lowercased().hasSuffix($0) }
    }

    func isAudioFile(at index: Int) -> Bool {
        let fileName = files[index]
        let audioExtensions = ["mp3", "wav", "m4a", "aac"]
        return audioExtensions.contains { fileName.lowercased().hasSuffix($0) }
    }

    func downloadFile(from url: URL, completion: @escaping (Error?) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = self.documentsDirectory.appendingPathComponent(url.lastPathComponent)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        AF.download(url, to: destination)
            .downloadProgress { progress in
                DispatchQueue.main.async {
                    self.downloadProgress = progress.fractionCompleted
                    self.downloadedBytes = progress.completedUnitCount
                    self.totalBytes = progress.totalUnitCount
                }
            }
            .response { response in
                if let error = response.error {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.listFiles()
                        self.downloadProgress = 0.0
                        self.downloadedBytes = 0
                        self.totalBytes = 0
                        completion(nil)
                    }
                }
            }
    }
    
    func getLrcContent(for audioFileURL: URL) -> String? {
        let lrcFileName = audioFileURL.deletingPathExtension().appendingPathExtension("lrc")
        let lrcFilePath = documentsDirectory.appendingPathComponent(lrcFileName.lastPathComponent)
        do {
            return try String(contentsOf: lrcFilePath, encoding: .utf8)
        } catch {
            print("Error reading lrc file content: \(error)")
            return nil
        }
    }
}
