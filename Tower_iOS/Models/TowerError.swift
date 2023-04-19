//
//  TowerError.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-19.
//
//

import Foundation


// MARK: TowerError

/// An error representing an issue while communicating with the service.
///
enum TowerError: Error {
    case invalidEndpoint
    case missingCredentials
    case badCredentials
    case serverError
    case unexpectedError

}
