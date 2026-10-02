//
// Copyright (c) 2023-2026 valo.media GmbH
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
import CoreLocation


// MARK: CLLocation

// MARK: + init

extension CLLocation {

    /// Creates a CLLocation with Optional sourceInfo.
    ///
    /// - Parameters:
    ///   - coordinate: The geographical coordinate information.
    ///   - altitude: The altitude above mean sea level associated with a location, measured in meters.
    ///   - horizontalAccuracy: The radius of uncertainty for the location, measured in meters.
    ///   - verticalAccuracy: The validity of the altitude values, and their estimated uncertainty, measured in meters.
    ///   - course: The direction in which the device is traveling, measured in degrees and relative to due north.
    ///   - courseAccuracy: The accuracy of the course value, measured in degrees.
    ///   - speed: The instantaneous speed of the device, measured in meters per second.
    ///   - speedAccuracy: The accuracy of the speed value, measured in meters per second.
    ///   - timestamp: The time at which this location was determined.
    ///   - sourceInfo: Information obout the source that provides the location.
    ///
    convenience init(
            coordinate: CLLocationCoordinate2D,
            altitude: CLLocationDistance,
            horizontalAccuracy: CLLocationAccuracy,
            verticalAccuracy: CLLocationAccuracy,
            course: CLLocationDirection,
            courseAccuracy: CLLocationDirectionAccuracy,
            speed: CLLocationSpeed,
            speedAccuracy: CLLocationSpeedAccuracy,
            timestamp: Date,
            sourceInfo: CLLocationSourceInformation? = nil) {
        if let sourceInfo {
            self.init(
                    coordinate: coordinate,
                    altitude: altitude,
                    horizontalAccuracy: horizontalAccuracy,
                    verticalAccuracy: verticalAccuracy,
                    course: course,
                    courseAccuracy: courseAccuracy,
                    speed: speed,
                    speedAccuracy: speedAccuracy,
                    timestamp: timestamp,
                    sourceInfo: sourceInfo)
        } else {
            self.init(
                    coordinate: coordinate,
                    altitude: altitude,
                    horizontalAccuracy: horizontalAccuracy,
                    verticalAccuracy: verticalAccuracy,
                    course: course,
                    courseAccuracy: courseAccuracy,
                    speed: speed,
                    speedAccuracy: speedAccuracy,
                    timestamp: timestamp)
        }
    }

}
