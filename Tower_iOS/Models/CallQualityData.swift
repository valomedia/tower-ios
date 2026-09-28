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

// MARK: CallQualityData

/// The data sent in realtime data messages related to call quality.
/// 
/// This contains the data that gets sent in the change-call-quality-request, change-call-quality-response and
/// call-quality-event realtime data messages.
///
struct CallQualityData: Codable {

    enum CodingKeys: String, CodingKey {
        case callQualityLevel = "callQualityLevel"
        case message = "message"
    }

    // MARK: - Properties

    /// The preset for the video quality related to this message.
    /// 
    /// For the change-call-quality-response and call-quality-event realtime data messages, this specifies the new
    /// setting being used. In a change-call-quality-request, this specifies the requested call quality.
    ///
    var callQualityLevel: CallQualityLevel?

    /// The error message if something went wrong.
    /// 
    var message: String?

}
