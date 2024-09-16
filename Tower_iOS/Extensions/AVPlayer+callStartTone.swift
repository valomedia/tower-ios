//
//  AVPlayer+callStartTone.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-09-16.
//

import Foundation
import AVFoundation


// MARK: AVPlayer

// MARK: + callStartTone

extension AVPlayer {
    
    /// An AVPlayer for a sound to play once, when the assistant joins the call.
    ///
    /// - Copyright: Asset by UNIVERSFIELD, see ACKNOWLEDGEMENTS.txt for more information.
    ///
    static let callStartTone: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "call-start-tone", withExtension: "mp3") else {
            fatalError("Failed to find source file.")
        }
        return AVPlayer(url: url)
    }()
    
}
