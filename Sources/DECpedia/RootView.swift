import SwiftUI
#if canImport(DECpediaCore)
import DECpediaCore
#endif

enum Palette {
    static let accent = Color(nsColor: NSColor(name: nil) { appearance in
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return NSColor(calibratedRed: 0.43, green: 0.76, blue: 0.68, alpha: 1)
        }
        return NSColor(calibratedRed: 0.12, green: 0.43, blue: 0.39, alpha: 1)
    })
    static let paper = Color(nsColor: .textBackgroundColor)
    static let editorial = Color.orange
}

extension AppTheme {
    var colorScheme: ColorScheme? {
        switch self {
        case .automatic: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var visibility: NavigationSplitViewVisibility = .all
    var body: some View {
        Group {
            if store.library == nil {
                EmptyPane(symbol: "exclamationmark.triangle", title: store.t("La biblioteca non si apre", "Unable to open the library"), message: store.loadIssue ?? store.t("Controlla le risorse del progetto.", "Check the project resources."))
            } else {
                NavigationSplitView(columnVisibility: $visibility) {
                    sidebar.navigationSplitViewColumnWidth(min: 205, ideal: 225, max: 285)
                } content: {
                    if store.scope == "sources" {
                        SourceListView().navigationSplitViewColumnWidth(min: 250, ideal: 285, max: 360)
                    } else {
                        conceptList.navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 380)
                    }
                } detail: {
                    if store.scope == "sources" {
                        if let source = store.library?.sources.first(where: { $0.id == store.selectedSourceID }) {
                            SourceDetailView(source: source)
                        } else {
                            EmptyPane(symbol: "books.vertical", title: store.t("Le tue fonti", "Your sources"), message: store.t("Scegli un PDF dalla biblioteca.", "Choose a PDF from the library."))
                        }
                    } else if let concept = store.current {
                        ArticleView(concept: concept).id(concept.id)
                    } else {
                        EmptyPane(symbol: "book", title: store.t("Uno spazio per capire", "A space for understanding"), message: store.t("Scegli una voce o cerca un concetto.", "Choose an entry or search for a concept."))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Picker(store.t("Aspetto", "Appearance"), selection: $store.theme) {
                                ForEach(AppTheme.allCases) { theme in
                                    Text(theme.title(store.language)).tag(theme)
                                }
                            }
                        } label: {
                            Label(store.t("Aspetto", "Appearance"), systemImage: "circle.lefthalf.filled")
                        }
                        .help(store.t("Tema: ", "Theme: ") + store.theme.title(store.language))
                        .accessibilityLabel(store.t("Scegli il tema", "Choose a theme"))
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Picker(store.t("Lingua", "Language"), selection: $store.language) {
                            Text("IT").tag(AppLanguage.it)
                            Text("EN").tag(AppLanguage.en)
                        }.pickerStyle(.segmented).frame(width: 90)
                    }
                    ToolbarItem(placement: .automatic) {
                        NativeSearchField(text: $store.query, focusRequest: store.searchFocusRequest, placeholder: store.t("Cerca in DECpedia", "Search DECpedia"))
                            .frame(width: 255).help(store.t("Cerca in DECpedia · ⌘F", "Search DECpedia · ⌘F"))
                    }
                    ToolbarItemGroup(placement: .navigation) {
                        Button { store.moveHistory(-1) } label: { Image(systemName: "chevron.left") }
                            .help(store.t("Voce precedente", "Previous entry")).disabled(!store.canGoBack)
                            .keyboardShortcut("[", modifiers: .command)
                        Button { store.moveHistory(1) } label: { Image(systemName: "chevron.right") }
                            .help(store.t("Voce successiva", "Next entry")).disabled(!store.canGoForward)
                            .keyboardShortcut("]", modifiers: .command)
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button { store.scope = "sources"; store.query = "" } label: { Image(systemName: "books.vertical") }
                            .help(store.t("Apri la biblioteca delle fonti", "Open the source library"))
                        Button { store.showContext.toggle() } label: { Image(systemName: "sidebar.right") }
                            .help(store.t("Mostra o nascondi i collegamenti", "Show or hide connections"))
                    }
                }
            }
        }
        .sheet(item: $store.pdfRequest) { request in PDFReaderView(request: request) }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let issue = store.persistenceIssue {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                    Text(issue).font(.caption).textSelection(.enabled)
                    Spacer()
                }.padding(10).background(.regularMaterial)
            }
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11).fill(Palette.accent.gradient).frame(width: 40, height: 40)
                    Text("D").font(.system(size: 27, weight: .medium, design: .serif)).foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("DECpedia").font(.system(size: 20, weight: .semibold, design: .serif))
                    Text(store.t("La tua enciclopedia", "Your encyclopedia")).font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }.padding(.horizontal, 18).padding(.vertical, 22)
            List(selection: $store.scope) {
                Section(store.t("Biblioteca", "Library")) {
                    Label(store.t("Tutte le voci", "All entries"), systemImage: "books.vertical").tag("all")
                    Label(store.t("Preferiti", "Bookmarks"), systemImage: "bookmark").tag("saved")
                    Label(store.t("Fonti originali", "Source documents"), systemImage: "doc.richtext").tag("sources")
                }
                Section(store.t("Esplora gli argomenti", "Explore topics")) {
                    ForEach((store.library?.categories ?? []).map { $0.localized(store.language) }) { category in
                        HStack(spacing: 9) {
                            Image(systemName: category.symbol).foregroundStyle(Palette.accent).frame(width: 19)
                            Text(category.title).font(.system(size: 12.5))
                        }.padding(.vertical, 3).tag(category.id)
                    }
                }
            }
            .listStyle(.sidebar)
            .onChange(of: store.scope) { _ in store.query = "" }
            Divider().padding(.horizontal, 16)
            HStack(spacing: 7) {
                Circle().fill(Palette.accent).frame(width: 6, height: 6)
                Text(store.t("Tutto sul tuo Mac", "Everything on your Mac")).font(.caption)
                Spacer()
                Text("1.3 · IT/EN").font(.system(size: 9, weight: .medium, design: .monospaced)).foregroundStyle(.tertiary)
            }.foregroundStyle(.secondary).padding(18)
        }
    }

    private var conceptList: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 7) {
                Text(store.scopeTitle).font(.system(size: 22, weight: .semibold, design: .serif))
                Text(store.t("\(store.results.count) \(store.results.count == 1 ? "voce" : "voci")\(store.query.isEmpty ? " da esplorare" : " trovate")", "\(store.results.count) \(store.results.count == 1 ? "entry" : "entries")\(store.query.isEmpty ? " to explore" : " found")"))
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(20)
            Divider()
            if store.results.isEmpty {
                EmptyPane(symbol: store.scope == "saved" ? "bookmark" : "magnifyingglass", title: store.scope == "saved" && store.query.isEmpty ? store.t("I tuoi riferimenti", "Your references") : store.t("Nessun risultato", "No results"), message: store.scope == "saved" && store.query.isEmpty ? store.t("Salva una voce con il segnalibro mentre leggi.", "Bookmark an entry while reading.") : store.t("Prova un titolo, un sinonimo inglese o meno parole.", "Try a title, a synonym or fewer words."))
                if !store.query.isEmpty {
                    Button(store.t("Azzera la ricerca", "Clear search")) { store.query = "" }.padding(20)
                }
            } else {
                ScrollViewReader { proxy in
                  List(selection: Binding(get: { store.selectedID }, set: { if let id = $0 { store.select(id) } })) {
                    ForEach(store.results) { concept in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(concept.title).font(.system(size: 14, weight: .semibold))
                                Spacer(minLength: 0)
                                if store.personal.bookmarks.contains(concept.id) {
                                    Image(systemName: "bookmark.fill").font(.caption2).foregroundStyle(Palette.accent)
                                }
                            }
                            Text(concept.summary.contains("\\(") || concept.summary.contains("\\[") ? store.t("Definizioni, esempi e passaggi spiegati nella voce.", "Definitions, examples and reasoning inside the entry.") : concept.summary).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(2)
                            Text(store.category(concept.category)?.title ?? "")
                                .font(.system(size: 9, weight: .medium)).foregroundStyle(Palette.accent)
                        }.padding(.vertical, 9).tag(concept.id).id(concept.id)
                    }
                  }.listStyle(.inset)
                  .onAppear { if let id = store.selectedID { DispatchQueue.main.async { proxy.scrollTo(id, anchor: .center) } } }
                  .onChange(of: store.selectedID) { id in if let id { DispatchQueue.main.async { proxy.scrollTo(id, anchor: .center) } } }
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct EmptyPane: View {
    let symbol: String
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: symbol).font(.system(size: 36, weight: .light)).foregroundStyle(Palette.accent)
            Text(title).font(.system(size: 23, weight: .medium, design: .serif))
            Text(message).font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center).frame(maxWidth: 400)
        }.padding(32).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
