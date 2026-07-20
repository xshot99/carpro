import CarPlay
import AVFoundation
import MediaPlayer
import UIKit

class CarPlaySceneDelegate: UIResponder {

    private var interfaceController: CPInterfaceController?
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var currentTitle: String = ""

    private func buildRootList() -> CPListTemplate {
        let vids = VideoManager.shared.videos

        if vids.isEmpty {
            let item = CPListItem(text: "No Videos Found",
                                  detailText: "Add via iTunes File Sharing",
                                  image: nil)
            item.handler = { _, _ in }
            let s = CPListSection(items: [item])
            let t = CPListTemplate(title: "CarMovie", sections: [s])
            t.delegate = self
            return t
        }

        let grouped = Dictionary(grouping: vids) { $0.folderName }
        var sections: [CPListSection] = []
        for folder in grouped.keys.sorted() {
            let fv = grouped[folder] ?? []
            let item = CPListItem(text: folder,
                                  detailText: "\(fv.count) videos",
                                  image: UIImage(systemName: "folder.fill"))
            item.accessoryType = .disclosureIndicator
            item.handler = { [weak self] _, done in
                self?.showFolder(folder, videos: fv)
                done()
            }
            sections.append(CPListSection(items: [item]))
        }
        let t = CPListTemplate(title: "CarMovie", sections: sections)
        t.delegate = self
        return t
    }

    private func showFolder(_ folder: String, videos: [VideoItem]) {
        var items: [CPListItem] = []
        for v in videos {
            let img = VideoManager.shared.thumbnail(for: v) ?? UIImage(systemName: "play.rectangle.fill")
            let item = CPListItem(text: v.displayName,
                                  detailText: "\(v.timeFormatted)  \(v.sizeFormatted)",
                                  image: img)
            item.handler = { [weak self] _, done in
                self?.play(v)
                done()
            }
            items.append(item)
        }
        let s = CPListSection(items: items)
        let t = CPListTemplate(title: folder, sections: [s])
        t.delegate = self
        interfaceController?.pushTemplate(t, animated: true, completion: nil)
    }

    private func play(_ video: VideoItem) {
        stopPlayback()
        currentTitle = video.displayName

        let p = AVPlayer(url: video.url)
        player = p

        let np = CPNowPlayingTemplate.shared
        np.isUpNextButtonEnabled = false
        np.isAlbumArtistButtonEnabled = false

        var info = np.nowPlayingInfo ?? [:]
        info[MPMediaItemPropertyTitle] = video.displayName
        info[MPMediaItemPropertyAlbumTitle] = video.folderName
        info[MPMediaItemPropertyPlaybackDuration] = video.duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

        if let img = VideoManager.shared.thumbnail(for: video, size: CGSize(width: 400, height: 400)) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
        }
        np.nowPlayingInfo = info
        np.add(self)

        timeObserver = p.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600),
                                                  queue: .main) { [weak self] t in
            guard let self, let pl = self.player else { return }
            var i = np.nowPlayingInfo ?? [:]
            i[MPNowPlayingInfoPropertyElapsedPlaybackTime] = t.seconds
            i[MPNowPlayingInfoPropertyPlaybackRate] = pl.rate
            np.nowPlayingInfo = i
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didFinish),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: p.currentItem)

        interfaceController?.pushTemplate(np, animated: true) { _, _ in p.play() }
    }

    private func stopPlayback() {
        if let o = timeObserver { player?.removeTimeObserver(o); timeObserver = nil }
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.pause(); player = nil
        CPNowPlayingTemplate.shared.remove(self)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    @objc private func didFinish() {
        player?.seek(to: .zero)
        player?.pause()
        var info = CPNowPlayingTemplate.shared.nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
        info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        CPNowPlayingTemplate.shared.nowPlayingInfo = info
        interfaceController?.popToRootTemplate(animated: true, completion: nil)
    }
}

extension CarPlaySceneDelegate: CPTemplateApplicationSceneDelegate {

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        VideoManager.shared.scanVideos()
        interfaceController.setRootTemplate(buildRootList(), animated: true, completion: nil)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
        stopPlayback()
    }
}

extension CarPlaySceneDelegate: CPListTemplateDelegate {

    func listTemplate(_ listTemplate: CPListTemplate,
                      didSelect item: CPListItem,
                      completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension CarPlaySceneDelegate: CPNowPlayingTemplateObserver {

    func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {}
    func nowPlayingTemplateAlbumArtistButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {}
}
