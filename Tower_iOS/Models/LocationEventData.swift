//
//  LocationEventData.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-05-23.
//
//

import Foundation
import CoreLocation


// MARK: LocationResponseData

/// The data sent in a location-event realtime data message.
///
struct LocationEventData: Codable {

    enum CodingKeys: String, CodingKey {
        case locationInfo = "locationInfo"
        case message = "message"
    }

    // MARK: - Properties

    /// The location information
    ///
    var locationInfo: LocationInfo?

    /// The error message if location failed.
    ///
    var message: String?

}


// MARK: LocationInfo

/// The location information.
///
/// This is the location information sent to the server (a subset of the data contained in a CLLocation, but with
/// non-optional latitude and longitude).
///
/// - SeeAlso:
///     [CLLocation | Apple Developer Documentation](https://developer.apple.com/documentation/corelocation/cllocation)
///
struct LocationInfo: Codable {

    enum CodingKeys: String, CodingKey {
        case coordinate = "coordinate"
        case altitude = "altitude"
        case horizontalAccuracy = "horizontalAccuracy"
        case verticalAccuracy = "verticalAccuracy"
        case course = "course"
        case courseAccuracy = "courseAccuracy"
        case timestamp = "timestamp"
    }

    // MARK: - Life cycle methods

    /// Creates LocationInfo with the specified coordinate, altitude, course, and accuracy information.
    ///
    /// - Parameters:
    ///     - coordinate: The geographical coordinate information.
    ///     - altitude: The altitude above mean sea level associated with the location, in meters.
    ///     - horizontalAccuracy: The radius of uncertainty for the location, in meters.
    ///     - verticalAccuracy: The estimated uncertainty of the altitude values, in meters.
    ///     - course: The direction in which the device is traveling, in degrees and relative to due north.
    ///     - courseAccuracy: The accuracy of the course value, in degrees.
    ///     - timestamp: The time at which this location was determined.
    ///
    init(
            coordinate: CLLocationCoordinate2D,
            altitude: CLLocationDistance? = nil,
            horizontalAccuracy: CLLocationAccuracy? = nil,
            verticalAccuracy: CLLocationAccuracy? = nil,
            course: CLLocationDirection? = nil,
            courseAccuracy: CLLocationDirectionAccuracy? = nil,
            timestamp: Date? = nil) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy  = verticalAccuracy
        self.course = course
        self.courseAccuracy = courseAccuracy
        self.timestamp = timestamp ?? Date()
    }


    /// Creates LocationInfo with the specified latitude, longitude, altitude, course, and accuracy information.
    ///
    /// - Parameters:
    ///     - latitude: The latitude in degrees.
    ///     - longitude: The longitude in degrees.
    ///     - altitude: The altitude above mean sea level associated with the location, in meters.
    ///     - horizontalAccuracy: The radius of uncertainty for the location, in meters.
    ///     - verticalAccuracy: The estimated uncertainty of the altitude values, in meters.
    ///     - course: The direction in which the device is traveling, in degrees and relative to due north.
    ///     - courseAccuracy: The accuracy of the course value, in degrees.
    ///     - timestamp: The time at which this location was determined.
    ///
    init(
            latitude: CLLocationDegrees,
            longitude: CLLocationDegrees,
            altitude: CLLocationDistance? = nil,
            horizontalAccuracy: CLLocationAccuracy? = nil,
            verticalAccuracy: CLLocationAccuracy? = nil,
            course: CLLocationDirection? = nil,
            courseAccuracy: CLLocationDirectionAccuracy? = nil,
            timestamp: Date? = nil) {
        self.init(
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                verticalAccuracy: verticalAccuracy,
                course: course,
                courseAccuracy: courseAccuracy,
                timestamp: timestamp)
    }

    /// Creates a LocationInfo from an existing Location.
    ///
    /// This will pull the location info from the Location object, returning nil, if the object has no valid coordinate.
    ///
    /// - Parameter location: The Location for the LocationInfo.
    ///
    init?(_ location: Location) {
        guard let coordinate = location.coordinate else {
            return nil
        }
        self.init(
                coordinate: coordinate,
                altitude: location.altitude,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy,
                course: location.course,
                courseAccuracy: location.courseAccuracy,
                timestamp: location.timestamp)
    }

    // MARK: - Properties

    /// The geographical coordinate information.
    ///
    var coordinate: CLLocationCoordinate2D

    /// The altitude above mean sea level, in meters.
    ///
    var altitude: CLLocationDistance?

    /// The radius of uncertainty for the location, in meters.
    ///
    var horizontalAccuracy: CLLocationAccuracy?

    /// The estimated uncertainty of the altitude value, in meters.
    ///
    var verticalAccuracy: CLLocationAccuracy?

    /// The direction in which the device is travelling, in degrees relative to due north.
    ///
    var course: CLLocationDirection?

    /// The accuracy of the course value, in degrees.
    ///
    var courseAccuracy: CLLocationDirectionAccuracy?

    /// The time at which the location was determined.
    ///
    var timestamp: Date

}
