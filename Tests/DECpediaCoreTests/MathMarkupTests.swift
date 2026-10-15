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
                        XCTAssertFalse(prose.contains(#"\("#) || prose.contains(#"\["#) || prose.contains(#"\)"#) || prose.contains(#"\]"#),concept.id)
                    case .inline(let math), .display(let math):
                        XCTAssertFalse(math.isEmpty,concept.id)
                        XCTAssertFalse(math.contains(#"\("#) || math.contains(#"\["#),concept.id)
                    }
                }
            }
        }
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
