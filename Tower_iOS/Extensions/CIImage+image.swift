//
//  CIImage+image.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-07-31.
//
//

import Foundation
import SwiftUI


// MARK: CIImage

// MARK: + image

extension CIImage {

    /// Create an Image from the CIImage by supplying sensible defaults to all the options.
    ///
    /// This will create an Image with scale 1 and orientation .up.
    ///
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }

}
