import SwiftUI
import WebKit
import AppKit

struct FormulaView: View {
    @EnvironmentObject private var store: AppStore
    let mathML: String
    let latex: String
    let description: String
    @State private var copied = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RichMathView(text: "\\[" + latex + "\\]", size: 19, inFormulaBox: true)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityLabel(description)
            HStack(alignment: .top, spacing: 10) {
                RichMathView(text: description, size: 15, inFormulaBox: true)
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
        .padding(20)
        .frame(maxWidth: 760, alignment: .center)
        .background(Color.primary.opacity(0.018), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.12), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

