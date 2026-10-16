import Foundation

public struct Library: Codable {
    public let schemaVersion: Int
    public let editorialPolicy: String
    public var editorialPolicyEN: String? = nil
    public let categories: [TopicCategory]
    public let sources: [SourceDocument]
    public let concepts: [Concept]

    public static func decode(_ data: Data) throws -> Library {
        let library = try JSONDecoder().decode(Library.self, from: data)
        let problems = library.validationErrors()
        guard problems.isEmpty else { throw LibraryError.invalid(problems.joined(separator: "\n")) }
        return library
    }

    public func concept(_ id: String) -> Concept? { concepts.first { $0.id == id } }
    public func source(_ id: String) -> SourceDocument? { sources.first { $0.id == id } }
    public func category(_ id: String) -> TopicCategory? { categories.first { $0.id == id } }
    public func backlinks(to id: String) -> [Concept] {
        concepts.filter { $0.prerequisites.contains(id) || $0.related.contains(id) }
    }

    public func search(_ query: String, category: String? = nil, saved: Set<String>? = nil) -> [Concept] {
        let tokens = Self.normalized(query).split(whereSeparator: \.isWhitespace).map(String.init)
        // A selection redraw with an empty query must not normalize the entire book.
        if tokens.isEmpty {
            return concepts.filter {
                (category == nil || $0.category == category) && (saved == nil || saved!.contains($0.id))
            }.sorted { $0.order < $1.order }
        }
        return concepts.compactMap { concept -> (Concept, Int)? in
            guard category == nil || concept.category == category,
                  saved == nil || saved!.contains(concept.id) else { return nil }
            let title = Self.normalized(([concept.title, concept.titleEN ?? ""] + concept.aliases).joined(separator: " "))
            let content = Self.normalized(([concept.summary, concept.summaryEN ?? ""] + concept.blocks.flatMap { [$0.text, $0.textEN ?? ""] }).joined(separator: " "))
            guard tokens.allSatisfy({ title.contains($0) || content.contains($0) }) else { return nil }
            let rank = tokens.reduce(0) { $0 + (title.contains($1) ? 10 : 1) }
            return (concept, rank)
        }.sorted {
            if $0.1 != $1.1 { return $0.1 > $1.1 }
            return $0.0.order < $1.0.order
        }.map(\.0)
    }

    public static func normalized(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "it_IT"))
    }

    public func validationErrors() -> [String] {
        var errors: [String] = []
        let ids = Set(concepts.map(\.id))
        if schemaVersion != 1 { errors.append("Versione del catalogo non supportata.") }
        if ids.count != concepts.count { errors.append("ID di voce duplicati.") }
        if Set(sources.map(\.id)).count != sources.count { errors.append("ID di fonte duplicati.") }
        if Set(categories.map(\.id)).count != categories.count { errors.append("ID di categoria duplicati.") }
        for source in sources {
            if source.pageCount != source.pageLabels.count { errors.append("Etichette di pagina: \(source.id)") }
            if source.fileName.contains("/") || source.fileName.contains("..") { errors.append("Nome PDF non valido.") }
            for item in source.outline where !(1...source.pageCount).contains(item.page) {
                errors.append("Indice fuori pagina: \(source.id)")
            }
        }
        for concept in concepts {
            if category(concept.category) == nil { errors.append("Categoria mancante: \(concept.id)") }
            if concept.blocks.isEmpty { errors.append("Voce vuota: \(concept.id)") }
            for target in concept.prerequisites + concept.related {
                if !ids.contains(target) || target == concept.id { errors.append("Rimando non valido: \(concept.id) → \(target)") }
            }
            if Set(concept.citations.map(\.id)).count != concept.citations.count { errors.append("Citazioni duplicate: \(concept.id)") }
            for citation in concept.citations {
                guard let document = source(citation.sourceID) else {
                    errors.append("Fonte mancante: \(concept.id)"); continue
                }
                if citation.page < 1 || citation.endPage < citation.page || citation.endPage > document.pageCount {
                    errors.append("Citazione fuori pagina: \(concept.id)")
                }
                if citation.evidence.isEmpty { errors.append("Riscontro mancante: \(concept.id)") }
            }
            for block in concept.blocks {
                if block.provenance == .source && block.citationIDs.isEmpty { errors.append("Blocco senza fonte: \(concept.id)") }
                if block.provenance == .editorial && !block.citationIDs.isEmpty { errors.append("Integrazione attribuita: \(concept.id)") }
                for ref in block.citationIDs where !concept.citations.contains(where: { $0.id == ref }) {
                    errors.append("Citazione non risolta: \(concept.id)/\(ref)")
                }
                if block.kind == .formula && (block.mathML == nil || block.latex == nil) { errors.append("Formula incompleta: \(concept.id)") }
            }
        }
        // A study prerequisite must not lead back to itself.
        func visit(_ id: String, path: Set<String>) {
            if path.contains(id) { errors.append("Ciclo nei prerequisiti: \(id)"); return }
            for next in concept(id)?.prerequisites ?? [] { visit(next, path: path.union([id])) }
        }
        for id in ids { visit(id, path: []) }
        return errors
    }
}

public enum LibraryError: LocalizedError {
    case invalid(String)
    public var errorDescription: String? { if case .invalid(let reason) = self { return reason }; return nil }
}

public struct TopicCategory: Codable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let symbol: String
    public var titleEN: String? = nil
    public var subtitleEN: String? = nil
    public func localized(_ language: AppLanguage) -> TopicCategory {
        guard language == .en else { return self }
        return TopicCategory(id: id, title: titleEN ?? title, subtitle: subtitleEN ?? subtitle, symbol: symbol, titleEN: titleEN, subtitleEN: subtitleEN)
    }
}

public struct SourceDocument: Codable, Identifiable {
    public let id: String
    public let title: String
    public var titleEN: String? = nil
    public let fileName: String
    public let authorship: String
    public let pageCount: Int
    public let sha256: String
    public let pageLabels: [String]
    public let outline: [OutlineItem]
    public let note: String
    public var noteEN: String? = nil
    public var origin: String? = nil
    public var authorshipEN: String? = nil
    public func localizedTitle(_ language: AppLanguage) -> String {
        language == .en ? (titleEN ?? title) : title
    }
    public func pageDescription(_ page: Int, language: AppLanguage = .it) -> String {
        guard page > 0 && page <= pageLabels.count else { return "Pagina non disponibile" }
        let label = pageLabels[page - 1]
        return language.text("PDF \(page) · pagina stampata \(label)", "PDF \(page) · printed page \(label)")
    }
}

public struct OutlineItem: Codable, Identifiable {
    public var id: String { "\(page)-\(title)" }
    public let title: String
    public let page: Int
    public var titleEN: String? = nil
}

public struct Concept: Codable, Identifiable {
    public let id: String
    public let order: Int
    public let title: String
    public let aliases: [String]
    public let category: String
    public let kind: String
    public let summary: String
    public let prerequisites: [String]
    public let related: [String]
    public let blocks: [ContentBlock]
    public let citations: [Citation]
    public var titleEN: String? = nil
    public var summaryEN: String? = nil
    public func localized(_ language: AppLanguage) -> Concept {
        guard language == .en else { return self }
        let englishKind = ["Concetto": "Concept", "Esercizio": "Exercise", "Esercizio svolto nei PDF": "Worked exercise in the PDFs"][kind] ?? kind
        return Concept(id: id, order: order, title: titleEN ?? title, aliases: aliases, category: category, kind: englishKind, summary: summaryEN ?? summary,
            prerequisites: prerequisites, related: related, blocks: blocks.map { $0.localized(language) }, citations: citations, titleEN: titleEN, summaryEN: summaryEN)
    }
}

public struct ContentBlock: Codable, Identifiable {
    public let id: String
    public let kind: BlockKind
    public let title: String
    public let text: String
    public let provenance: Provenance
    public let citationIDs: [String]
    public let latex: String?
    public let mathML: String?
    public var titleEN: String? = nil
    public var textEN: String? = nil
    public var illustration: String? = nil
    public var emphasized: Bool? = nil
    public func localized(_ language: AppLanguage) -> ContentBlock {
        guard language == .en else { return self }
        return ContentBlock(id: id, kind: kind, title: titleEN ?? title, text: textEN ?? text,
            provenance: provenance, citationIDs: citationIDs, latex: latex, mathML: mathML, titleEN: titleEN, textEN: textEN, illustration: illustration, emphasized: emphasized)
    }
}
public enum BlockKind: String, Codable { case paragraph, formula }
public enum Provenance: String, Codable { case source, editorial }

public struct Citation: Codable, Identifiable, Hashable {
    public let id: String
    public let sourceID: String
    public let page: Int
    public let endPage: Int
    public let section: String
    public let evidence: String
    public var sectionEN: String? = nil
}

public struct PersonalState: Codable {
    public var schemaVersion = 1
    public var bookmarks: Set<String> = []
    public var notes: [String: String] = [:]
    public var lastConceptID: String? = nil
    public var language: String? = nil
    public var theme: String? = nil
    public var gameRecords: [String: LogicRecord]? = nil
    public init() {}
    public static func read(from url: URL) throws -> PersonalState {
        let state = try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
        guard state.schemaVersion == 1 else { throw LibraryError.invalid("Formato delle note non supportato.") }
        return state
    }
    public func write(to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(self).write(to: url, options: .atomic)
    }
}

public enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case it, en
    public var id: String { rawValue }
    public func text(_ italian: String, _ english: String) -> String { self == .it ? italian : english }
}

public enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case automatic, light, dark
    public var id: String { rawValue }
    public func title(_ language: AppLanguage) -> String {
        switch self {
        case .automatic: return language.text("Automatico", "Automatic")
        case .light: return language.text("Chiaro", "Light")
        case .dark: return language.text("Scuro", "Dark")
        }
    }
}
