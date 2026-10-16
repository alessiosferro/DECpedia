import SwiftUI
import AppKit
import UniformTypeIdentifiers
#if canImport(DECpediaCore)
import DECpediaCore
#endif

@MainActor
final class AppStore: ObservableObject {
    @Published var library: Library?
    @Published var loadIssue: String?
    @Published var persistenceIssue: String?
    @Published var scope = "all"
    @Published var query = ""
    @Published var searchFocusRequest = 0
    @Published var language: AppLanguage = .it {
        didSet { personal.language = language.rawValue; save() }
    }
    @Published var theme: AppTheme = .automatic {
        didSet { personal.theme = theme.rawValue; save() }
    }
    @Published var selectedID: String? = nil
    @Published var selectedSourceID: String? = "C"
    @Published var personal = PersonalState()
    @Published var showContext = true
    @Published var pdfRequest: PDFRequest?
    @Published var games: LogicGames?
    @Published var gameLoadIssue: String?
    @Published var selectedGameID: String? {
        willSet {
            if let gameSession { suspendedGames[gameSession.gameID] = gameSession }
        }
        didSet { gameSession = selectedGameID.flatMap { suspendedGames[$0] } }
    }
    @Published var gameSession: LogicSession?
    private var suspendedGames: [String:LogicSession] = [:]
    @Published private(set) var history: [String] = []
    @Published private(set) var historyIndex = -1
    private var readOnlyState = false
    private let stateURL: URL

    init(stateURL: URL? = nil) {
        let isolatedURL = ProcessInfo.processInfo.environment["DECPEDIA_STATE_PATH"].map { URL(fileURLWithPath: $0) }
        self.stateURL = stateURL ?? isolatedURL ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DECpedia/state.json")
        do {
            let url = try Self.resourceURL("catalog.json")
            library = try Library.decode(Data(contentsOf: url))
            do {
                games = try LogicGames.decode(Data(contentsOf: Self.resourceURL("games.json")), library: library!)
                selectedGameID = games?.games.first?.id
            } catch { gameLoadIssue = error.localizedDescription }
            if FileManager.default.fileExists(atPath: self.stateURL.path) {
                do { personal = try PersonalState.read(from: self.stateURL) }
                catch {
                    readOnlyState = true
                    persistenceIssue = "Le note salvate non sono leggibili. Il file originale è stato conservato e il salvataggio è sospeso: \(error.localizedDescription)"
                }
            }
            let initial = personal.lastConceptID.flatMap { library?.concept($0)?.id } ?? "rsa"
            language = AppLanguage(rawValue: personal.language ?? "it") ?? .it
            theme = AppTheme(rawValue: personal.theme ?? "automatic") ?? .automatic
            selectedID = initial
            history = [initial]
            historyIndex = 0
        } catch { loadIssue = error.localizedDescription }
    }

    static func resourceURL(_ path: String) throws -> URL {
        if let root = Bundle.main.resourceURL {
            for folder in ["Resources", "DECpedia_DECpedia.bundle/Resources"] {
                let candidate = root.appendingPathComponent(folder + "/" + path)
                if FileManager.default.fileExists(atPath: candidate.path) { return candidate }
            }
        }
        #if SWIFT_PACKAGE
        let url = (Bundle.module.resourceURL ?? Bundle.module.bundleURL).appendingPathComponent("Resources/" + path)
        #else
        let url = (Bundle.main.resourceURL ?? Bundle.main.bundleURL).appendingPathComponent("Resources/" + path)
        #endif
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw LibraryError.invalid("Risorsa mancante: \(path)")
        }
        return url
    }

    var results: [Concept] {
        library?.search(query, category: ["all", "saved", "sources"].contains(scope) ? nil : scope,
                        saved: scope == "saved" ? personal.bookmarks : nil).map { $0.localized(language) } ?? []
    }
    var scopeTitle: String {
        if scope == "games" { return t("Minigiochi", "Logic games") }
        if scope == "saved" { return t("Preferiti", "Bookmarks") }
        return category(scope)?.title ?? t("Tutte le voci", "All entries")
    }
    var current: Concept? { selectedID.flatMap { library?.concept($0)?.localized(language) } }
    func category(_ id: String) -> TopicCategory? { library?.category(id)?.localized(language) }
    func concept(_ id: String) -> Concept? { library?.concept(id)?.localized(language) }
    func t(_ it: String, _ en: String) -> String { language.text(it, en) }
    var selectedGame: LogicGame? { selectedGameID.flatMap { games?.game($0) } }
    var visibleGames: [LogicGame] {
        let tokens = Library.normalized(query).split(whereSeparator: \.isWhitespace)
        return (games?.games ?? []).filter { game in
            let text = Library.normalized([game.title.it,game.title.en,game.introduction.it,game.introduction.en,category(game.id)?.title ?? ""].joined(separator:" "))
            return tokens.allSatisfy { text.contains($0) }
        }
    }
    func openGame(_ id: String? = nil) {
        if let id, games?.game(id) != nil { selectedGameID = id }
        scope = "games"; query = ""
    }
    func startGame(_ game: LogicGame) { gameSession = LogicSession(game:game) }
    @discardableResult
    func play(_ move: LogicMove, level: LogicLevel) -> Bool {
        guard var session = gameSession, !session.isComplete else { return false }
        let changed = session.run.apply(move,level:level)
        if changed { gameSession = session }
        return changed
    }
    func undoGame() { gameSession?.run.undo() }
    func restartLevel(_ level: LogicLevel) {
        guard gameSession?.run.levelID == level.id else { return }
        gameSession?.run.restart(level:level)
    }
    func gameHint(_ level: LogicLevel) {
        guard gameSession?.run.levelID == level.id else { return }
        gameSession?.run.revealHint(level:level)
    }
    func advanceGame(_ game: LogicGame) {
        guard var session = gameSession, session.advance(game:game) else { return }
        gameSession = session
        if session.isComplete {
            var records = personal.gameRecords ?? [:]
            records[game.id] = LogicRecord(session:session,levels:game.levels.count,previous:records[game.id])
            personal.gameRecords = records; save()
        }
    }
    var canGoBack: Bool { historyIndex > 0 }
    var canGoForward: Bool { historyIndex + 1 < history.count }

    func select(_ id: String, reveal: Bool = false) {
        guard library?.concept(id) != nil else { return }
        if reveal { scope = "all"; query = "" }
        selectedID = id
        if historyIndex < 0 || history[historyIndex] != id {
            history = Array(history.prefix(historyIndex + 1))
            history.append(id)
            historyIndex = history.count - 1
        }
        personal.lastConceptID = id
        save()
    }
    func moveHistory(_ offset: Int) {
        let index = historyIndex + offset
        guard history.indices.contains(index) else { return }
        historyIndex = index
        selectedID = history[index]
        scope = "all"
        query = ""
        personal.lastConceptID = selectedID
        save()
    }
    func toggleBookmark(_ id: String) {
        if personal.bookmarks.contains(id) { personal.bookmarks.remove(id) }
        else { personal.bookmarks.insert(id) }
        save()
    }
    func noteBinding(for id: String) -> Binding<String> {
        Binding(get: { self.personal.notes[id] ?? "" }, set: { value in
            if value.isEmpty { self.personal.notes.removeValue(forKey: id) }
            else { self.personal.notes[id] = value }
            self.save()
        })
    }
    func open(_ citation: Citation) {
        guard let source = library?.source(citation.sourceID) else { return }
        open(source, page: citation.page, endPage: citation.endPage)
    }
    func open(_ source: SourceDocument, page: Int = 1, endPage: Int? = nil) {
        guard (1...source.pageCount).contains(page) else { return }
        let url: URL
        if let bundled = try? Self.resourceURL("PDFs/" + source.fileName) {
            url = bundled
        } else {
            let panel = NSOpenPanel()
            panel.title = t("Scegli il documento originale", "Choose the source document")
            panel.message = t("DECpedia conserva i riferimenti bibliografici, ma non distribuisce i PDF. Seleziona una copia locale autorizzata.", "DECpedia keeps bibliographic references but does not distribute PDFs. Choose an authorized local copy.")
            panel.prompt = t("Apri PDF", "Open PDF")
            panel.allowedContentTypes = [.pdf]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            guard panel.runModal() == .OK, let selected = panel.url else { return }
            url = selected
        }
        pdfRequest = PDFRequest(source: source, url: url, page: page, endPage: endPage ?? page)
    }
    func exportNotes() {
        let panel = NSSavePanel()
        panel.title = t("Esporta note e preferiti", "Export notes and bookmarks")
        panel.nameFieldStringValue = "DECpedia-note.json"
        panel.allowedContentTypes = [.json]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do { try personal.write(to: url) }
        catch { persistenceIssue = t("Esportazione non riuscita: \(error.localizedDescription)", "Export failed: \(error.localizedDescription)") }
    }
    private func save() {
        guard !readOnlyState else { return }
        do { try personal.write(to: stateURL); persistenceIssue = nil }
        catch { persistenceIssue = t("Salvataggio non riuscito: \(error.localizedDescription)", "Save failed: \(error.localizedDescription)") }
    }
}

struct PDFRequest: Identifiable {
    let id = UUID()
    let source: SourceDocument
    let url: URL
    let page: Int
    let endPage: Int
}
