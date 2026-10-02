//
//  CLLocation+init.swift
//  Tower_iOS
//
//
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
