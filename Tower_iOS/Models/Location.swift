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


// MARK: Location

/// The latitude, longitude, and course information reported by the system.
///
/// This is a typesafe wrapper for CLLocation
///
/// - SeeAlso:
///     [CLLocation | Apple Developer Documentation](https://developer.apple.com/documentation/corelocation/cllocation)
///
class Location {

    // MARK: - Life cycle methods

    /// Creates a Location from a CLLocation.
    ///
    /// - Parameters:
    ///     - clLocation: The CLLocation to use as the source of truth.
    ///
    init(_ clLocation: CLLocation) {
        self.clLocation = clLocation
    }

    /// Creates a Location with the specified coordinate, altitude, course and accuracy information.
    ///
    /// This is a convenience initializer that passes all its parameters straight through to the underlying CLLocation
    /// object. Apart from replacing nil values with the respective values that indicate invalid data in CLLocation, no
    /// further sanity checks will be performed (but the values will be checked and nil will be returned as
    /// appropriate when reading them later).
    ///
    /// - Parameters:
    ///     - coordinate: The geographical coordinate information.
    ///     - altitude: The altitude above mean sea level associated with a location, in meters.
    ///     - horizontalAccuracy: The radius of uncertainty for the location, in meters.
    ///     - verticalAccuracy: The validity of the altitude values, and their estimated uncertainty, in meters.
    ///     - course: The direction in which the device is traveling, in degrees and relative to due north.
    ///     - courseAccuracy: The accuracy of the course value, in degrees.
    ///     - speed: The instantaneous speed of the device, in meters per second.
    ///     - speedAccuracy: The accuracy of the speed value, in meters per second.
    ///     - timestamp: The time at which this location was determined.
    ///     - sourceInfo: Information about the source that provides the location.
    ///
    convenience init(
            coordinate: CLLocationCoordinate2D? = nil,
            altitude: CLLocationDistance? = nil,
            horizontalAccuracy: CLLocationAccuracy? = nil,
            verticalAccuracy: CLLocationAccuracy? = nil,
            course: CLLocationDirection? = nil,
            courseAccuracy: CLLocationDirectionAccuracy? = nil,
            speed: CLLocationSpeed? = nil,
            speedAccuracy: CLLocationSpeedAccuracy? = nil,
            timestamp: Date? = nil,
            sourceInfo: CLLocationSourceInformation? = nil) {
        self.init(
                CLLocation(
                        coordinate: coordinate ?? CLLocationCoordinate2D(),
                        altitude: altitude ?? 0,
                        horizontalAccuracy: horizontalAccuracy ?? (coordinate != nil ? 0 : -1),
                        verticalAccuracy: verticalAccuracy ?? -1,
                        course: course ?? -1,
                        courseAccuracy: courseAccuracy ?? -1,
                        speed: speed ?? -1,
                        speedAccuracy: speedAccuracy ?? -1,
                        timestamp: timestamp ?? Date(),
                        sourceInfo: sourceInfo)
        )
    }

    /// Creates a Location with the specified latitude, longitude, altitude, course and accuracy information.
    ///
    /// This is a convenience initializer that passes all its parameters straight through to the underlying CLLocation
    /// object. Apart from replacing nil values with the respective values that indicate invalid data in CLLocation, no
    /// further sanity checks will be performed (but the values will be checked and nil will be returned as
    /// appropriate when reading them later).
    ///
    /// - Parameters:
    ///     - latitude: The latitude in degrees.
    ///     - longitude: The longitude in degrees.
    ///     - altitude: The altitude above mean sea level associated with a location, in meters.
    ///     - horizontalAccuracy: The radius of uncertainty for the location, in meters.
    ///     - verticalAccuracy: The validity of the altitude values, and their estimated uncertainty, in meters.
    ///     - course: The direction in which the device is traveling, in degrees and relative to due north.
    ///     - courseAccuracy: The accuracy of the course value, in degrees.
    ///     - speed: The instantaneous speed of the device, in meters per second.
    ///     - speedAccuracy: The accuracy of the speed value, in meters per second.
    ///     - timestamp: The time at which this location was determined.
    ///     - sourceInfo: Information about the source that provides the location.
    ///
    convenience init(
            latitude: CLLocationDegrees,
            longitude: CLLocationDegrees,
            altitude: CLLocationDistance? = nil,
            horizontalAccuracy: CLLocationAccuracy? = nil,
            verticalAccuracy: CLLocationAccuracy? = nil,
            course: CLLocationDirection? = nil,
            courseAccuracy: CLLocationDirectionAccuracy? = nil,
            speed: CLLocationSpeed? = nil,
            speedAccuracy: CLLocationSpeedAccuracy? = nil,
            timestamp: Date? = nil,
            sourceInfo: CLLocationSourceInformation? = nil) {
        self.init(
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                verticalAccuracy: verticalAccuracy,
                course: course,
                courseAccuracy: courseAccuracy,
                speed: speed,
                speedAccuracy: speedAccuracy,
                timestamp: timestamp,
                sourceInfo: sourceInfo)
    }

    // MARK: - Properties

    /// The CLLocation being wrapped.
    ///
    /// - SeeAlso: [
    ///
    let clLocation: CLLocation

    /// The geographical coordinate information.
    ///
    /// This will return the coordinate information from the wrapped CLLocation, or nil if horizontalAccuracy is
    /// negative.
    ///
    var coordinate: CLLocationCoordinate2D? {
        (clLocation.horizontalAccuracy >= 0) .!! clLocation.coordinate
    }

    /// The altitude above mean sea level associated with a location, measured in meters.
    ///
    /// This will return the altitude information from the wrapped CLLocation, or nil if verticalAccuracy is zero or
    /// a negative number. Zero is considered a valid accuracy horizontally, but not vertically!
    ///
    var altitude: CLLocationDistance? {
        (clLocation.verticalAccuracy > 0) .!! clLocation.altitude
    }

    /// The altitude above the World Geodetic System 1984 (WGS84) ellipsoid, measured in meters.
    ///
    /// This will return the altitude information from the wrapped CLLocation, or nil if verticalAccuracy is zero or
    /// a negative number. Zero is considered a valid accuracy horizontally, but not vertically!
    ///
    ///
    var ellipsoidalAltitude: CLLocationDistance? {
        (clLocation.verticalAccuracy > 0) .!! clLocation.ellipsoidalAltitude
    }

    /// The logical floor of the building in which the user is located.
    ///
    /// This will return the floor information from the wrapped CLLocation unaltered.
    ///
    var floor: CLFloor? {
        clLocation.floor
    }

    /// The time at which this location was determined.
    ///
    /// This will return the timestamp from the wrapped CLLocation unaltered.
    ///
    var timestamp: Date {
        clLocation.timestamp
    }

    /// Information about the source that provides the location.
    ///
    /// This will return the sourceInformation from the wrapped CLLocation unaltered.
    ///
    var sourceInformation: CLLocationSourceInformation? {
        clLocation.sourceInformation
    }

    /// The radius of uncertainty for the location, measured in meters.
    ///
    /// This will return the horizontalAccuracy from the wrapped CLLocation, or nil if the value is negative.
    ///
    var horizontalAccuracy: CLLocationAccuracy? {
        (clLocation.horizontalAccuracy >= 0) .!! clLocation.horizontalAccuracy
    }

    /// The validity of the altitude values, and their estimated uncertainty, measured in meters.
    ///
    /// This will return the verticalAccuracy from the wrapped CLLocation, or nil if the value is zero or a negative
    /// number. Zero is considered a valid accuracy horizontally, but not vertically!
    ///
    var verticalAccuracy: CLLocationAccuracy? {
        (clLocation.verticalAccuracy > 0) .!! clLocation.verticalAccuracy
    }

    /// The instantaneous speed of the device, measured in meters per second.
    ///
    /// This will return the speed information from the wrapped CLLocation, or nil if the value is negative. According
    /// to the documentation this property should also be considered invalid if the speedAccuracy property is negative,
    /// but CoreLocation is buggy and will set speedAccuracy to -1 when the accuracy is not known, even when the speed
    /// itself is known, so the speedAccuracy property is ignored here.
    ///
    var speed: CLLocationSpeed? {
        (clLocation.speed >= 0) .!! clLocation.speed
    }

    /// The accuracy of the speed value, measured in meters per second.
    ///
    /// This will return the speed accuracy information from the wrapped CLLocation, or nil if the value is negative.
    ///
    var speedAccuracy: CLLocationSpeedAccuracy? {
        (clLocation.speedAccuracy >= 0) .!! clLocation.speedAccuracy
    }

    /// The direction in which the device is traveling, measured in degrees and relative to due north.
    ///
    /// This will return the course information from the wrapped CLLocation, or nil if the value is negative. According
    /// to the documentation this property should also be considered invalid if the courseAccuracy property is negative,
    /// but CoreLocation is buggy and will set courseAccuracy to -1 when the accuracy is not known, even when the course
    /// itself is known, so the courseAccuracy property is ignored here.
    ///
    var course: CLLocationDirection? {
        (clLocation.course >= 0) .!! clLocation.course
    }

    /// The accuracy of the course value, measured in degrees.
    ///
    /// This will return the course accuracy information from the wrapped CLLocation, or nil if the value is negative.
    ///
    var courseAccuracy: CLLocationDirectionAccuracy? {
        (clLocation.courseAccuracy >= 0) .!! clLocation.courseAccuracy
    }

    // MARK: - Methods

    /// Returns the distance (measured in meters) from the current object's location to the specified location.
    ///
    func distance(from location: Location) -> CLLocationDistance {
        clLocation.distance(from: location.clLocation)
    }

}
