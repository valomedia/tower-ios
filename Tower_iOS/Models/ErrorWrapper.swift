//
//  ErrorWrapper.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-03-22.
//
//

import Foundation


// MARK: ErrorWrapper

/// An Error with metadata for display in the UI.
///
/// This is a wrapper around Error that makes it Identifiable and supplements it with a guidance String.
///
struct ErrorWrapper: Identifiable {


    // MARK: - Properties

    let id = UUID()

    /// The wrapped Error.
    ///
    let error: Error

    /// Guidance for the user.
    ///
    /// This is a string containing some information intended to give the user advice on how to proceed.
    ///
    let guidance: String

}
