//
//  PreviewCaptureViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 03/10/2023.
//

import UIKit
import AVKit

class PreviewCaptureViewController: UIViewController {
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Properties
    
    var currentPlayingVideoClip: VideoClips
    let recordingClips: [VideoClips]
    var viewWillDenitRestartVideoSession: (() -> Void)?
    
    var player: AVPlayer = AVPlayer()
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    var urlsForVids: [URL] = [] {
        didSet {
            print("DEBUG: OutputUrlLunwrapped", urlsForVids)
        }
    }
    
    var hideStatusBar: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideStatusBar = true
        handleStartPlayingFirstClip()
        
        setupView()
        
        recordingClips.forEach { clip in
            urlsForVids.append(clip.videoUrl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: animated)
        player.play()
        hideStatusBar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
        player.pause()
    }
    
    deinit {
        print("DEBUG: PreviewCaptureViewController was deinied")
        (viewWillDenitRestartVideoSession)?()
    }
    
    init?(coder: NSCoder, recordingClips: [VideoClips]) {
        self.currentPlayingVideoClip = recordingClips.first!
        self.recordingClips = recordingClips
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func avPlayerItemDidPlayToEndTime(notification: Notification) {
        if let currentIndex = recordingClips.firstIndex(of: currentPlayingVideoClip) {
            let nextIndex = currentIndex + 1
            
            if nextIndex > recordingClips.count - 1 {
                removePeriodicTimeObserver()
                
                guard let firstClip = recordingClips.first else { return }
                setupPlayerView(with: firstClip)
                currentPlayingVideoClip = firstClip
            } else {
                for (index, clip) in recordingClips.enumerated() {
                    if index == nextIndex {
                        removePeriodicTimeObserver()
                        setupPlayerView(with: clip)
                        currentPlayingVideoClip = clip
                    }
                }
            }
        }
    }
    
    // MARK: - @IBAction
    
    @IBAction func cancelButtonDidTapped(_ sender: Any) {
        hideStatusBar = true
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonDidTapped(_ sender: Any) {
        handleMergeClips()
        hideStatusBar = false
        
        let shareVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "SharePostViewController", creator: { coder -> SharePostViewController? in
            SharePostViewController(coder: coder, videoUrl: self.currentPlayingVideoClip.videoUrl)
        })
        
        shareVC.selectedPhoto = thumbnailImageView.image
        navigationController?.pushViewController(shareVC, animated: true)
        return
    }
    
    
    // MARK: - Helpers
    
    func setupView() {
        nextButton.layer.cornerRadius = 2
        nextButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 88/255, alpha: 1)
    }
    
    func handleStartPlayingFirstClip() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let firstClip = self.recordingClips.first else { return }
            self.currentPlayingVideoClip = firstClip
            self.setupPlayerView(with: firstClip)
        }
    }
    
    func setupPlayerView(with videoClip: VideoClips) {
        let player = AVPlayer(url: videoClip.videoUrl)
        let playerLayer = AVPlayerLayer(player: player)
        self.player = player
        self.playerLayer = playerLayer
        
        playerLayer.frame = thumbnailImageView.frame
        self.player = player
        self.playerLayer = playerLayer
        
        thumbnailImageView.layer.insertSublayer(playerLayer, at: 3)
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        handleMirrorPlayer(cameraPosition: videoClip.cameraPosition)
    }
    
    func removePeriodicTimeObserver() {
        player.replaceCurrentItem(with: nil)
        playerLayer.removeFromSuperlayer()
    }
    
    func handleMirrorPlayer(cameraPosition: AVCaptureDevice.Position) {
        if cameraPosition == .front {
            thumbnailImageView.transform = CGAffineTransform(scaleX: -1, y: -1)
        } else {
            thumbnailImageView.transform = .identity
        }
    }
    
    func handleMergeClips() {
        VideoCompositionWriter().mergeMultipleVideo(urls: urlsForVids) { success, outputURL in
            if success {
                guard let outputURLunwrapped = outputURL else { return }
                
                DispatchQueue.main.async {
                    let player = AVPlayer(url: outputURLunwrapped)
                    let vc = AVPlayerViewController()
                    vc.player = player
                    
                    self.present(vc, animated: true)
                }
            }
        }
    }

}
