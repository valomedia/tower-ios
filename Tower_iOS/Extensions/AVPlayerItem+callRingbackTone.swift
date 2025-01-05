//
//  AVPlayerItem+callRingbackTone.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-01-05.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: AVPlayer

extension AVPlayerItem {

    // MARK: + callRingbackTone

    /// An AVPlayerItem for a sound to play on loop while making a call.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static let callRingbackTone: AVPlayerItem = {
        guard let url = Bundle.main.url(forResource: "call-ringback-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        return AVPlayerItem(url: url)
    }()

}
