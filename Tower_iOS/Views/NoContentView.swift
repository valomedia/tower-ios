//
//  NoContentView.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-03-24.
//
//

import Foundation
import SwiftUI


// MARK: NoContentView

/// A view telling the user that no content is available to be displayed.
///
/// This is used to show a message to the user that nothing of use can be shown.  This can be for a variety of reasons.
/// For example the functionality the user is looking for may not be implemented yet, there was an error, or some action
/// is required from the user first (such as creating the content to be displayed).
///
struct NoContentView<Content: View>: View {

    // MARK: - Life cycle methods

    /// Constructor.
    ///
    /// - Parameters:
    ///   - image: The image to display at the top of the View.
    ///   - title: The title for the message, displayed below the Image.
    ///   - headline: The headline for the message, displayed below the title.
    ///   - caption: The caption for the message, displayed below the headline.
    ///   - content: Additional content, to be displayed below the caption.
    ///
    init(
            image: Image? = nil,
            title: String = "Hier gibt es nichts zu sehen",
            headline: String,
            caption: String,
            @ViewBuilder content: @escaping () -> Content = EmptyView.init) {
        self.image = image
        self.title = title
        self.headline = headline
        self.caption = caption
        self.content = content
    }

    // MARK: - Properties

    /// The image to display at the top of the View.
    ///
    /// This is intended for an image to add visual interest.  It is hidden from assistive technologies and should not
    /// be used as the only means to communicate a piece of information.  This is optional, and if no image is provided,
    /// nothing will be shown in its place.  Instead the title will be the first thing to be shown all the way at the
    /// top of the message.
    ///
    let image: Image?

    /// The title to display below the Image.
    ///
    /// This is a piece of information that is intended to give the user a general idea what is happening.  It is
    /// displayed in a very large font and should be kept as short as possible, so it fits on screen even at larger font
    /// sizes.
    ///
    let title: String

    /// The headline to display below the title.
    ///
    /// This is displayed below the title and uses a smaller font to allow giving a bit more detail.  It is intended to
    /// be used to give the user specific information about why there is no content, but should still be kept brief and
    /// should not contain an explanation.
    ///
    let headline: String

    /// The caption to display below the headline.
    ///
    /// This is the longest piece of text being displayed and it is intended to give the user actual guidance about what
    /// to do and how to proceed.  There should be a one-to-one correspondence from headline to caption if possible, to
    /// ensure that a user encountering a message that the user is familiar with only needs to read the headline.  The
    /// caption is intended for users who are encountering something for the first time and need additional information
    /// on what content would usually be shown in the place they are looking and what needs to happen for that content
    /// to become available.
    ///
    let caption: String

    var body: some View {
        ScrollView {
            VStack {
                if let image {
                    image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .accessibility(hidden: true)
                }
                Text(title)
                        .font(.title)
                        .padding(.bottom)
                Text(headline)
                        .font(.headline)
                Text(caption)
                        .font(.caption)
                        .padding(.top)
                content()
                        .padding()
                Spacer()
            }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .multilineTextAlignment(.center)
        }
                .padding()
    }

    // MARK: - Methods

    /// The additional content to display below the caption.
    ///
    /// This allows the caller to add additional elements to the box, such as a Button to get more information.
    ///
    @ViewBuilder let content: () -> Content

}


// MARK: NoContentView_Previews

class NoContentView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        NoContentView(
                title: "Lorem Ipsum",
                headline: "Lorem Ipsum Dolor Sit Amet",
                caption: """
                         Lorem impsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut \
                         labore et dolore magna aliqua.
                         """)
    }

}
