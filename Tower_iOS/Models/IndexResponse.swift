//
//  IndexResponse.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: IndexResponse

/// The data returned by the `/`-endpoint.
///
struct IndexResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case message = "message"
        case apiVersion = "apiVersion"
        case openingHours = "openingHours"
    }

    // MARK: - Properties

    /// The message returned by the endpoint.
    ///
    /// Currently this will always be "Success".
    ///
    var message: String

    /// The major and minor version of the backend.
    ///
    var apiVersion: String

    /// The information about the opening hours of the service.
    ///
    var openingHours: OpeningHoursInfo

}

// MARK: OpeningHoursInfo

/// The data regarding opening hours, as returned by the api.
///
/// Information about the local time of the service, whether the service is currently open, and the schedule for the
/// next couple days.
///
struct OpeningHoursInfo: Codable {

    enum CodingKeys: String, CodingKey {
        case time, status, schedule, description
    }

    // MARK: - Static properties

    private static let codingFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    // MARK: - Life cycle methods

    init(time: String, status: ServiceStatus, schedule: [(Date, String?)], description: String) {
        self.time = time
        self.status = status
        self.schedule = schedule
        self.description = description
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            time: try container.decode(String.self, forKey: .time),
            status: try container.decode(ServiceStatus.self, forKey: .status),
            schedule: try (container.decode([String: String].self, forKey: .schedule))
                .map { (dateString, serviceHours) in 
                    guard let date = OpeningHoursInfo.codingFormatter.date(from: dateString) else { 
                        throw DecodingError.dataCorruptedError(
                            forKey: .schedule,
                            in: container,
                            debugDescription: "Expected date string to be formatted as YYYY-MM-DD")
                    }
                    return (date, serviceHours != "" ? serviceHours : nil)
                }
                .sorted(by: \.0),
            description: try container.decode(String.self, forKey: .description))
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time, forKey: .time)
        try container.encode(status, forKey: .status)
        try container.encode(
            Dictionary(uniqueKeysWithValues: schedule.map { 
                (OpeningHoursInfo.codingFormatter.string(from: $0.0), $0.1 ?? "") 
            }),
            forKey: .schedule)
        try container.encode(description, forKey: .description)
    }

    // MARK: - Properties

    /// The local time where the service is located, formatted as hh:mm.
    ///
    var time: String

    /// Whether the assistance service is currently available.
    ///
    var status: ServiceStatus

    /// The schedule for the next couple days.
    ///
    /// This is an Array with an Tuple for each day. Each Tuple will have the Date the opening hours apply for, and a
    /// human-readable String specifying the opening hours as provided by the API.
    ///
    var schedule: [(Date, String?)]

    /// The human-readable description of the opening hours.
    ///
    var description: String

}

// MARK: ServiceStatus

/// An enum representing whether the assistance service is currently available or not.
///
enum ServiceStatus: String, Codable {
    case open = "open"
    case closed = "closed"
}
