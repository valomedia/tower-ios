//
//  Settings+callQualityLevel.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-11-02.
//

import Foundation

// MARK: Settings

// MARK: + callQualityLevel

extension Settings {
    
    /// Get the CallQualityLevel for the current qualityPreference.
    ///
    static var callQualityLevel: CallQualityLevel { CallQualityLevel(rawValue: Settings.qualityPreference)! }
    
}
