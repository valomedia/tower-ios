//
//  AVPlayerItem+cameraSwitchTone.swift
//  Tower_iOS
//
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: AVPlayerItem

extension AVPlayerItem {

    // MARK: + cameraSwitchTone

    /// An AVPlayerItem for a sound to play once, when the camera is switched for privacy notification.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static var cameraSwitchTone: AVPlayerItem {
        guard let url = Bundle.main.url(forResource: "camera-switch-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        return AVPlayerItem(url: url)
    }

}
