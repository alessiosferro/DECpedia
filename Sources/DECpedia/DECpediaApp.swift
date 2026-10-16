import SwiftUI
import AppKit
#if canImport(DECpediaCore)
import DECpediaCore
#endif

@main
struct DECpediaApp: App {
    @StateObject private var store = AppStore()
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
    }
    var body: some Scene {
        WindowGroup("DECpedia") {
            RootView().environmentObject(store)
                .preferredColorScheme(store.theme.colorScheme)
                .frame(minWidth: 1120, minHeight: 720)
                .tint(Palette.accent)
                .onAppear { NSApplication.shared.activate(ignoringOtherApps: true) }
        }
        .defaultSize(width: 1460, height: 940)
        .commands {
            #if DECPEDIA_MANUAL_QA
            CommandMenu("Manual QA") {
                Button("Next game") {
                    let games = store.games?.games ?? []
                    if let i = games.firstIndex(where: { $0.id == store.selectedGameID }), !games.isEmpty {
                        store.openGame(games[(i + 1) % games.count].id)
                    }
                }.keyboardShortcut("j", modifiers: [.control, .option])
                Button("Italian") { store.language = .it }.keyboardShortcut("i", modifiers: [.control, .option])
                Button("English") { store.language = .en }.keyboardShortcut("e", modifiers: [.control, .option])
                Button("Light") { store.theme = .light }.keyboardShortcut("l", modifiers: [.control, .option])
                Button("Dark") { store.theme = .dark }.keyboardShortcut("d", modifiers: [.control, .option])
                Button("Automatic") { store.theme = .automatic }.keyboardShortcut("a", modifiers: [.control, .option])
            }
            #endif
            CommandGroup(after: .textEditing) {
                Button(store.t("Cerca in DECpedia", "Search DECpedia")) { store.searchFocusRequest += 1 }
                    .keyboardShortcut("f", modifiers: .command)
            }
            CommandGroup(after: .saveItem) {
                Button(store.t("Esporta note e preferiti…", "Export notes and bookmarks…")) { store.exportNotes() }
            }
            CommandMenu(store.t("Aspetto", "Appearance")) {
                Picker(store.t("Tema", "Theme"), selection: $store.theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.title(store.language)).tag(theme)
                    }
                }
            }
            CommandMenu(store.t("Studio", "Study")) {
                Button(store.t("Tutte le voci", "All entries")) { store.scope = "all"; store.query = "" }
                    .keyboardShortcut("1", modifiers: .command)
                Button(store.t("Preferiti", "Bookmarks")) { store.scope = "saved"; store.query = "" }
                    .keyboardShortcut("2", modifiers: .command)
                Button(store.t("Biblioteca delle fonti", "Source library")) { store.scope = "sources" }
                    .keyboardShortcut("3", modifiers: .command)
                Button(store.t("Minigiochi", "Logic games")) { store.openGame() }
                    .keyboardShortcut("4", modifiers:.command)
                Divider()
                Button(store.t("Aggiungi o rimuovi dai preferiti", "Toggle bookmark")) {
                    if let id = store.selectedID { store.toggleBookmark(id) }
                }.keyboardShortcut("d", modifiers: .command).disabled(store.current == nil)
            }
        }
    }
}
