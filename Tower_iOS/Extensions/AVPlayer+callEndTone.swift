//
//  AVPlayer+callEndTone.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-09-16.
//

import Foundation
import AVFoundation


// MARK: AVPlayer

// MARK: + callEndTone

extension AVPlayer {
    
    /// An AVPlayer for a sound to play once, when the call ends normally.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static let callEndTone: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "call-end-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        return AVPlayer(url: url)
    }()
    
}
