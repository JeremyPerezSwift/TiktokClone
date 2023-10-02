//
//  VideoClips.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 30/09/2023.
//

import UIKit
import AVKit

struct VideoClips: Equatable {
    let videoUrl: URL
    let cameraPosition: AVCaptureDevice.Position
    
    init(videoUrl: URL, cameraPosition: AVCaptureDevice.Position) {
        self.videoUrl = videoUrl
        self.cameraPosition = cameraPosition
    }
    
    static func ==(lhs: VideoClips, rhs: VideoClips) -> Bool {
        return lhs.videoUrl == rhs.videoUrl && lhs.cameraPosition == rhs.cameraPosition
    }
}
