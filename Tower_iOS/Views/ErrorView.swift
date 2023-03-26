//
//  ErrorView.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-03-26.
//
//

import Foundation
import SwiftUI


// MARK: ErrorView

/// A view showing an Error to the user.
///
/// This view will display an Error along with the guidance string from the ErrorWrapper.
///
struct ErrorView: View {

    // MARK: - Properties

    /// The ErrorWrapper containing the Error and guidance to be shown.
    ///
    let errorWrapper: ErrorWrapper

    var body: some View {
        NavigationView {
            NoContentView(
                    title: "An error has occurred!",
                    headline: errorWrapper.error.localizedDescription,
                    caption: errorWrapper.guidance)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Dismiss") {
                                dismiss()
                            }
                        }
                    }
        }
    }

    @Environment(\.dismiss)
    private var dismiss

}


// MARK: ErrorView_Previews

class ErrorView_Previews: PreviewProvider {

    /// A mock Error for demonstration purposes.
    ///
    enum SampleError: Error {
        case errorRequired
    }

    // MARK: - Static properties

    /// The Error and guidance to display in the preview.
    ///
    static var wrapper: ErrorWrapper {
        ErrorWrapper(error: SampleError.errorRequired, guidance: "You can safely ignore this error.")
    }

    static var previews: some View {
        ErrorView(errorWrapper: wrapper)
    }

}
