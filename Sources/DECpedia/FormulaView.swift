import SwiftUI
import WebKit
import AppKit

struct FormulaView: View {
    @EnvironmentObject private var store: AppStore
    let mathML: String
    let latex: String
    let description: String
    var emphasized = false
    @State private var copied = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RichMathView(text: "\\[" + latex + "\\]", size: emphasized ? 21 : 18)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityLabel(description)
            HStack(alignment: .top, spacing: 10) {
                RichMathView(text: description, size: 15)
                Spacer(minLength: 0)
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(latex, forType: .string)
                    copied = true
                } label: {
                    Label(copied ? store.t("Copiato", "Copied") : "LaTeX", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 10))
                }.buttonStyle(.borderless).help(store.t("Copia la formula in LaTeX", "Copy formula as LaTeX"))
            }
        }
        .padding(.horizontal, emphasized ? 24 : 8)
        .padding(.vertical, emphasized ? 24 : 10)
        .frame(maxWidth: 760, alignment: .center)
        .background {
            if emphasized {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.055))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor.opacity(0.22), lineWidth: 1))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

