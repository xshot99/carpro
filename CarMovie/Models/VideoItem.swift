import Foundation

struct VideoItem: Identifiable, Hashable, Comparable {
    let id: String
    let url: URL
    let fileName: String
    let fileSize: Int64
    let duration: TimeInterval
    let folderName: String

    var displayName: String {
        (fileName as NSString).deletingPathExtension
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: ".", with: " ")
    }

    var sizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    var timeFormatted: String {
        let h = Int(duration) / 3600
        let m = (Int(duration) % 3600) / 60
        let s = Int(duration) % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }

    static func < (lhs: VideoItem, rhs: VideoItem) -> Bool {
        lhs.fileName.localizedStandardCompare(rhs.fileName) == .orderedAscending
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool { lhs.id == rhs.id }
}
