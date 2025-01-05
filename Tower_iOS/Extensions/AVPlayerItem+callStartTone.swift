//
//  AVPlayerItem+callStartTone.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-09-16.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: AVPlayerItem

extension AVPlayerItem {

    // MARK: + callStartTone

    /// An AVPlayerItem for a sound to play once, when the assistant joins the call.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static let callStartTone: AVPlayerItem = {
        guard let url = Bundle.main.url(forResource: "call-start-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        return AVPlayerItem(url: url)
    }()

}
