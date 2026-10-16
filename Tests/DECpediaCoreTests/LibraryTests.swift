import XCTest
#if canImport(FoundationXML)
import FoundationXML
#endif
import PDFKit
import CryptoKit
@testable import DECpediaCore

final class LibraryTests: XCTestCase {
    private var root: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
    private var resources: URL { root.appendingPathComponent("Sources/DECpedia/Resources") }
    private func data() throws -> Data { try Data(contentsOf: resources.appendingPathComponent("catalog.json")) }
    private func library() throws -> Library { try Library.decode(data()) }

    func testCompleteLibraryAndEveryLink() throws {
        let lib = try library()
        XCTAssertEqual(lib.concepts.count, 121)
        XCTAssertEqual(lib.concepts.filter { $0.category == "exercises" }.count, 27)
        XCTAssertEqual(lib.sources.map(\.pageCount).reduce(0, +), 339)
        XCTAssertTrue(lib.validationErrors().isEmpty)
        XCTAssertTrue(lib.backlinks(to: "rsa").contains { $0.id == "rsa-signature" })
        XCTAssertTrue(lib.concept("ex-14")!.related.contains("appunti-ex-1"))
    }

    func testRealPDFsPaginationHashesAndCitationEvidence() throws {
        let lib = try library()
        func normalize(_ text: String) -> String {
            String(text.decomposedStringWithCompatibilityMapping.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }).lowercased()
        }
        for source in lib.sources {
            let url = resources.appendingPathComponent("PDFs/" + source.fileName)
            // Public source distributions omit third-party PDFs. When a local
            // copy is present, keep verifying its hash, page labels and citations.
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            let bytes = try Data(contentsOf: url)
            XCTAssertEqual(SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined(), source.sha256)
            let pdf = try XCTUnwrap(PDFDocument(url: url))
            XCTAssertEqual(pdf.pageCount, source.pageCount)
            for index in 0..<pdf.pageCount {
                XCTAssertEqual(pdf.page(at: index)?.label, source.pageLabels[index], "\(source.id) PDF \(index+1)")
            }
            for concept in lib.concepts {
                for citation in concept.citations where citation.sourceID == source.id {
                    let text = (citation.page...citation.endPage).compactMap { pdf.page(at: $0-1)?.string }.joined(separator: " ")
                    let expected = String(normalize(citation.evidence).prefix(70))
                    XCTAssertGreaterThan(expected.count, 12)
                    XCTAssertTrue(normalize(text).contains(expected), "Riscontro non trovato: \(concept.id), \(source.id), \(citation.page): \(expected)")
                }
            }
        }
    }

    func testFormulasAreWellFormedOfflineMathML() throws {
        let lib = try library()
        let blocks = lib.concepts.flatMap(\.blocks).filter { $0.kind == .formula }
        XCTAssertGreaterThan(blocks.count, 25)
        for block in blocks {
            let math = try XCTUnwrap(block.mathML)
            let parser = XMLParser(data: Data(math.utf8))
            parser.shouldResolveExternalEntities = false
            XCTAssertTrue(parser.parse(), "\(block.id): \(String(describing: parser.parserError))")
            XCTAssertTrue(math.hasPrefix("<math xmlns=\"http://www.w3.org/1998/Math/MathML\""))
            for forbidden in ["<script", "<iframe", "<img", "<a ", "href=", "src=", "<!DOCTYPE", "onclick"] {
                XCTAssertFalse(math.lowercased().contains(forbidden.lowercased()))
            }
            XCTAssertFalse(try XCTUnwrap(block.latex).isEmpty)
        }
    }

    func testItalianEnglishSearchAndFilters() throws {
        let lib = try library()
        XCTAssertEqual(lib.search("rsa").first?.id, "rsa")
        XCTAssertTrue(lib.search("VIGENERE").contains { $0.id == "vigenere" })
        XCTAssertTrue(lib.search("elliptic curve").contains { $0.id == "elliptic-curves" })
        XCTAssertTrue(lib.search("Bézout").contains { $0.id == "euclid" })
        XCTAssertEqual(lib.search("", saved: ["rsa", "bch"]).map(\.id), ["rsa", "bch"])
        XCTAssertTrue(lib.search("", category: "classic").allSatisfy { $0.category == "classic" })
        XCTAssertTrue(lib.search("no-such-concept-23121").isEmpty)
        XCTAssertTrue(lib.search("", saved: []).isEmpty)
        XCTAssertEqual(lib.search(" \n ").count, 121)
    }

    func testProvenanceIsExplicit() throws {
        for concept in try library().concepts {
            XCTAssertFalse(concept.citations.isEmpty)
            for block in concept.blocks {
                if block.provenance == .source {
                    XCTAssertFalse(block.citationIDs.isEmpty, concept.id)
                } else {
                    XCTAssertTrue(block.citationIDs.isEmpty, concept.id)
                    XCTAssertEqual(block.provenance, .editorial, concept.id)
                }
            }
        }
    }

    func testBilingualTeachingCoverageAndGeneratedSources() throws {
        let lib = try library()
        XCTAssertEqual(lib.sources.count, 10)
        XCTAssertEqual(lib.sources.filter { $0.origin == "generated" }.count, 4)
        for category in lib.categories {
            XCTAssertFalse(try XCTUnwrap(category.titleEN).isEmpty)
        }
        for source in lib.sources {
            XCTAssertFalse(try XCTUnwrap(source.titleEN).isEmpty, source.id)
        }
        XCTAssertEqual(lib.source("C")?.localizedTitle(.it), "Crittografia · revisione 2")
        XCTAssertEqual(lib.source("C")?.localizedTitle(.en), "Cryptography · Rev. 2")
        for concept in lib.concepts {
            XCTAssertFalse(try XCTUnwrap(concept.titleEN).isEmpty, concept.id)
            XCTAssertFalse(try XCTUnwrap(concept.summaryEN).isEmpty, concept.id)
            let explanations = concept.blocks.filter { $0.id.hasPrefix("learn-") || $0.id.hasPrefix("proof-") }
            XCTAssertGreaterThanOrEqual(explanations.count, 2, concept.id)
            XCTAssertGreaterThan(explanations.map { $0.text.count }.reduce(0,+), 500, concept.id)
            XCTAssertGreaterThan(explanations.map { $0.textEN?.count ?? 0 }.reduce(0,+), 500, concept.id)
            for block in concept.blocks {
                XCTAssertFalse(try XCTUnwrap(block.titleEN).isEmpty, concept.id)
                XCTAssertFalse(try XCTUnwrap(block.textEN).isEmpty, concept.id)
            }
            let en = concept.localized(.en)
            XCTAssertEqual(en.title, concept.titleEN)
            XCTAssertEqual(en.blocks.map(\.text), concept.blocks.compactMap(\.textEN))
        }
        XCTAssertTrue(lib.search("conditional probability").contains { $0.id == "probability-basics" })
        XCTAssertTrue(lib.search("Buffon").contains { $0.id == "buffon" })
        XCTAssertEqual(lib.source("L14")!.pageDescription(14, language: .en), "PDF 14 · printed page 14")
    }

    func testEveryEntryIntroducesTheIdeaBeforeItsFormulaCard() throws {
        for concept in try library().concepts {
            XCTAssertEqual(concept.blocks.first?.kind, .paragraph, concept.id)
            let firstExplanation = try XCTUnwrap(concept.blocks.firstIndex { $0.kind == .paragraph }, concept.id)
            for (index, block) in concept.blocks.enumerated() where block.kind == .formula {
                XCTAssertGreaterThan(index, firstExplanation, concept.id)
            }
        }
    }

    func testRejectsBrokenCitationsAndPrerequisiteCycles() throws {
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: data()) as? [String: Any])
        var concepts = try XCTUnwrap(json["concepts"] as? [[String: Any]])
        var citations = try XCTUnwrap(concepts[0]["citations"] as? [[String: Any]])
        citations[0]["page"] = 999
        concepts[0]["citations"] = citations
        json["concepts"] = concepts
        XCTAssertThrowsError(try Library.decode(JSONSerialization.data(withJSONObject: json)))
        json = try XCTUnwrap(JSONSerialization.jsonObject(with: data()) as? [String: Any])
        concepts = try XCTUnwrap(json["concepts"] as? [[String: Any]])
        concepts[0]["prerequisites"] = [concepts[1]["id"] as! String]
        concepts[1]["prerequisites"] = [concepts[0]["id"] as! String]
        json["concepts"] = concepts
        XCTAssertThrowsError(try Library.decode(JSONSerialization.data(withJSONObject: json)))
    }

    func testPersonalNotesPersistAndUnknownSchemaIsRejected() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("notes/state.json")
        var personal = PersonalState()
        personal.bookmarks = ["rsa", "hamming"]
        personal.notes["rsa"] = "Rivedere la dimostrazione, con p ∣ m.\nSeconda riga."
        personal.lastConceptID = "rsa"
        personal.language = "en"
        personal.theme = AppTheme.light.rawValue
        try personal.write(to: url)
        let loaded = try PersonalState.read(from: url)
        XCTAssertEqual(loaded.bookmarks, personal.bookmarks)
        XCTAssertEqual(loaded.notes, personal.notes)
        XCTAssertEqual(loaded.lastConceptID, "rsa")
        XCTAssertEqual(loaded.language, "en")
        XCTAssertEqual(loaded.theme, "light")
        personal.schemaVersion = 99
        try personal.write(to: url)
        XCTAssertThrowsError(try PersonalState.read(from: url))
    }

    func testAppearanceIsBackwardCompatibleWithExistingNotes() throws {
        let oldState = #"{"schemaVersion":1,"bookmarks":["rsa"],"notes":{"rsa":"Keep this note"},"language":"en"}"#
        let state = try JSONDecoder().decode(PersonalState.self, from: Data(oldState.utf8))
        XCTAssertNil(state.theme)
        XCTAssertEqual(AppTheme(rawValue: state.theme ?? "automatic"), .automatic)
        XCTAssertEqual(state.notes["rsa"], "Keep this note")
        for theme in AppTheme.allCases {
            var changed = state
            changed.theme = theme.rawValue
            let restored = try JSONDecoder().decode(PersonalState.self, from: JSONEncoder().encode(changed))
            XCTAssertEqual(restored.theme, theme.rawValue)
            XCTAssertEqual(restored.bookmarks, ["rsa"])
        }
    }

    func testRenderedAndPrintedPageNumbersAreDistinct() throws {
        let lib = try library()
        XCTAssertEqual(lib.source("C")!.pageDescription(19), "PDF 19 · pagina stampata 18")
        XCTAssertEqual(lib.source("E")!.pageDescription(1), "PDF 1 · pagina stampata 1")
    }
}
