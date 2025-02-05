//
//  NewsletterApi.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-02-05.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: NewsletterApi

/// Implementation of the API for signing up to the newsletter.
///
class NewsletterApi {

    // MARK: - Static properties

    static let endpoint 
        = "https://102627ed.sibforms.com/serve/MUIFABS_EeTDewI6CHBRf1w5NnZKEguZJpIu0oXeZ21dMbNT2IywvP-okYcDh6EPoX2Y-klH"
        + "0RSNPg1969fylxfBU8021ArZb0VaRYZePUj59qqieaZ8HYKILYOQ9HDah27RLpMDylzxLWUWc4u_WWqWfvfgaujW4Kg7lOgzW48Borm-kgMd"
        + "JBoxq55jP7pJ3X_uJA6mra0LUiEG"

    // MARK: - Static methods

    /// Sign a user up for the newsletter.
    ///
    /// Brevo doesn't give us a good indication of whether this worked, returning the same 302 pretty much no matter
    /// what, so this just returns Void.
    ///
    /// - Parameters:
    ///   - firstName: The given name of the user signing up to the newsletter, empty if unknown.
    ///   - lastName: The surname of the user signing up to the newsletter, empty if unknown.
    ///   - email: The e-mail adress of the user signing up to the newsletter.
    ///
    static func signup(firstName: String, lastName: String, email: String) async -> Void {
        let url = URL(string: endpoint)!

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "VORNAME", value: firstName),
            URLQueryItem(name: "NACHNAME", value: lastName),
            URLQueryItem(name: "EMAIL", value: email)
        ]

        // Workaround for Apple being “technically correct” (the best kind of correct) in their implementation of
        // `percentEncodedQuery` (see https://stackoverflow.com/a/27724627/1271826).
        let body = urlComponents.percentEncodedQuery!.replacingOccurrences(of: "+", with: "%2B")

        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = Data(body.utf8)

        _ = try? await URLSession.shared.data(for: request)
    }

}
