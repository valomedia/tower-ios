//
//  Image_Orientation+init.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-07-31.
//
//

import Foundation
import SwiftUI


// MARK: Image.Orientation

// MARK: + init

extension Image.Orientation {

    /// Initialize an Orientation from a CGImagePropertyOrientation.
    ///
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }

}