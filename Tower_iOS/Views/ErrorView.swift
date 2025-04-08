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
                title: "Es ist ein Fehler aufgetreten!",
                headline: errorWrapper.error.localizedDescription,
                caption: errorWrapper.guidance
            ) {
                Text("""
                    Sollte das Problem weiterhin auftreten, wende dich bitte an unseren Support. Im Folgenden findest du \
                    Informationen, die unserem Team helfen können, den Fehler zu finden. Bitte kopiere den \
                    Fehlerbericht und schicke ihn uns per e-Mail.
                    """)
                Button {
                    UIPasteboard.general.string = String(reflecting: errorWrapper.error)
                    hasCopiedErrorReport = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        hasCopiedErrorReport = false
                    }
                } label: {
                    Label("Bericht kopieren", systemImage: hasCopiedErrorReport ? "checkmark" : "document.on.clipboard")
                }
                    .buttonStyle(.borderedProminent)
                    .disabled(hasCopiedErrorReport)
                Text("Fehlerbericht").bold()
                Text(String(reflecting: errorWrapper.error))
                    .font(.system(.body, design: .monospaced))
                    .multilineTextAlignment(.leading)
                    .background(.thinMaterial)
            }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Schließen") {
                            dismiss()
                        }
                    }
                }
        }
    }

    @Environment(\.dismiss)
    private var dismiss

    @State private var hasCopiedErrorReport = false

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
        ErrorWrapper(error: SampleError.errorRequired, guidance: "Sie können diesen Fehler gefahrlos ignorieren.")
    }

    static var previews: some View {
        ErrorView(errorWrapper: wrapper)
    }

}
