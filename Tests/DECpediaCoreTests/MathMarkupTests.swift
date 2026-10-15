import XCTest
@testable import DECpediaCore

final class MathMarkupTests: XCTestCase {
    func testInlineDisplayAndProseAreSeparatedAndEscaped() {
        let text = #"Se \(a<2\), allora \[a^2<4.\] <script>&"#
        XCTAssertEqual(MathMarkup.fragments(text), [.prose("Se "),.inline("a<2"),.prose(", allora "),.display("a^2<4."),.prose(" <script>&")])
        let html = MathMarkup.html(text)
        XCTAssertFalse(html.contains("<script>"))
        XCTAssertTrue(html.contains("&lt;script&gt;&amp;"))
        XCTAssertTrue(html.contains("class=\"math display\""))
        XCTAssertEqual(MathMarkup.fragments(#"unclosed \(a"#), [.prose(#"unclosed \(a"#)])
        let steps = #"\[\begin{aligned}a&=b\\[4pt]&=c\end{aligned}\]"#
        XCTAssertEqual(MathMarkup.fragments(steps).count, 1)
    }

    func testKeyConceptsAreExplicitAndCannotInjectHTML() {
        let html = MathMarkup.html(#"A **key <concept>** and **\(a<2\)**, then \(3\)."#)
        XCTAssertTrue(html.contains("<strong class=\"key-concept\">key &lt;concept&gt;</strong>"))
        XCTAssertTrue(html.contains("<strong class=\"key-concept\"><span class=\"math inline\">a&lt;2</span></strong>"))
        XCTAssertTrue(html.hasSuffix("<span class=\"math inline\">3</span>."))
        XCTAssertFalse(html.contains("<concept>"))
        XCTAssertEqual(MathMarkup.html("An **unfinished marker"), "An **unfinished marker")
    }

    func testLongProofsIncludeThePrerequisiteProofTextInBothLanguages() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let lib = try Library.decode(Data(contentsOf: root.appendingPathComponent("Sources/DECpedia/Resources/catalog.json")))
        for (target, prerequisite) in [("riemann-roch", "local-trace-duality"), ("riemann-roch", "laurent-duality"), ("prime-number", "newman-lemma")] {
            let source = try XCTUnwrap(lib.concept(prerequisite))
            let embedded = try XCTUnwrap(lib.concept(target)?.blocks.first { $0.id == "foundation-" + prerequisite })
            XCTAssertEqual(embedded.provenance, .editorial)
            for key in [AppLanguage.it, .en] {
                let sourceTexts = source.localized(key).blocks.filter { $0.provenance == .editorial && $0.id != "editorial-note" }.map(\.text)
                let embeddedText = embedded.localized(key).text.filter { !$0.isWhitespace }
                for text in sourceTexts { XCTAssertTrue(embeddedText.contains(text.filter { !$0.isWhitespace }), target + " / " + prerequisite) }
            }
        }
    }

    func testAllStudyNumeralsAreLaTeXAndDelimitersAreBalanced() throws {
        let root = URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let data = try Data(contentsOf:root.appendingPathComponent("Sources/DECpedia/Resources/catalog.json"))
        let lib = try Library.decode(data)
        for concept in lib.concepts {
            for text in [concept.summary,concept.summaryEN ?? ""] + concept.blocks.flatMap({[$0.text,$0.textEN ?? ""]}) {
                for fragment in MathMarkup.fragments(text) {
                    switch fragment {
                    case .prose(let prose):
                        XCTAssertNil(prose.rangeOfCharacter(from:.decimalDigits),concept.id+": "+prose)
                        XCTAssertFalse(hasUnescapedDelimiter(prose),concept.id)
                    case .inline(let math), .display(let math):
                        XCTAssertFalse(math.isEmpty,concept.id)
                        XCTAssertFalse(hasUnescapedDelimiter(math),concept.id)
                    }
                }
            }
        }
    }

    private func hasUnescapedDelimiter(_ text: String) -> Bool {
        var slashes = 0
        for character in text {
            if character == "\\" { slashes += 1; continue }
            if "()[]".contains(character) && slashes % 2 == 1 { return true }
            slashes = 0
        }
        return false
    }

    func testAdvancedProofsHaveCompleteDependencyRoutes() throws {
        let root = URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let lib = try Library.decode(Data(contentsOf:root.appendingPathComponent("Sources/DECpedia/Resources/catalog.json")))
        func ancestors(_ id:String) -> Set<String> {
            let direct = lib.concept(id)?.prerequisites ?? []
            return direct.reduce(Set(direct)) { $0.union(ancestors($1)) }
        }
        XCTAssertTrue(ancestors("riemann-roch").isSuperset(of:["local-algebra-basics","separating-variable","modules-normalization","local-valuations","finite-maps-norm","differentials-trace","local-trace-duality","cech-balance","laurent-duality"]))
        XCTAssertTrue(ancestors("prime-number").isSuperset(of:["analysis-foundations","complex-cauchy","chebyshev-bounds","zeta-euler","zeta-boundary","newman-lemma"]))
        XCTAssertTrue(ancestors("mumford-proof").contains("riemann-roch"))
        for id in ["riemann-roch","prime-number","mumford-proof","elliptic-picard-proof","hyperelliptic-genus"] {
            let c = try XCTUnwrap(lib.concept(id))
            XCTAssertTrue(c.blocks.allSatisfy { $0.provenance == .editorial })
            XCTAssertFalse(c.blocks.contains { $0.text.contains("teorema assunto") || ($0.textEN ?? "").contains("assumed theorem") })
        }
    }
}
