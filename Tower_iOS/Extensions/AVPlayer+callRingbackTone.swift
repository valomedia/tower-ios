//
//  AVPlayer+callRingbackTone.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-09-16.
//

import Foundation
import AVFoundation


// MARK: AVPlayer

// MARK: + callRingbackTone

extension AVPlayer {
    
    /// An AVPlayer for a sound to play on loop while making a call.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static let callRingbackTone: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "call-ringback-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        let player = AVPlayer(url: url)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { _ in
                player.seek(to: CMTime.zero)
                player.play()
            }
        return player
    }()
    
}
