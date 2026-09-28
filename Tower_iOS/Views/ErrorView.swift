//
// Copyright (c) 2023-2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
                    Informationen, die unserem Team helfen können, den Fehler zu finden. Bitte kopiere den Fehlerbericht und \
                    schicke ihn uns per E-Mail an [feedback@tower-assist.de](mailto:feedback@tower-assist.de).
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
