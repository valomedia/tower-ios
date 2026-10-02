//
// Copyright (c) 2024-2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation


// MARK: PhotoData

/// The data for a photo.
///
/// This contains the Data  for an image file, along with its dimensions.
///
struct PhotoData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case imageData = "imageData"
        case imageSize = "imageSize"
    }
    
    // MARK: - Properties
    
    /// The image in a format that could be written to a file.
    ///
    var imageData: Data
    
    /// The width and height of the image.
    ///
    var imageSize: ImageSize
    
}
