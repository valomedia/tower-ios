//
//  PreviewProvider+env.swift
//  Tower_iOS
//
//
//

import Foundation
import SwiftUI


// MARK: PreviewProvider

extension PreviewProvider {

    // MARK: + env

    /// Mock TowerEnvironment for previews.
    ///
    static var env: TowerEnvironment {
        TowerEnvironment.preview
    }

}