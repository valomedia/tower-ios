//
//  TowerEnvironment.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-03-28.
//
//

import Foundation


// MARK: TowerEnvironment

/// Main environment object.
///
/// This class is a view controller that represents all data that is needed across most views. It is added as an
/// EnvironmentObject to pretty much all views. This means that if this object publishes a change, pretty much the
/// entire app needs to be reloaded, so it should not contain any data that changes often.
///
class TowerEnvironment: ObservableObject {

    // MARK: - Static properties

    /// Preview TowerEnvironment
    ///
    /// This is a singleton used to mock a TowerEnvironment in previews.
    ///
    static let preview: TowerEnvironment = TowerEnvironment()

    // MARK: - Properties

    /// The current error, if any.
    ///
    /// This contains the current Error, along with its guidance String, if any Error has occurred. The error will
    /// completely take over the app and will be cleared, once the user acknowledges the messages, so there can ever be
    /// at most one error that is current.
    ///
    @Published var errorWrapper: ErrorWrapper?

}
