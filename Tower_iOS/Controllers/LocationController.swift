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

    var locationManager = CLLocationManager()

    /// The call controller to use to send location messages.
    ///
    weak var callController: CallController?

    private let logger = ConsoleLogger(name: "LocationController")

    // MARK: - Methods

    /// Start updating the location.
    ///
    /// - Throws: CLError
    ///
    func requestLocation() throws {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            logger.info(msg: "Requesting location data")
            locationManager.startUpdatingLocation()
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
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        logger.info(msg: "locationManagerDidChangeAuthorization")
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            logger.info(msg: "Requesting location data")
            locationManager.startUpdatingLocation()
            break
        case .restricted, .denied:
            callController?.sendDataMessage(
                    .locationEvent,
                    data: try! JSONEncoder.shared.encode(LocationEventData(message: "\(CLError(.denied))")))
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logger.info(msg: "locationManager(_:didUpdateLocations:)")
        locations.last.map { location in
            callController?.sendDataMessage(
                    .locationEvent,
                    data: try! JSONEncoder.shared.encode(
                            LocationEventData(locationInfo: LocationInfo(Location(location))))
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.info(msg: "locationManager(_:didFailWithError:)")
        callController?.sendDataMessage(
                .locationEvent,
                data: try! JSONEncoder.shared.encode(LocationEventData(message: "\(error)")))
    }

}
