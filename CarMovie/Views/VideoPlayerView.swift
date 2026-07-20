import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let video: VideoItem
    @Environment(\.dismiss) var dismissAction
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let p = player {
                PlayerVC(player: p).ignoresSafeArea()
            } else {
                ProgressView().tint(.white)
            }
            VStack {
                HStack {
                    Button {
                        player?.pause(); player = nil; dismissAction()
                    } label: {
                        Image(systemName: "xmark.circle.fill").font(.title).foregroundColor(.white.opacity(0.8)).padding()
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            let p = AVPlayer(url: video.url)
            player = p
            p.play()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: p.currentItem, queue: .main) { _ in
                dismissAction()
            }
        }
        .onDisappear { player?.pause(); player = nil }
        .statusBar(hidden: true)
    }
}

private struct PlayerVC: UIViewControllerRepresentable {
    let player: AVPlayer
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = true
        vc.videoGravity = .resizeAspect
        return vc
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
