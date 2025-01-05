//
//  AVPlayerItem+callEndTone.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-01-05.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: AVPlayerItem

extension AVPlayerItem {

    // MARK: + callEndTone

    /// An AVPlayerItem for a sound to play once, when the call ends normally.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static let callEndTone: AVPlayerItem = {
        guard let url = Bundle.main.url(forResource: "call-end-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        return AVPlayerItem(url: url)
    }()

}
