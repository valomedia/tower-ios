//
//  AVPlayer+callErrorTone.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-09-16.
//

import Foundation
import AVFoundation


// MARK: AVPlayer

// MARK: + callErrorTone

extension AVPlayer {
    
    /// An AVPlayer for a sound to play once, when the call either fails to connect, or is disconnected unexpectedly.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static let callErrorTone: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "call-error-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        return AVPlayer(url: url)
    }()
    
}
