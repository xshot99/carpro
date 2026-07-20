import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismissAction
    @State private var videoCount = 0
    @State private var totalSize: Int64 = 0

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Storage")) {
                    HStack {
                        Label("Total Videos", systemImage: "video.fill")
                        Spacer()
                        Text("\(videoCount)").foregroundColor(.secondary)
                    }
                    HStack {
                        Label("Total Size", systemImage: "internaldrive.fill")
                        Spacer()
                        Text(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file))
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Mazda Controls")) {
                    Label("Rotate knob: Navigate list", systemImage: "circle.circle")
                    Label("Press knob: Select / Play", systemImage: "hand.point.up.fill")
                    Label("Back button: Return", systemImage: "arrow.left.circle")
                    Label("Now Playing: Playback controls", systemImage: "play.circle")
                }

                Section(header: Text("About")) {
                    HStack { Text("Version"); Spacer(); Text("2.0").foregroundColor(.secondary) }
                    HStack { Text("Developer"); Spacer(); Text("Dcsyhi").foregroundColor(.secondary) }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismissAction() }
                }
            }
            .onAppear {
                let m = VideoManager.shared
                videoCount = m.videos.count
                totalSize = m.videos.reduce(0) { $0 + $1.fileSize }
            }
        }
    }
}
