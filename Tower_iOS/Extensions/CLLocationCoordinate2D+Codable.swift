//
//  CLLocationCoordinate2D+Codable.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-05-23.
//
//

import Foundation
import CoreLocation


// MARK: CLLocationCoordinate2d

// MARK: + Codable

extension CLLocationCoordinate2D: Codable {

    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
                latitude: container.decode(CLLocationDegrees.self, forKey: .latitude),
                longitude: container.decode(CLLocationDegrees.self, forKey: .longitude))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

}