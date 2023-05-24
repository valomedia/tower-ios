//
//  LocationController.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-05-24.
//
//

import Foundation
import CoreLocation
import AmazonChimeSDK


// MARK: LocationController

/// The controller for location services.
///
/// This contains all the application logic around retrieving locations.
///
class LocationController: NSObject, CLLocationManagerDelegate {

    // MARK: - Static properties

    /// A shared LocationController instance for use throughout the app.
    ///
    //static let shared = LocationController()

    // MARK: - Class methods

    // MARK: - Life cycle methods

    override init() {
        logger.info(msg: "Init")
        super.init()
        locationManager.delegate = self
    }

    // MARK: - Properties

    /// All tasks waiting for location data to continue.
    ///
    var continuations: [CheckedContinuation<Location, Error>] = []

    var locationManager = CLLocationManager()

    private let logger = ConsoleLogger(name: "LocationController")

    // MARK: - Methods

    /// Get the location from the location manager.
    ///
    /// - Returns: The Location
    /// - Throws: CLError
    ///
    func requestLocation() async throws -> Location {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            logger.info(msg: "Requesting location data")
            locationManager.requestLocation()
            break
        case .restricted, .denied:
            throw CLError(.denied)
        case .notDetermined:
            logger.info(msg: "Requesting location permissions")
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        logger.info(msg: "locationManagerDidChangeAuthorization")
        guard !continuations.isEmpty else { return }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            logger.info(msg: "Requesting location data")
            locationManager.requestLocation()
            break
        case .restricted, .denied:
            continuations.forEach { continuation in
                continuation.resume(throwing: CLError(.denied))
            }
            continuations = []
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logger.info(msg: "locationManager(_:didUpdateLocations:)")
        continuations.forEach { continuation in
            continuation.resume(returning: Location(locations.last!))
        }
        continuations = []
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.info(msg: "locationManager(_:didFailWithError:)")
        continuations.forEach { continuation in
            continuation.resume(throwing: error)
        }
        continuations = []
    }

}
