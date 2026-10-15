import SwiftUI
import AppKit

@main
struct DECpediaApp: App {
    @StateObject private var store = AppStore()
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
    }
    var body: some Scene {
        WindowGroup("DECpedia") {
            RootView().environmentObject(store)
                .frame(minWidth: 1120, minHeight: 720)
                .tint(Palette.accent)
                .onAppear { NSApplication.shared.activate(ignoringOtherApps: true) }
        }
        .defaultSize(width: 1460, height: 940)
        .commands {
            CommandGroup(after: .textEditing) {
                Button(store.t("Cerca in DECpedia", "Search DECpedia")) { store.searchFocusRequest += 1 }
                    .keyboardShortcut("f", modifiers: .command)
            }
            CommandGroup(after: .saveItem) {
                Button(store.t("Esporta note e preferiti…", "Export notes and bookmarks…")) { store.exportNotes() }
            }
            CommandMenu(store.t("Studio", "Study")) {
                Button(store.t("Tutte le voci", "All entries")) { store.scope = "all"; store.query = "" }
                    .keyboardShortcut("1", modifiers: .command)
                Button(store.t("Preferiti", "Bookmarks")) { store.scope = "saved"; store.query = "" }
                    .keyboardShortcut("2", modifiers: .command)
                Button(store.t("Biblioteca delle fonti", "Source library")) { store.scope = "sources" }
                    .keyboardShortcut("3", modifiers: .command)
                Divider()
                Button(store.t("Aggiungi o rimuovi dai preferiti", "Toggle bookmark")) {
                    if let id = store.selectedID { store.toggleBookmark(id) }
                }.keyboardShortcut("d", modifiers: .command).disabled(store.current == nil)
            }
        }
    }
}
