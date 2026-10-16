import SwiftUI
#if canImport(DECpediaCore)
import DECpediaCore
#endif

struct SourceListView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 7) {
                Text(store.t("Documenti di studio", "Study documents")).font(.system(size: 22, weight: .semibold, design: .serif))
                Text("\(store.library?.sources.count ?? 0) " + store.t("fonti · pagine indicate", "sources · cited pages")).font(.caption).foregroundStyle(.secondary)
            }.padding(20)
            Divider()
            List(selection: $store.selectedSourceID) {
                ForEach((store.library?.sources ?? []).filter {
                    store.query.isEmpty || Library.normalized($0.title + " " + $0.fileName).contains(Library.normalized(store.query))
                }) { source in
                    HStack(alignment: .top, spacing: 13) {
                        Image(systemName: "doc.richtext").font(.system(size: 30, weight: .light))
                            .selectionAwareAccent(isSelected: store.selectedSourceID == source.id)
                        VStack(alignment: .leading, spacing: 7) {
                            Text(source.title).font(.system(size: 14, weight: .semibold))
                            Text("\(source.pageCount) " + store.t("pagine", "pages")).font(.caption).foregroundStyle(.secondary)
                            Text(source.origin == "reference" ? store.t("Riferimento matematico aggiunto", "Added mathematical reference") : source.origin == "generated" ? store.t("Lezione · appunti generati", "Lecture · generated study notes") : source.id == "E" ? store.t("Consegne degli esercizi", "Exercise questions") : store.t("Dispensa e appunti", "Course notes")).font(.caption2).foregroundStyle(.tertiary)
                        }
                    }.padding(.vertical, 13).tag(source.id)
                }
            }.listStyle(.inset)
        }
    }
}

struct SourceDetailView: View {
    @EnvironmentObject private var store: AppStore
    let source: SourceDocument
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text(store.t("BIBLIOTECA PERSONALE", "PERSONAL LIBRARY")).font(.system(size: 10, weight: .semibold)).tracking(1.5).foregroundStyle(Palette.accent)
                Text(source.title).font(.system(size: 38, weight: .medium, design: .serif))
                Text(store.language == .en ? source.authorshipEN ?? source.authorship : source.authorship).font(.callout).foregroundStyle(.secondary)
                Text(store.language == .en ? source.noteEN ?? source.note : source.note).font(.callout).lineSpacing(5)
                Button { store.open(source) } label: { Label(store.t("Apri o scegli il PDF originale", "Open or choose the source PDF"), systemImage: "doc.text.magnifyingglass") }
                    .buttonStyle(.borderedProminent)
                Divider()
                Text(store.t("Indice del documento", "Document outline")).font(.system(size: 24, weight: .medium, design: .serif))
                Text(store.t("Rimandi editoriali verificati sul documento; i titoli sono tradotti o raggruppati per la consultazione.", "Editorial browsing links verified against the document; headings are translated or grouped for navigation."))
                    .font(.caption).foregroundStyle(.secondary)
                ForEach(source.outline) { item in
                    Button { store.open(source, page: item.page) } label: {
                        HStack {
                            Text(store.language == .en ? item.titleEN ?? item.title : item.title).font(.system(size: 14))
                            Spacer()
                            Text(source.pageDescription(item.page, language: store.language)).font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
                            Image(systemName: "arrow.up.right").font(.caption)
                        }.padding(.vertical, 8)
                    }.buttonStyle(.plain)
                    Divider().opacity(0.4)
                }
                Text(store.t("Voci che usano questa fonte", "Entries using this source")).font(.system(size: 24, weight: .medium, design: .serif))
                ForEach((store.library?.concepts ?? []).filter { $0.citations.contains(where: { $0.sourceID == source.id }) }) { concept in
                    Button(concept.localized(store.language).title) { store.select(concept.id, reveal: true) }.buttonStyle(.link)
                }
                Divider()
                DisclosureGroup(store.t("Identità del file e metodo editoriale", "File identity and editorial method")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(source.fileName).font(.caption).textSelection(.enabled)
                        Text("SHA-256: " + source.sha256).font(.system(size: 10, design: .monospaced)).textSelection(.enabled)
                        Text(store.language == .en ? store.library?.editorialPolicyEN ?? "" : store.library?.editorialPolicy ?? "").font(.caption).lineSpacing(4)
                    }.padding(.top, 10)
                }.font(.caption)
            }.padding(40).frame(maxWidth: 850, alignment: .leading).frame(maxWidth: .infinity)
        }.background(Palette.paper)
    }
}
