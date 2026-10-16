import Foundation

public struct GameText: Codable {
    public let it: String
    public let en: String
    public func value(_ language: AppLanguage) -> String { language.text(it, en) }
}
public enum PuzzleKind: String, Codable { case gears, xor, route, curve, seals, factor, parity, allocation }
public struct LogicGame: Codable, Identifiable {
    public var id: String { categoryID }
    public let categoryID: String
    public let revision: Int?
    public let title: GameText
    public let introduction: GameText
    public let levels: [LogicLevel]
}
public struct LogicLevel: Codable, Identifiable {
    public let id: String
    public let title: GameText
    public let mission: GameText
    public let hints: [GameText]
    public let explanation: GameText
    public let conceptIDs: [String]
    public let moveLimit: Int
    public let kind: PuzzleKind
    public let gears: GearPuzzle?
    public let xor: XORPuzzle?
    public let route: RoutePuzzle?
    public let curve: CurvePuzzle?
    public let seals: SealPuzzle?
    public let factor: FactorPuzzle?
    public let parity: ParityPuzzle?
    public let allocation: AllocationPuzzle?
}
public struct GearPuzzle: Codable {
    public let moduli: [Int]
    public let start: [Int]
    public let target: [Int]
    public let moves: [GearMove]
}
public struct GearMove: Codable { public let name: GameText; public let deltas: [Int] }
public struct XORPuzzle: Codable {
    public let ciphertexts: [[Int]]
    public let clues: [[Int?]]
    public let startKey: [Int]
}
public struct RoutePuzzle: Codable {
    public let nodes: [RouteNode]
    public let start: String
    public let goal: String
    public let initialTokens: [String]
    public let goalTokens: [String]
    public let tokens: [RouteToken]
}
public struct RouteToken: Codable, Identifiable { public let id: String; public let label: GameText }
public struct RouteNode: Codable, Identifiable {
    public let id: String
    public let row: Int
    public let column: Int
    public let title: GameText
    public let detail: GameText
    public let exits: [String]
    public let requires: [String]
    public let grants: [String]
    public let removes: [String]
    public let blockedReason: GameText?
}
public struct CurvePoint: Codable, Equatable, Hashable {
    public let x: Int?
    public let y: Int?
    public static let infinity = CurvePoint(x: nil, y: nil)
    public init(x: Int?, y: Int?) { self.x = x; self.y = y }
    public var latex: String { if let x, let y { return "(\(x),\(y))" }; return "\\Omega" }
}
public struct CurvePuzzle: Codable {
    public let p: Int
    public let a: Int
    public let b: Int
    public let start: CurvePoint
    public let target: CurvePoint
    public let moves: [CurveMove]
    public func contains(_ point: CurvePoint) -> Bool {
        guard let x = point.x, let y = point.y else { return point == .infinity }
        return (0..<p).contains(x) && (0..<p).contains(y) && mod(y*y-x*x*x-a*x-b, p) == 0
    }
    public var points: [CurvePoint] {
        (0..<p).flatMap { x in (0..<p).map { CurvePoint(x: x, y: $0) }.filter(contains) }
    }
    public func adding(_ lhs: CurvePoint, _ rhs: CurvePoint) -> CurvePoint {
        guard let x = lhs.x, let y = lhs.y else { return rhs }
        guard let u = rhs.x, let v = rhs.y else { return lhs }
        if x == u && mod(y+v,p) == 0 { return .infinity }
        let numerator = lhs == rhs ? 3*x*x+a : v-y
        let denominator = lhs == rhs ? 2*y : u-x
        guard let inverse = (1..<p).first(where: { mod($0*denominator,p) == 1 }) else { return .infinity }
        let slope = mod(numerator*inverse,p)
        let rx = mod(slope*slope-x-u,p)
        return CurvePoint(x: rx, y: mod(slope*(x-rx)-y,p))
    }
}
public struct CurveMove: Codable { public let name: GameText; public let operation: String; public let point: CurvePoint? }
public struct SealPuzzle: Codable { public let n: Int; public let e: Int; public let messages: [SealMessage]; public let seals: [SealCard] }
public struct SealMessage: Codable, Identifiable { public let id: String; public let label: GameText; public let digest: Int }
public struct SealCard: Codable, Identifiable { public let id: String; public let value: Int }
public struct FactorPuzzle: Codable { public let number: Int; public let tools: [FactorTool] }
public struct FactorTool: Codable { public let title: GameText; public let operand: Int; public let derivation: GameText }
public struct ParityPuzzle: Codable { public let start: [Int]; public let columns: [[Int]]; public let locked: [Int] }
public struct AllocationPuzzle: Codable { public let cards: [CodeCard]; public let stations: [CodeStation]; public let budget: Int }
public struct CodeCard: Codable, Identifiable { public let id: String; public let name: GameText; public let n: Int; public let k: Int; public let d: Int; public let q: Int }
public struct CodeStation: Codable, Identifiable { public let id: String; public let name: GameText; public let q: Int; public let payload: Int; public let errors: Int; public let maxLength: Int }

public struct LogicGames: Codable {
    public let schemaVersion: Int
    public let games: [LogicGame]
    public func game(_ id: String) -> LogicGame? { games.first { $0.id == id } }
    public static func decode(_ data: Data, library: Library) throws -> LogicGames {
        let catalog = try JSONDecoder().decode(Self.self, from: data)
        let errors = catalog.validationErrors(library: library)
        guard errors.isEmpty else { throw LibraryError.invalid(errors.joined(separator: "\n")) }
        return catalog
    }
    public func validationErrors(library: Library) -> [String] {
        var errors: [String] = []
        if schemaVersion != 1 { errors.append("Unsupported game catalog version.") }
        if Set(games.map(\.id)) != Set(library.categories.map(\.id)) || Set(games.map(\.id)).count != games.count { errors.append("Each topic category needs exactly one game.") }
        var ids = Set<String>()
        func full(_ text: GameText) -> Bool { !text.it.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !text.en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        for game in games {
            if !full(game.title) || !full(game.introduction) || game.levels.isEmpty { errors.append("Incomplete game: \(game.id)") }
            for level in game.levels {
                if !ids.insert(level.id).inserted || !full(level.title) || !full(level.mission) || !full(level.explanation) || level.hints.isEmpty || !level.hints.allSatisfy(full) || level.moveLimit < 1 { errors.append("Incomplete level: \(level.id)") }
                if level.conceptIDs.isEmpty || level.conceptIDs.contains(where: { library.concept($0) == nil }) || !level.conceptIDs.contains(where: { library.concept($0)?.category == game.id }) { errors.append("Invalid study links: \(level.id)") }
                let configs = [level.gears != nil, level.xor != nil, level.route != nil, level.curve != nil, level.seals != nil, level.factor != nil, level.parity != nil, level.allocation != nil]
                if configs.filter({$0}).count != 1 { errors.append("Ambiguous board: \(level.id)") }
                switch level.kind {
                case .gears:
                    guard let p = level.gears, !p.moduli.isEmpty, p.start.count == p.moduli.count, p.target.count == p.moduli.count, p.moduli.allSatisfy({$0 > 1 && $0 <= 100}), !p.moves.isEmpty, p.moves.allSatisfy({$0.deltas.count == p.moduli.count && full($0.name)}), zip(p.start,p.moduli).allSatisfy({$0.0 >= 0 && $0.0 < $0.1}), zip(p.target,p.moduli).allSatisfy({$0.0 >= 0 && $0.0 < $0.1}) else { errors.append("Invalid gears: \(level.id)"); continue }
                case .xor:
                    guard let p = level.xor, !p.startKey.isEmpty, p.ciphertexts.count == p.clues.count, p.ciphertexts.count >= 2, (p.ciphertexts + [p.startKey]).allSatisfy({$0.count == p.startKey.count && $0.allSatisfy({$0 == 0 || $0 == 1})}), p.clues.allSatisfy({$0.count == p.startKey.count && $0.allSatisfy({$0 == nil || $0 == 0 || $0 == 1})}) else { errors.append("Invalid XOR board: \(level.id)"); continue }
                case .route:
                    guard let p = level.route else { errors.append("Missing route: \(level.id)"); continue }
                    let nodeIDs = Set(p.nodes.map(\.id)); let tokens = Set(p.tokens.map(\.id))
                    if nodeIDs.count != p.nodes.count || !nodeIDs.contains(p.start) || !nodeIDs.contains(p.goal) || p.nodes.contains(where: { !full($0.title) || !full($0.detail) || !$0.exits.allSatisfy(nodeIDs.contains) || !($0.requires+$0.grants+$0.removes).allSatisfy(tokens.contains) || $0.row < 0 || $0.column < 0 || $0.column > 2 }) || !(p.initialTokens+p.goalTokens).allSatisfy(tokens.contains) || Set(p.nodes.map({"\($0.row),\($0.column)"})).count != p.nodes.count { errors.append("Invalid route: \(level.id)") }
                case .curve:
                    guard let p = level.curve, [5,7,11,13,17].contains(p.p), mod(4*p.a*p.a*p.a+27*p.b*p.b,p.p) != 0, p.contains(p.start), p.contains(p.target), !p.moves.isEmpty, p.moves.allSatisfy({ full($0.name) && (["double","negate"].contains($0.operation) || ($0.operation == "add" && $0.point.map(p.contains) == true)) }) else { errors.append("Invalid elliptic board: \(level.id)"); continue }
                case .seals:
                    guard let p = level.seals, p.n > 2, p.n <= 10000, p.e > 0, p.e < 10000, !p.messages.isEmpty, p.messages.allSatisfy({full($0.label) && (0..<p.n).contains($0.digest)}), p.seals.allSatisfy({(0..<p.n).contains($0.value)}), Set(p.messages.map(\.id)).count == p.messages.count, Set(p.seals.map(\.id)).count == p.seals.count else { errors.append("Invalid seals: \(level.id)"); continue }
                case .factor:
                    guard let p = level.factor, p.number > 3, p.number <= 100000, !isPrime(p.number), !p.tools.isEmpty, p.tools.allSatisfy({$0.operand > 0 && full($0.title) && full($0.derivation)}) else { errors.append("Invalid factor machine: \(level.id)"); continue }
                case .parity:
                    guard let p = level.parity, !p.start.isEmpty, p.columns.count == p.start.count, p.start.allSatisfy({$0 == 0 || $0 == 1}), let width = p.columns.first?.count, width > 0, p.columns.allSatisfy({$0.count == width && $0.allSatisfy({$0 == 0 || $0 == 1})}), p.locked.allSatisfy({p.start.indices.contains($0)}) else { errors.append("Invalid parity board: \(level.id)"); continue }
                case .allocation:
                    guard let p = level.allocation, p.budget >= 0, !p.stations.isEmpty, Set(p.stations.map(\.id)).count == p.stations.count, Set(p.cards.map(\.id)).count == p.cards.count, p.cards.allSatisfy({full($0.name) && $0.q >= 2 && $0.k > 0 && $0.n >= $0.k && $0.d > 0 && $0.d <= $0.n-$0.k+1}), p.stations.allSatisfy({full($0.name) && $0.payload > 0 && $0.errors >= 0 && $0.maxLength > 0}) else { errors.append("Invalid code allocation: \(level.id)"); continue }
                }
                if LogicRun(level: level).isSolved(level: level) { errors.append("Already solved board: \(level.id)") }
            }
        }
        return errors
    }
}

public struct LogicState: Equatable {
    public var values: [Int] = []
    public var nodeID = ""
    public var tokens: Set<String> = []
    public var point: CurvePoint = .infinity
    public var factors: [Int] = []
    public var usedTools: Set<Int> = []
    public var assignments: [String:String] = [:]
}
public enum LogicMove { case gear(Int), flip(Int), travel(String), curve(Int), factor(Int, Int), assign(String, String) }
public struct LogicRun {
    public let levelID: String
    public private(set) var state: LogicState
    public private(set) var history: [LogicState] = []
    public private(set) var hintsUsed = 0
    public var moveCount: Int { history.count }
    public init(level: LogicLevel) {
        levelID = level.id
        var start = LogicState()
        switch level.kind {
        case .gears: start.values = level.gears!.start
        case .xor: start.values = level.xor!.startKey
        case .route: start.nodeID = level.route!.start; start.tokens = Set(level.route!.initialTokens)
        case .curve: start.point = level.curve!.start
        case .factor: start.factors = [level.factor!.number]
        case .parity: start.values = level.parity!.start
        case .seals, .allocation: break
        }
        state = start
    }
    public mutating func revealHint(level: LogicLevel) { hintsUsed = min(hintsUsed+1,level.hints.count) }
    public mutating func undo() { if let previous = history.popLast() { state = previous } }
    public mutating func restart(level: LogicLevel) { let hints = hintsUsed; self = LogicRun(level: level); hintsUsed = hints }
    public func syndrome(_ puzzle: ParityPuzzle) -> [Int] {
        (0..<puzzle.columns[0].count).map { row in zip(state.values,puzzle.columns).reduce(0) { $0 ^ ($1.0 * $1.1[row]) } }
    }
    public func decoded(_ puzzle: XORPuzzle) -> [[Int]] { puzzle.ciphertexts.map { zip($0,state.values).map { $0.0 ^ $0.1 } } }
    public func sealMatches(_ message: SealMessage, puzzle: SealPuzzle) -> Bool {
        guard let id = state.assignments[message.id], let seal = puzzle.seals.first(where: {$0.id == id}) else { return false }
        return modularPower(seal.value,puzzle.e,puzzle.n) == message.digest
    }
    public func allocationCost(_ puzzle: AllocationPuzzle) -> Int {
        state.assignments.values.compactMap { id in puzzle.cards.first(where: {$0.id == id}) }.reduce(0) {$0+$1.n-$1.k}
    }
    public func stationFits(_ station: CodeStation, puzzle: AllocationPuzzle) -> Bool {
        guard let id = state.assignments[station.id], let code = puzzle.cards.first(where: {$0.id == id}) else { return false }
        return code.q == station.q && code.k >= station.payload && code.d > 2*station.errors && code.n <= station.maxLength
    }
    public func isSolved(level: LogicLevel) -> Bool {
        switch level.kind {
        case .gears: return state.values == level.gears!.target
        case .xor:
            let p = level.xor!; let rows = decoded(p)
            return p.clues.enumerated().allSatisfy { row, clues in clues.enumerated().allSatisfy { i, bit in bit == nil || bit == rows[row][i] } }
        case .route: return state.nodeID == level.route!.goal && Set(level.route!.goalTokens).isSubset(of: state.tokens)
        case .curve: return state.point == level.curve!.target
        case .seals: return level.seals!.messages.allSatisfy { sealMatches($0,puzzle:level.seals!) }
        case .factor: return state.factors.allSatisfy(isPrime)
        case .parity: return syndrome(level.parity!).allSatisfy {$0 == 0}
        case .allocation: return level.allocation!.stations.allSatisfy { stationFits($0,puzzle:level.allocation!) } && allocationCost(level.allocation!) <= level.allocation!.budget
        }
    }
    @discardableResult
    public mutating func apply(_ move: LogicMove, level: LogicLevel) -> Bool {
        guard level.id == levelID, moveCount < level.moveLimit, !isSolved(level: level) else { return false }
        var next = state
        switch (level.kind,move) {
        case (.gears,.gear(let index)):
            guard let p = level.gears, p.moves.indices.contains(index) else { return false }
            next.values = zip(zip(state.values,p.moves[index].deltas),p.moduli).map { mod($0.0.0+$0.0.1,$0.1) }
        case (.xor,.flip(let index)), (.parity,.flip(let index)):
            guard state.values.indices.contains(index), level.parity?.locked.contains(index) != true else { return false }
            next.values[index] ^= 1
        case (.route,.travel(let id)):
            guard let p = level.route, let current = p.nodes.first(where: {$0.id == state.nodeID}), current.exits.contains(id),
                  let destination = p.nodes.first(where: {$0.id == id}), destination.blockedReason == nil, Set(destination.requires).isSubset(of:state.tokens) else { return false }
            next.nodeID = id
            next.tokens.subtract(destination.removes); next.tokens.formUnion(destination.grants)
        case (.curve,.curve(let index)):
            guard let p = level.curve, p.moves.indices.contains(index) else { return false }
            let action = p.moves[index]
            if action.operation == "double" { next.point = p.adding(state.point,state.point) }
            else if action.operation == "negate" { next.point = state.point.x.map { CurvePoint(x:$0,y:mod(-state.point.y!,p.p)) } ?? .infinity }
            else { next.point = p.adding(state.point,action.point!) }
        case (.factor,.factor(let index,let tool)):
            guard let p = level.factor, state.factors.indices.contains(index), p.tools.indices.contains(tool), !state.usedTools.contains(tool), !isPrime(state.factors[index]) else { return false }
            let n = state.factors[index], divisor = gcd(n,p.tools[tool].operand)
            guard divisor > 1 && divisor < n else { return false }
            next.factors.remove(at:index); next.factors += [divisor,n/divisor]; next.factors.sort(); next.usedTools.insert(tool)
        case (.seals,.assign(let slot,let item)):
            guard let p = level.seals, p.messages.contains(where: {$0.id == slot}), p.seals.contains(where: {$0.id == item}) else { return false }
            Self.assign(slot:slot,item:item,in:&next)
        case (.allocation,.assign(let slot,let item)):
            guard let p = level.allocation, p.stations.contains(where: {$0.id == slot}), p.cards.contains(where: {$0.id == item}) else { return false }
            Self.assign(slot:slot,item:item,in:&next)
        default: return false
        }
        guard next != state else { return false }
        history.append(state); state = next
        return true
    }
    private static func assign(slot:String,item:String,in state:inout LogicState) {
        let source = state.assignments.first(where: {$0.value == item})?.key
        let old = state.assignments[slot]
        if let source { state.assignments[source] = old }
        state.assignments[slot] = item
    }
}

public struct LogicSession {
    public let gameID: String
    public private(set) var levelIndex = 0
    public var run: LogicRun
    public private(set) var totalMoves = 0
    public private(set) var totalHints = 0
    public private(set) var isComplete = false
    public init(game: LogicGame) { gameID = game.id; run = LogicRun(level:game.levels[0]) }
    @discardableResult
    public mutating func advance(game:LogicGame) -> Bool {
        guard game.id == gameID, !isComplete, run.isSolved(level:game.levels[levelIndex]) else { return false }
        totalMoves += run.moveCount; totalHints += run.hintsUsed
        if levelIndex+1 == game.levels.count { isComplete = true }
        else { levelIndex += 1; run = LogicRun(level:game.levels[levelIndex]) }
        return true
    }
}
public struct LogicRecord: Codable {
    public let revision: Int?
    public func matches(_ game: LogicGame) -> Bool { (revision ?? 1) == (game.revision ?? 1) }
    public let completedRuns: Int
    public let bestMoves: Int
    public let lastMoves: Int
    public let lastHints: Int
    public let levels: Int
    public let completedAt: Date
    public init(session:LogicSession,levels:Int,previous:LogicRecord?,revision:Int = 1) {
        self.revision = revision
        completedRuns = (previous?.completedRuns ?? 0)+1
        bestMoves = previous?.levels == levels && (previous?.revision ?? 1) == revision ? min(previous!.bestMoves,session.totalMoves) : session.totalMoves
        lastMoves = session.totalMoves; lastHints = session.totalHints; self.levels = levels; completedAt = Date()
    }
}
public func mod(_ a:Int,_ n:Int) -> Int { (a % n + n) % n }
public func gcd(_ a:Int,_ b:Int) -> Int { var x=a; var y=b; while y != 0 { (x,y)=(y,x%y) }; return abs(x) }
public func isPrime(_ n:Int) -> Bool { guard n >= 2 else { return false }; if n < 4 { return true }; var d=2; while d*d <= n { if n%d == 0 { return false }; d += 1 }; return true }
public func modularPower(_ a:Int,_ exponent:Int,_ n:Int) -> Int { var base=mod(a,n), e=exponent, result=1; while e > 0 { if e%2 == 1 { result=mod(result*base,n) }; base=mod(base*base,n); e /= 2 }; return result }
