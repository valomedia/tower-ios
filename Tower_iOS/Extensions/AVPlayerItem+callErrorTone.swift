//
//  AVPlayerItem+callErrorTone.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-01-05.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: AVPlayerItem

extension AVPlayerItem {

    // MARK: + callErrorTone

    /// An AVPlayerItem for a sound to play once, when the call either fails to connect, or is disconnected unexpectedly.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static let callErrorTone: AVPlayerItem = {
        guard let url = Bundle.main.url(forResource: "call-error-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        return AVPlayerItem(url: url)
    }()

}
