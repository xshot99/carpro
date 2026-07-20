import Foundation
import AVFoundation
import UIKit

final class VideoManager: ObservableObject {
    static let shared = VideoManager()

    @Published var videos: [VideoItem] = []
    @Published var folders: [String] = []
    @Published var isLoading = false

    private let fm = FileManager.default
    private let exts: Set<String> = [
        "mp4","mov","m4v","avi","mkv","mpg","mpeg","mpe","m1v","m2v",
        "3gp","3gpp","3gpp2","wmv","flv","f4v","webm","ts","mts","m2ts","vob","divx"
    ]

    var docsURL: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private init() {}

    func scanVideos() {
        isLoading = true
        defer { isLoading = false }

        var found: [VideoItem] = []
        var folders = Set<String>()

        guard let en = fm.enumerator(at: docsURL,
                                     includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                                     options: [.skipsHiddenFiles])
        else { self.videos = []; self.folders = []; return }

        for case let url as URL in en {
            guard let res = try? url.resourceValues(forKeys: [.isDirectoryKey]),
                  res.isDirectory == false,
                  exts.contains(url.pathExtension.lowercased())
            else { continue }

            let rel = url.path.replacingOccurrences(of: docsURL.path + "/", with: "")
            let folder: String
            if let slash = rel.range(of: "/") {
                folder = String(rel[..<slash.lowerBound])
            } else {
                folder = "Root"
            }
            folders.insert(folder)

            let name = url.lastPathComponent
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize.map(Int64.init) ?? 0
            let d = AVURLAsset(url: url).duration.seconds

            found.append(VideoItem(
                id: url.path,
                url: url,
                fileName: name,
                fileSize: size,
                duration: d.isFinite ? d : 0,
                folderName: folder
            ))
        }
        found.sort()
        videos = found
        self.folders = Array(folders).sorted()
    }

    func videos(in folder: String) -> [VideoItem] {
        videos.filter { $0.folderName == folder }
    }

    func thumbnail(for video: VideoItem, size: CGSize = CGSize(width: 160, height: 90)) -> UIImage? {
        let asset = AVURLAsset(url: video.url)
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        gen.maximumSize = size
        do {
            let cg = try gen.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 600), actualTime: nil)
            return UIImage(cgImage: cg)
        } catch { return nil }
    }
}
