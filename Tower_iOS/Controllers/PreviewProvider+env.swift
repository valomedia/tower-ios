//
//  PreviewProvider+env.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-05.
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