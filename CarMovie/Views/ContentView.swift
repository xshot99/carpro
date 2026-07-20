import SwiftUI

struct ContentView: View {
    @StateObject private var vm = VideoManager.shared
    @State private var picked: VideoItem?
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            Group {
                if vm.videos.isEmpty && !vm.isLoading {
                    emptyView
                } else {
                    listView
                }
            }
            .navigationTitle("CarMovie")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button { vm.scanVideos() } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(vm.isLoading)
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .onAppear { vm.scanVideos() }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .fullScreenCover(item: $picked) { v in VideoPlayerView(video: v) }
        }
        .navigationViewStyle(.stack)
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "video.slash").font(.system(size: 60)).foregroundColor(.gray)
            Text("No Videos Found").font(.title2).fontWeight(.semibold)
            Text("Use iTunes File Sharing to add videos\nthen connect to CarPlay").multilineTextAlignment(.center).foregroundColor(.secondary)
            Button { vm.scanVideos() } label: {
                Label("Scan", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 30).padding(.vertical, 10)
                    .background(Color.blue).foregroundColor(.white).cornerRadius(10)
            }
            .disabled(vm.isLoading)
            if vm.isLoading { ProgressView().padding() }
            Spacer()
        }
    }

    private var listView: some View {
        List {
            ForEach(vm.folders, id: \.self) { folder in
                Section(header:
                    HStack {
                        Image(systemName: "folder.fill").foregroundColor(.yellow)
                        Text(folder).font(.headline)
                        Spacer()
                        Text("\(vm.videos(in: folder).count) videos").font(.caption).foregroundColor(.secondary)
                    }
                ) {
                    ForEach(vm.videos(in: folder)) { v in
                        VideoRow(video: v)
                            .contentShape(Rectangle())
                            .onTapGesture { picked = v }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay { if vm.isLoading { ProgressView().scaleEffect(1.2) } }
    }
}

struct VideoRow: View {
    let video: VideoItem
    @State private var thumb: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            thumbView.frame(width: 80, height: 45).cornerRadius(6)
            VStack(alignment: .leading, spacing: 4) {
                Text(video.displayName).font(.body).fontWeight(.medium).lineLimit(2)
                HStack(spacing: 12) {
                    Label(video.timeFormatted, systemImage: "clock")
                    Label(video.sizeFormatted, systemImage: "doc")
                }.font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "play.circle.fill").font(.title2).foregroundColor(.blue)
        }
        .padding(.vertical, 4)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let img = VideoManager.shared.thumbnail(for: video)
                DispatchQueue.main.async { thumb = img }
            }
        }
    }

    @ViewBuilder
    private var thumbView: some View {
        if let t = thumb {
            Image(uiImage: t).resizable().aspectRatio(contentMode: .fill)
        } else {
            ZStack {
                Color.black.opacity(0.2)
                Image(systemName: "play.rectangle.fill").font(.title2).foregroundColor(.gray)
            }
        }
    }
}
