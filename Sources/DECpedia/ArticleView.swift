import SwiftUI
#if canImport(DECpediaCore)
import DECpediaCore
#endif

struct ArticleView: View {
    @EnvironmentObject private var store: AppStore
    let concept: Concept
    @State private var noteExpanded = false

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width > 790 && store.showContext
            HStack(alignment: .top, spacing: 0) {
                ScrollViewReader { reader in
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        header
                        Menu(store.t("Indice della voce", "Entry contents")) {
                            ForEach(concept.blocks) { block in
                                Button(block.title) { withAnimation { reader.scrollTo(block.id, anchor: .top) } }
                            }
                        }.menuStyle(.borderlessButton).fixedSize()
                        Divider()
                        ForEach(concept.blocks) { block in blockView(block).id(block.id) }
                        if !wide && store.showContext { connections }
                        sourceReferences
                        notes
                        Text(store.t("DECpedia · enciclopedia personale · consultazione offline", "DECpedia · personal encyclopedia · offline reading"))
                            .font(.caption2).foregroundStyle(.tertiary).padding(.top, 10)
                    }
                    .padding(.horizontal, wide ? 42 : 38)
                    .padding(.vertical, 34)
                    .frame(maxWidth: 820, alignment: .leading)
                    .frame(maxWidth: .infinity)
                }
                .background(Palette.paper)
                }
                if wide {
                    Divider()
                    ScrollView {
                        connections.padding(20)
                    }.frame(width: 218).background(Color(nsColor: .controlBackgroundColor))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { store.toggleBookmark(concept.id) } label: {
                    Image(systemName: store.personal.bookmarks.contains(concept.id) ? "bookmark.fill" : "bookmark")
                }.help(store.personal.bookmarks.contains(concept.id) ? store.t("Rimuovi dai preferiti", "Remove bookmark") : store.t("Salva nei preferiti", "Bookmark this entry"))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 7) {
                Image(systemName: store.category(concept.category)?.symbol ?? "book")
                Text((store.category(concept.category)?.title ?? "DEC").uppercased()).tracking(1.3)
            }.font(.system(size: 10, weight: .semibold)).foregroundStyle(Palette.accent)
            HStack(alignment: .top) {
                Text(concept.title).font(.system(size: 37, weight: .medium, design: .serif)).textSelection(.enabled)
                Spacer(minLength: 4)
            }
            RichMathView(text: concept.summary)
            HStack(spacing: 10) {
                Label("\(Set(concept.citations.map(\.sourceID)).count) \(Set(concept.citations.map(\.sourceID)).count == 1 ? store.t("fonte", "source") : store.t("fonti", "sources"))", systemImage: "doc.text")
                Text("·")
                Text(concept.kind)
                Spacer()
                Text(store.t("Testo in italiano", "English text")).foregroundStyle(Palette.accent)
            }.font(.system(size: 10)).foregroundStyle(.secondary)
            if concept.aliases.contains(where: { $0.caseInsensitiveCompare(concept.title) != .orderedSame }) {
                Text(concept.aliases.filter { $0.caseInsensitiveCompare(concept.title) != .orderedSame }.joined(separator: " · ")).font(.caption2).foregroundStyle(.tertiary).textSelection(.enabled)
            }
        }
    }

    @ViewBuilder
    private func blockView(_ block: ContentBlock) -> some View {
        let editorial = block.provenance == .editorial
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 7) {
                Text(block.title).font(.system(size: 13, weight: .semibold))
                Spacer()
                if editorial {
                    Text(store.t("INTEGRAZIONE DIDATTICA", "TEACHING ADDITION")).font(.system(size: 8, weight: .semibold)).foregroundStyle(.secondary)
                } else {
                    Text(store.t("FONTE", "SOURCE")).font(.system(size: 8, weight: .semibold)).tracking(1)
                        .padding(.horizontal, 6).padding(.vertical, 3).background(Palette.accent.opacity(0.09), in: Capsule())
                }
            }.foregroundStyle(Palette.accent)
            if block.kind == .formula, let math = block.mathML, let latex = block.latex {
                FormulaView(mathML: math, latex: latex, description: block.text)
            } else {
                RichMathView(text: block.text)
            }
            if let illustration = block.illustration { TeachingDiagram(kind: illustration) }
            if !block.citationIDs.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), alignment: .leading)], alignment: .leading, spacing: 9) {
                    ForEach(block.citationIDs, id: \.self) { id in
                        if let citation = concept.citations.first(where: { $0.id == id }), let source = store.library?.source(citation.sourceID) {
                            Button { store.open(citation) } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.right.square")
                                    Text("\(source.title) · PDF \(pageRange(citation))")
                                }.font(.system(size: 10))
                            }.buttonStyle(.link).help("\(citation.section) · \(source.pageDescription(citation.page, language: store.language))")
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var connections: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.t("COLLEGAMENTI TRA CONCETTI", "CONCEPT CONNECTIONS")).font(.system(size: 9, weight: .semibold)).tracking(1.2).foregroundStyle(.secondary)
                Text(store.t("Ogni idea si collega a un’altra.", "Every idea connects to another.")).font(.system(size: 19, weight: .medium, design: .serif))
            }
            if !concept.prerequisites.isEmpty { connectionGroup(store.t("Prima di iniziare", "Before you begin"), symbol: "arrow.turn.up.left", ids: concept.prerequisites) }
            if !concept.related.isEmpty { connectionGroup(store.t("Continua a esplorare", "Keep exploring"), symbol: "arrow.up.right", ids: concept.related) }
            let backlinks = (store.library?.backlinks(to: concept.id) ?? []).filter { !concept.related.contains($0.id) && !concept.prerequisites.contains($0.id) }
            if !backlinks.isEmpty { connectionGroup(store.t("Voci che rimandano qui", "Entries linking here"), symbol: "link", ids: backlinks.map(\.id)) }
            Divider()
            Label(store.t("Relazioni editoriali", "Editorial study links"), systemImage: "point.3.connected.trianglepath.dotted").font(.caption2).foregroundStyle(.secondary)
            Text(store.t("I collegamenti suggeriscono un percorso di studio. Non rappresentano un ordine ufficiale delle lezioni.", "These links suggest a study route. They do not represent an official lecture order."))
                .font(.caption2).foregroundStyle(.tertiary).lineSpacing(3)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func connectionGroup(_ title: String, symbol: String, ids: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 11, weight: .semibold)).foregroundStyle(.secondary)
            ForEach(ids, id: \.self) { id in
                if let target = store.concept(id) {
                    Button { store.select(id, reveal: true) } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Image(systemName: symbol).font(.system(size: 9)).frame(width: 12)
                            Text(target.title).font(.system(size: 12)).multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }.foregroundStyle(Palette.accent)
                    }.buttonStyle(.plain).help(target.title)
                }
            }
        }
    }

    private var sourceReferences: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
            Text(store.t("Fonti e riferimenti", "Sources and references")).font(.system(size: 24, weight: .medium, design: .serif))
            Text(store.t("PDF indica la posizione del foglio nel file, a partire da 1. La numerazione stampata può essere diversa.", "PDF pages are one-based positions in the file. Printed page labels may differ."))
                .font(.caption).foregroundStyle(.secondary).lineSpacing(3)
            ForEach(concept.citations) { citation in
                if let source = store.library?.source(citation.sourceID) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button { store.open(citation) } label: {
                            HStack(alignment: .top, spacing: 11) {
                                Image(systemName: "doc.richtext").font(.title3).foregroundStyle(Palette.accent)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(source.title).font(.system(size: 12, weight: .semibold))
                                    Text(store.language == .en ? citation.sectionEN ?? citation.section : citation.section).font(.caption).foregroundStyle(.secondary)
                                    Text("\(source.pageDescription(citation.page, language: store.language))\(citation.endPage == citation.page ? "" : store.t(" · fino a PDF \(citation.endPage)", " · through PDF \(citation.endPage)"))")
                                        .font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(Palette.accent)
                            }.padding(13).background(Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 8))
                        }.buttonStyle(.plain)
                        DisclosureGroup(store.t("Passo corrispondente nel PDF", "Matching passage in the PDF")) {
                            Text(citation.evidence).font(.caption).foregroundStyle(.secondary).lineSpacing(3).textSelection(.enabled).padding(.top, 5)
                        }.font(.system(size: 10)).padding(.horizontal, 8)
                    }
                }
            }
        }
    }

    private var notes: some View {
        DisclosureGroup(isExpanded: $noteExpanded) {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: store.noteBinding(for: concept.id))
                    .font(.system(size: 14)).frame(minHeight: 150)
                    .padding(8).overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.secondary.opacity(0.2)))
                Text(store.t("Note personali · salvataggio automatico sul Mac · ⌘S non necessario", "Personal notes · automatically saved on your Mac"))
                    .font(.caption2).foregroundStyle(.secondary)
            }.padding(.top, 10)
        } label: {
            Label(store.t("Il tuo taccuino", "Your notebook") + ((store.personal.notes[concept.id] ?? "").isEmpty ? "" : store.t(" · contiene note", " · has notes")), systemImage: "square.and.pencil")
                .font(.system(size: 13, weight: .medium))
        }
    }
    private func pageRange(_ citation: Citation) -> String {
        citation.page == citation.endPage ? "\(citation.page)" : "\(citation.page)–\(citation.endPage)"
    }
}
