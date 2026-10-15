import SwiftUI
import PDFKit
#if canImport(DECpediaCore)
import DECpediaCore
#endif

struct PDFReaderView: View {
    @EnvironmentObject private var store: AppStore
    let request: PDFRequest
    @Environment(\.dismiss) private var dismiss
    @State private var page: Int
    @State private var error: String?
    init(request: PDFRequest) {
        self.request = request
        _page = State(initialValue: request.page)
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.source.title).font(.headline)
                    Text(request.source.pageDescription(page, language: store.language)).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button { page = max(1, page - 1) } label: { Image(systemName: "chevron.left") }.disabled(page <= 1).help(store.t("Pagina precedente", "Previous page"))
                HStack(spacing: 4) {
                    TextField(store.t("Pagina PDF", "PDF page"), value: $page, format: .number.grouping(.never))
                        .frame(width: 45).textFieldStyle(.roundedBorder)
                        .onChange(of: page) { _ in page = min(max(page, 1), request.source.pageCount) }
                    Text("/ \(request.source.pageCount)").font(.caption).foregroundStyle(.secondary)
                }
                Button { page = min(request.source.pageCount, page + 1) } label: { Image(systemName: "chevron.right") }.disabled(page >= request.source.pageCount).help(store.t("Pagina successiva", "Next page"))
                Button(store.t("Riferimento", "Reference")) { page = request.page }.help(store.t("Torna alla pagina citata", "Return to cited page"))
                Button(store.t("Chiudi", "Close")) { dismiss() }.keyboardShortcut(.cancelAction)
            }.padding(16).background(.regularMaterial)
            Divider()
            if let error {
                EmptyPane(symbol: "doc.badge.ellipsis", title: store.t("PDF non leggibile", "Unable to read PDF"), message: error)
            } else {
                PDFCanvas(url: request.url, page: $page, error: $error)
            }
            Divider()
            HStack {
                Image(systemName: "internaldrive")
                Text(store.t("File locale · testo originale in inglese", "Local file · source text in English"))
                Spacer()
                Text(store.t("Riferimento: PDF ", "Reference: PDF ") + "\(request.page)\(request.endPage == request.page ? "" : "–\(request.endPage)")")
            }.font(.caption2).foregroundStyle(.secondary).padding(10)
        }.frame(minWidth: 850, idealWidth: 1050, minHeight: 700, idealHeight: 900)
    }
}

private struct PDFCanvas: NSViewRepresentable {
    let url: URL
    @Binding var page: Int
    @Binding var error: String?
    func makeCoordinator() -> Coordinator { Coordinator(page: $page) }
    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.pageBreakMargins = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.backgroundColor = .windowBackgroundColor
        if let document = PDFDocument(url: url) {
            view.document = document
            if let target = document.page(at: page - 1) { view.go(to: target) }
        } else {
            DispatchQueue.main.async { error = "Il file \(url.lastPathComponent) non può essere aperto da PDFKit." }
        }
        context.coordinator.observer = NotificationCenter.default.addObserver(forName: .PDFViewPageChanged, object: view, queue: .main) { [weak view, weak coordinator = context.coordinator] _ in
            guard let view, let document = view.document, let current = view.currentPage, let coordinator else { return }
            let number = document.index(for: current) + 1
            // Notifications also happen while SwiftUI updates the view.
            DispatchQueue.main.async {
                if coordinator.lastRequestedPage == nil { coordinator.page.wrappedValue = number }
            }
        }
        return view
    }
    func updateNSView(_ view: PDFView, context: Context) {
        context.coordinator.page = $page
        guard let document = view.document, let target = document.page(at: page - 1) else { return }
        if let current = view.currentPage, document.index(for: current) + 1 == page { return }
        context.coordinator.lastRequestedPage = page
        view.go(to: target)
        DispatchQueue.main.async { context.coordinator.lastRequestedPage = nil }
    }
    static func dismantleNSView(_ view: PDFView, coordinator: Coordinator) {
        if let observer = coordinator.observer { NotificationCenter.default.removeObserver(observer) }
        view.document = nil
    }
    final class Coordinator {
        var page: Binding<Int>
        var observer: NSObjectProtocol?
        var lastRequestedPage: Int?
        init(page: Binding<Int>) { self.page = page }
        deinit { if let observer { NotificationCenter.default.removeObserver(observer) } }
    }
}
