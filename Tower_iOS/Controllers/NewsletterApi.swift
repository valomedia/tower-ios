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
    
    /// The “store contact only” (do-not-subscribe) endpoint
    static let contactEndpoint
        = "https://102627ed.sibforms.com/serve/MUIFAFgJpc2hiHD82N7TqhbhDNgFe6PbBvnGQCwOu5RLno"
        + "kggQHOuLNYDzrfsvfG4Ag9QC5LOyIqV92r2k99S68Rfmf_1idVtlX11J28hPJqrT48Eea_DD5stwFzUOxsqgg"
        + "MdY6azuLvRv5MuMsVFniCohvsLD6qNfVl2oBBB_WLw2qi_2g2ggGsbguEMWcsu94spdM5pH3ldc5v"
    
    // MARK: - Static methods

    /// Subscribe or just store contact, based on `wantsNewsletter`.
    ///
    /// Brevo doesn't give us a good indication of whether this worked, returning the same 302 pretty much no matter
    /// what, so this just returns Void.
    ///
    /// - Parameters:
    ///   - firstName: The given name.
    ///   - lastName: The surname.
    ///   - email: The e-mail address.
    ///   - wantsNewsletter: `true` to subscribe; `false` to just store.
    ///
    static func signup(
        firstName: String,
        lastName: String,
        email: String,
        wantsNewsletter: Bool
    ) async -> Void {
        let urlString = wantsNewsletter ? endpoint : contactEndpoint
        await sendRequest(
            to: urlString,
            firstName: firstName,
            lastName: lastName,
            email: email
        )
    }

    private static func sendRequest(to urlString: String, firstName: String, lastName: String, email: String) async -> Void {
        let url = URL(string: urlString)!
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "VORNAME", value: firstName),
            URLQueryItem(name: "NACHNAME", value: lastName),
            URLQueryItem(name: "EMAIL", value: email)
        ]
        // Workaround for Apple being “technically correct” (the best kind of correct) in their implementation of
        // `percentEncodedQuery` (see https://stackoverflow.com/a/27724627/1271826).
        let body = urlComponents.percentEncodedQuery!.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = Data(body.utf8)

        _ = try? await URLSession.shared.data(for: request)
    }

}
