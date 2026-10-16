import XCTest
@testable import DECpediaCore

final class LogicGamesTests:XCTestCase {
    private var resources:URL { URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Sources/DECpedia/Resources") }
    private func catalog() throws -> LogicGames {
        let library=try Library.decode(Data(contentsOf:resources.appendingPathComponent("catalog.json")))
        return try LogicGames.decode(Data(contentsOf:resources.appendingPathComponent("games.json")),library:library)
    }
    private func moves(_ run:LogicRun,_ level:LogicLevel) -> [LogicMove] {
        switch level.kind {
        case .gears:return level.gears!.moves.indices.map(LogicMove.gear)
        case .xor,.parity:return run.state.values.indices.map(LogicMove.flip)
        case .route:return level.route!.nodes.first {$0.id == run.state.nodeID}!.exits.map(LogicMove.travel)
        case .curve:return level.curve!.moves.indices.map(LogicMove.curve)
        case .seals:return level.seals!.messages.flatMap {m in level.seals!.seals.map {LogicMove.assign(m.id,$0.id)}}
        case .factor:return run.state.factors.indices.flatMap {i in level.factor!.tools.indices.map {LogicMove.factor(i,$0)}}
        case .allocation:return level.allocation!.stations.flatMap {s in level.allocation!.cards.map {LogicMove.assign(s.id,$0.id)}}
        }
    }
    private func key(_ state:LogicState) -> String {
        "\(state.values)|\(state.nodeID)|\(state.tokens.sorted())|\(state.point)|\(state.factors)|\(state.usedTools.sorted())|"+state.assignments.keys.sorted().map {$0+":"+state.assignments[$0]!}.joined(separator:";")
    }
    private func solve(_ level:LogicLevel) throws -> LogicRun {
        var queue=[LogicRun(level:level)], cursor=0, seen=Set<String>()
        seen.insert(key(queue[0].state))
        while cursor < queue.count {
            let run=queue[cursor]; cursor += 1
            if run.isSolved(level:level) { return run }
            for move in moves(run,level) {
                var next=run
                if next.apply(move,level:level), seen.insert(key(next.state)).inserted { queue.append(next) }
            }
        }
        XCTFail("Unsolvable level within its move budget: \(level.id)")
        throw LibraryError.invalid(level.id)
    }
    func testEverySectionHasBilingualInteractiveLevelsAndSolvableBoards() throws {
        let games=try catalog()
        XCTAssertEqual(games.games.count,11)
        XCTAssertEqual(games.games.flatMap(\.levels).count,33)
        XCTAssertEqual(Set(games.games.flatMap(\.levels).map(\.kind)),Set([.gears,.xor,.route,.curve,.seals,.factor,.parity,.allocation]))
        for level in games.games.flatMap(\.levels) {
            let solution=try solve(level)
            XCTAssertGreaterThan(solution.moveCount,0,level.id)
            XCTAssertLessThanOrEqual(solution.moveCount,level.moveLimit,level.id)
        }
        let data=try Data(contentsOf:resources.appendingPathComponent("games.json"))
        let json=try JSONSerialization.jsonObject(with:data)
        let math=try NSRegularExpression(pattern:#"\\\([\s\S]*?\\\)|\\\[[\s\S]*?\\\]"#)
        func check(_ value:Any) {
            if let dict=value as? [String:Any] {
                if let it=dict["it"] as? String, let en=dict["en"] as? String {
                    for text in [it,en] {
                        XCTAssertFalse(text.isEmpty)
                        let prose=math.stringByReplacingMatches(in:text,range:NSRange(text.startIndex...,in:text),withTemplate:"")
                        XCTAssertFalse(prose.contains(where:\.isNumber),"Number outside LaTeX: \(prose)")
                    }
                }
                dict.values.forEach(check)
            } else if let list=value as? [Any] {list.forEach(check)}
        }
        check(json)
    }
    func testUndoRestoresInventoryAndOneUseToolsAndLockedBitsCannotMove() throws {
        let games=try catalog()
        let factor=games.game("factoring")!.levels[0]
        var run=LogicRun(level:factor); let original=run.state
        XCTAssertTrue(run.apply(.factor(0,0),level:factor))
        XCTAssertTrue(run.state.usedTools.contains(0))
        XCTAssertEqual(run.state.factors.reduce(1,*),factor.factor!.number)
        run.undo(); XCTAssertEqual(run.state,original)
        XCTAssertTrue(run.apply(.factor(0,0),level:factor))
        let route=games.game("proof-geometry")!.levels[0]
        run=LogicRun(level:route)
        XCTAssertFalse(run.apply(.travel("rightA"),level:route))
        XCTAssertTrue(run.apply(.travel("leftA"),level:route))
        XCTAssertTrue(run.state.tokens.contains("left-pre"))
        run.undo(); XCTAssertFalse(run.state.tokens.contains("left-pre"))
        let parity=games.game("linear")!.levels[2]
        run=LogicRun(level:parity)
        let before=run.state
        XCTAssertFalse(run.apply(.flip(0),level:parity))
        XCTAssertEqual(run.state,before)
        XCTAssertFalse(run.apply(.curve(0),level:parity))
    }
    func testCurveLawAndRSAVerificationAgainstKnownExamples() throws {
        let games=try catalog()
        let curve=games.game("curves")!.levels[0].curve!
        XCTAssertEqual(curve.adding(CurvePoint(x:0,y:1),CurvePoint(x:0,y:1)),CurvePoint(x:4,y:2))
        for level in games.games.flatMap(\.levels) {
            if let c=level.curve {
                for p in c.points {
                    XCTAssertEqual(c.adding(p,.infinity),p)
                    XCTAssertEqual(c.adding(p,CurvePoint(x:p.x,y:mod(-p.y!,c.p))),.infinity)
                    for q in c.points {XCTAssertTrue(c.contains(c.adding(p,q)))}
                }
            }
            if let s=level.seals {
                XCTAssertEqual(Set(s.messages.map(\.digest)).count,s.messages.count)
                for m in s.messages {XCTAssertEqual(s.seals.filter {modularPower($0.value,s.e,s.n) == m.digest}.count,1)}
            }
        }
        XCTAssertEqual(modularPower(18,3,55),2)
        XCTAssertEqual(modularPower(16,3,33),4)
    }
    func testCompletedGameRecordsAndOldNotesRemainCompatible() throws {
        let games=try catalog(); let game=games.game("algebra")!
        var session=LogicSession(game:game)
        XCTAssertFalse(session.advance(game:game))
        for level in game.levels {
            session.run=try solve(level)
            XCTAssertTrue(session.advance(game:game))
        }
        XCTAssertTrue(session.isComplete)
        let moves=session.totalMoves
        XCTAssertFalse(session.advance(game:game)); XCTAssertEqual(session.totalMoves,moves)
        let old=Data(#"{"schemaVersion":1,"bookmarks":["rsa"],"notes":{"rsa":"keep me"},"theme":"light","language":"en"}"#.utf8)
        var state=try JSONDecoder().decode(PersonalState.self,from:old)
        XCTAssertNil(state.gameRecords)
        state.gameRecords=[game.id:LogicRecord(session:session,levels:game.levels.count,previous:nil)]
        let decoded=try JSONDecoder().decode(PersonalState.self,from:JSONEncoder().encode(state))
        XCTAssertEqual(decoded.notes["rsa"],"keep me")
        XCTAssertEqual(decoded.bookmarks,["rsa"])
        XCTAssertEqual(decoded.gameRecords?[game.id]?.bestMoves,moves)
        XCTAssertEqual(decoded.gameRecords?[game.id]?.completedRuns,1)
    }
    func testMoveLimitsAndAssignmentsAreTransactional() throws {
        let games=try catalog()
        let level=games.game("linear")!.levels[0]
        var run=LogicRun(level:level)
        XCTAssertFalse(run.apply(.flip(-1),level:level))
        XCTAssertTrue(run.apply(.flip(0),level:level))
        let before=run.state
        XCTAssertFalse(run.apply(.flip(1),level:level))
        XCTAssertEqual(run.state,before)
        run.undo(); XCTAssertEqual(run.moveCount,0)
        let allocation=games.game("families")!.levels[0]
        run=LogicRun(level:allocation)
        XCTAssertTrue(run.apply(.assign("alarm","rep5"),level:allocation))
        XCTAssertTrue(run.apply(.assign("photo","ham"),level:allocation))
        XCTAssertTrue(run.apply(.assign("alarm","ham"),level:allocation))
        XCTAssertEqual(run.state.assignments["photo"],"rep5")
        XCTAssertEqual(Set(run.state.assignments.values).count,run.state.assignments.count)
        XCTAssertFalse(run.apply(.assign("not-a-slot","ham"),level:allocation))
    }
}
