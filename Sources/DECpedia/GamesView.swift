import SwiftUI
#if canImport(DECpediaCore)
import DECpediaCore
#endif

extension View {
    @ViewBuilder
    func manualQAKey(_ key: String) -> some View {
        #if DECPEDIA_MANUAL_QA
        keyboardShortcut(KeyEquivalent(Character(key)), modifiers: [.command, .control])
        #else
        self
        #endif
    }
}

// Keep mathematical evidence readable when a completed board disables its controls.
private struct GameBoardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct GameListView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        VStack(alignment:.leading,spacing:0) {
            VStack(alignment:.leading,spacing:7) {
                Text(store.t("Giochi di logica","Logic games")).font(.system(size:23,weight:.semibold,design:.serif))
                Text(store.t("Un gioco di logica per mettere alla prova ogni sezione.","A small laboratory for every section.")).font(.caption).foregroundStyle(.secondary)
            }.padding(20)
            Divider()
            List(selection:$store.selectedGameID) {
                ForEach(store.visibleGames) { game in
                    VStack(alignment:.leading,spacing:7) {
                        Label(game.title.value(store.language),systemImage:store.category(game.id)?.symbol ?? "gamecontroller")
                            .font(.system(size:14,weight:.semibold))
                        Text(store.category(game.id)?.title ?? "").font(.caption)
                            .selectionAwareAccent(isSelected:store.selectedGameID == game.id)
                        if let record = store.personal.gameRecords?[game.id], record.matches(game) {
                            Label(store.t("Completato · \(record.bestMoves) mosse","Completed · \(record.bestMoves) moves"),systemImage:"checkmark.seal")
                                .font(.caption2).foregroundStyle(.secondary)
                        } else {
                            Text(store.t("\(game.levels.count) livelli da esplorare","\(game.levels.count) levels to explore")).font(.caption2).foregroundStyle(.secondary)
                        }
                    }.padding(.vertical,10).tag(game.id)
                }
                if store.visibleGames.isEmpty { Text(store.t("Nessun gioco trovato.","No games found.")).foregroundStyle(.secondary) }
            }.listStyle(.inset)
        }
    }
}

struct GameDetailView: View {
    @EnvironmentObject private var store: AppStore
    let game: LogicGame
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:24) {
                Label(store.category(game.id)?.title.uppercased() ?? "",systemImage:"gamecontroller")
                    .font(.system(size:10,weight:.semibold)).foregroundStyle(Palette.accent)
                Text(game.title.value(store.language)).font(.system(size:36,weight:.medium,design:.serif))
                Text(game.introduction.value(store.language)).font(.system(size:17,design:.serif)).lineSpacing(5)
                if let session = store.gameSession, session.gameID == game.id {
                    if session.isComplete { completed(session) }
                    else { PuzzleView(game:game,level:game.levels[session.levelIndex]).id(session.run.levelID) }
                } else {
                    VStack(alignment:.leading,spacing:17) {
                        Label(store.t("Muovi, osserva, riprova","Move, observe, try again"),systemImage:"hand.tap").font(.headline)
                        Text(store.t("Ogni mossa cambia il tabellone. Puoi annullarla, ricominciare il livello e chiedere indizi graduali. Il traguardo si apre quando tutti i vincoli sono rispettati.","Each move changes the board. You can undo it, restart the level, and ask for gradual hints. The goal opens when every constraint is satisfied.")).lineSpacing(4)
                        ForEach(Array(game.levels.enumerated()),id:\.element.id) { index, level in
                            Label(level.title.value(store.language),systemImage:"circle.dotted").font(.callout)
                        }
                        Button(store.t("Entra nel gioco","Enter the game")) { store.startGame(game) }
                            .manualQAKey("\r")
                            .buttonStyle(.borderedProminent).controlSize(.large)
                        if let record = store.personal.gameRecords?[game.id], record.matches(game) {
                            Text(store.t("Il tuo percorso migliore: \(record.bestMoves) mosse. Partite completate: \(record.completedRuns).","Your best route: \(record.bestMoves) moves. Completed runs: \(record.completedRuns)."))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }.padding(22).frame(maxWidth:.infinity,alignment:.leading).background(Color.secondary.opacity(0.06),in:RoundedRectangle(cornerRadius:16))
                }
                Divider()
                Text(store.t("Giochi originali e integrazioni didattiche. I tabelloni non sono consegne dei PDF. Risultati salvati solo su questo Mac; nessun timer e nessuna classifica online.","Original games and teaching additions. The boards are not problem statements from the PDFs. Results are stored only on this Mac; there is no timer or online leaderboard."))
                    .font(.caption).foregroundStyle(.secondary).lineSpacing(3)
            }.padding(30).frame(maxWidth:920,alignment:.leading).frame(maxWidth:.infinity)
        }.background(Palette.paper)
        .safeAreaInset(edge:.bottom,spacing:0) {
            if let session=store.gameSession, session.gameID == game.id, !session.isComplete {
                GameControls(game:game,level:game.levels[session.levelIndex])
            }
        }
    }
    private func completed(_ session:LogicSession) -> some View {
        VStack(alignment:.leading,spacing:18) {
            Label(store.t("Percorso completato","Route completed"),systemImage:"flag.checkered").font(.title2)
            Text(store.t("Hai attraversato tutti i livelli: \(session.totalMoves) mosse e \(session.totalHints) indizi.","You crossed every level: \(session.totalMoves) moves and \(session.totalHints) hints.")).font(.body)
            Text(store.t("Puoi provare un percorso più breve o esplorare il gioco di un’altra sezione.","Try a shorter route, or explore another section’s game.")).foregroundStyle(.secondary)
            Button(store.t("Nuova partita","New game")) { store.startGame(game) }.manualQAKey("\r").buttonStyle(.borderedProminent)
            ForEach(game.levels) { level in
                DisclosureGroup(level.title.value(store.language)) {
                    RichMathView(text:level.explanation.value(store.language),size:16)
                    GameStudyLinks(ids:level.conceptIDs)
                }
            }
        }.padding(22).background(Palette.accent.opacity(0.06),in:RoundedRectangle(cornerRadius:16))
    }
}

struct GameStudyLinks: View {
    @EnvironmentObject private var store: AppStore
    let ids:[String]
    var body: some View {
        VStack(alignment:.leading,spacing:9) {
            Text(store.t("Rileggi i concetti · la partita resta aperta","Review the concepts · your game stays open")).font(.caption).foregroundStyle(.secondary)
            ForEach(ids,id:\.self) { id in
                if let concept=store.concept(id) {
                    Button { store.select(id,reveal:true) } label: { Label(concept.title,systemImage:"book") }.buttonStyle(.link)
                }
            }
        }
    }
}

private struct GameControls:View {
    @EnvironmentObject private var store:AppStore
    let game:LogicGame
    let level:LogicLevel
    private var run:LogicRun {
        if let run=store.gameSession?.run, run.levelID == level.id { return run }
        return LogicRun(level:level)
    }
    var body:some View {
        VStack(spacing:10) {
            Divider()
            if run.hintsUsed > 0, !run.isSolved(level:level) {
                RichMathView(text:level.hints[run.hintsUsed-1].value(store.language),size:14,compact:true).padding(.horizontal,20)
            }
            HStack {
                Button { store.undoGame() } label:{Label(store.t("Annulla","Undo"),systemImage:"arrow.uturn.backward")}.manualQAKey("z").disabled(run.history.isEmpty)
                Button { store.restartLevel(level) } label:{Label(store.t("Ricomincia","Restart"),systemImage:"arrow.clockwise")}.manualQAKey("r")
                Spacer()
                if run.isSolved(level:level) {
                    Button(store.gameSession?.levelIndex == game.levels.count-1 ? store.t("Concludi il percorso","Finish the route"):store.t("Prossimo livello","Next level")) {store.advanceGame(game)}.manualQAKey("\r").buttonStyle(.borderedProminent)
                } else {
                    Button {store.gameHint(level)} label:{Label(store.t("Un indizio","A hint"),systemImage:"lightbulb")}.manualQAKey("h").disabled(run.hintsUsed >= level.hints.count)
                }
            }.buttonStyle(.bordered).padding(.horizontal,20).padding(.bottom,12)
        }.frame(maxWidth:920).frame(maxWidth:.infinity).background(.regularMaterial)
    }
}

struct PuzzleView: View {
    @EnvironmentObject private var store: AppStore
    let game:LogicGame
    let level:LogicLevel
    @State private var selectedCard:String?
    @State private var selectedFactor=0
    @State private var message:String?
    private var run:LogicRun {
        if let run=store.gameSession?.run, run.levelID == level.id { return run }
        return LogicRun(level:level)
    }
    private var solved:Bool { run.isSolved(level:level) }
    var body: some View {
        VStack(alignment:.leading,spacing:20) {
            HStack {
                Text(store.t("Livello \((store.gameSession?.levelIndex ?? 0)+1) di \(game.levels.count)","Level \((store.gameSession?.levelIndex ?? 0)+1) of \(game.levels.count)")).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(store.t("Mosse: \(run.moveCount)/\(level.moveLimit)","Moves: \(run.moveCount)/\(level.moveLimit)")).font(.system(.caption,design:.monospaced))
            }
            ProgressView(value:Double(store.gameSession?.levelIndex ?? 0),total:Double(game.levels.count)).accessibilityLabel(store.t("Avanzamento del gioco","Game progress"))
            Text(level.title.value(store.language)).font(.system(size:25,weight:.medium,design:.serif))
            RichMathView(text:level.mission.value(store.language),size:16)
            board
            if let message { HStack(alignment:.top) { Image(systemName:"info.circle"); RichMathView(text:message,size:15) }.padding(12).background(Color.secondary.opacity(0.08),in:RoundedRectangle(cornerRadius:10)) }
            if run.moveCount >= level.moveLimit && !solved {
                Label(store.t("Le mosse sono finite: annulla una mossa o riparti dal livello.","No moves left: undo a move or restart the level."),systemImage:"arrow.uturn.backward").font(.callout)
            }
            if solved {
                VStack(alignment:.leading,spacing:15) {
                    Label(store.t("Passaggio sbloccato","Passage unlocked"),systemImage:"checkmark.seal.fill").font(.headline).foregroundStyle(Palette.accent)
                    RichMathView(text:level.explanation.value(store.language),size:16)
                }.padding(20).background(Palette.accent.opacity(0.06),in:RoundedRectangle(cornerRadius:14))
            }
            DisclosureGroup(store.t("Concetti utili per questo tabellone","Useful concepts for this board")) { GameStudyLinks(ids:level.conceptIDs).padding(.top,10) }
        }.onChange(of:run.moveCount) { _ in message=nil; selectedFactor=0 }
            .onChange(of:store.language) { _ in message=nil }
    }
    @ViewBuilder private var board:some View {
        switch level.kind {
        case .gears: gearBoard(level.gears!)
        case .xor: xorBoard(level.xor!)
        case .route: routeBoard(level.route!)
        case .curve: curveBoard(level.curve!)
        case .seals: sealBoard(level.seals!)
        case .factor: factorBoard(level.factor!)
        case .parity: parityBoard(level.parity!)
        case .allocation: allocationBoard(level.allocation!)
        }
    }
    private func play(_ move:LogicMove) {
        message=nil
        if !store.play(move,level:level), !solved, run.moveCount < level.moveLimit {
            message=store.t("Questa mossa non cambia il tabellone. Prova un altro collegamento.","This move does not change the board. Try another connection.")
        }
    }
    private func math(_ latex:String,size:Double=18) -> some View {
        RichMathView(text:"\\["+latex+"\\]",size:size,inFormulaBox:true,compact:true).allowsHitTesting(false)
    }
    private func tile<Content:View>(selected:Bool=false,@ViewBuilder content:()->Content) -> some View {
        content().padding(13).frame(maxWidth:.infinity).background(selected ? Palette.accent.opacity(0.09) : Color.secondary.opacity(0.05),in:RoundedRectangle(cornerRadius:12))
            .overlay(RoundedRectangle(cornerRadius:12).stroke(selected ? Palette.accent : Color.secondary.opacity(0.18),lineWidth:selected ? 2:1))
    }
    private func lamp(_ on:Bool,label:String) -> some View {
        Image(systemName:on ? "lightbulb.fill":"lightbulb")
            .foregroundStyle(on ? Palette.accent:Color.secondary).font(.system(size:22))
            .frame(maxWidth:.infinity,minHeight:32).accessibilityLabel(label+store.t(on ? ": accesa":": spenta",on ? ": on":": off"))
    }
    private func gearBoard(_ puzzle:GearPuzzle) -> some View {
        VStack(spacing:16) {
            HStack(alignment:.top,spacing:10) {
                ForEach(puzzle.moduli.indices,id:\.self) { i in
                    tile(selected:run.state.values[i] == puzzle.target[i]) {
                        VStack(spacing:7) {
                            Image(systemName:run.state.values[i] == puzzle.target[i] ? "lock.open.fill":"gearshape.2").font(.title2).foregroundStyle(Palette.accent)
                            math(String(run.state.values[i])+"\\quad\\longrightarrow\\quad"+String(puzzle.target[i]))
                            math("\\bmod\\,"+String(puzzle.moduli[i]),size:14)
                        }
                    }
                }
            }
            ForEach(puzzle.moves.indices,id:\.self) { i in
                Button { play(.gear(i)) } label: {
                    tile { HStack { Label(puzzle.moves[i].name.value(store.language),systemImage:"gearshape").font(.headline); Spacer(); math("+("+puzzle.moves[i].deltas.map(String.init).joined(separator:",")+")",size:17).frame(maxWidth:260) } }
                }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(i+1)).disabled(solved).accessibilityLabel(puzzle.moves[i].name.value(store.language))
            }
        }
    }
    private func xorBoard(_ puzzle:XORPuzzle) -> some View {
        VStack(alignment:.leading,spacing:16) {
            math("c_A=m_A\\oplus k,\\qquad c_B=m_B\\oplus k")
            Text(store.t("Chiave comune · aziona gli interruttori","Shared key · flip the switches")).font(.headline)
            HStack(spacing:8) {
                ForEach(run.state.values.indices,id:\.self) { i in
                    Button { play(.flip(i)) } label: {
                        tile(selected:run.state.values[i] == 1) {
                            VStack(spacing:6) {
                                Image(systemName:run.state.values[i] == 1 ? "lightbulb.fill":"lightbulb").font(.title2)
                                Text(run.state.values[i] == 1 ? store.t("Acceso","On"):store.t("Spento","Off")).font(.caption2)
                            }
                        }
                    }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(i+1)).disabled(solved).accessibilityLabel(store.t("Interruttore \(i+1)","Switch \(i+1)"))
                        .accessibilityValue(run.state.values[i] == 1 ? store.t("Acceso","On"):store.t("Spento","Off"))
                }
            }
            ForEach(puzzle.ciphertexts.indices,id:\.self) { row in
                VStack(alignment:.leading,spacing:10) {
                    Text(store.t("Messaggio ","Message ")+String(UnicodeScalar(65+row)!)).font(.headline)
                    Text(store.t("Cifrato ricevuto","Received ciphertext")).font(.caption).foregroundStyle(.secondary)
                    HStack { ForEach(puzzle.ciphertexts[row].indices,id:\.self) { i in lamp(puzzle.ciphertexts[row][i] == 1,label:store.t("Cifrato \(i+1)","Cipher bit \(i+1)")) } }
                    Text(store.t("Ricostruzione attuale","Current reconstruction")).font(.caption).foregroundStyle(.secondary)
                    HStack { ForEach(run.state.values.indices,id:\.self) { i in lamp(run.decoded(puzzle)[row][i] == 1,label:store.t("Testo \(i+1)","Plaintext bit \(i+1)")) } }
                    Text(store.t("Indizi · il punto interrogativo lascia libero il valore","Clues · a question mark leaves the value free")).font(.caption).foregroundStyle(.secondary)
                    HStack {
                        ForEach(run.state.values.indices,id:\.self) { i in
                            if let bit=puzzle.clues[row][i] {
                                VStack { lamp(bit == 1,label:store.t("Indizio \(i+1)","Clue \(i+1)")); Image(systemName:run.decoded(puzzle)[row][i] == bit ? "checkmark":"xmark").font(.caption) }.frame(maxWidth:.infinity)
                            } else { Image(systemName:"questionmark").frame(maxWidth:.infinity,minHeight:50).foregroundStyle(.secondary) }
                        }
                    }
                }.padding(15).background(Color.secondary.opacity(0.05),in:RoundedRectangle(cornerRadius:12))
            }
        }
    }
    private func routeBoard(_ puzzle:RoutePuzzle) -> some View {
        let current=puzzle.nodes.first {$0.id == run.state.nodeID}!
        return VStack(alignment:.leading,spacing:16) {
            Text(store.t("Inventario","Inventory")).font(.headline)
            FlowTokenList(tokens:puzzle.tokens.filter {run.state.tokens.contains($0.id)},language:store.language)
            GeometryReader { geometry in
                let width=geometry.size.width/3, height:CGFloat=112
                ZStack(alignment:.topLeading) {
                    Path { path in
                        for node in puzzle.nodes {
                            for exit in node.exits {
                                if let next=puzzle.nodes.first(where:{$0.id == exit}) {
                                    path.move(to:CGPoint(x:(CGFloat(node.column)+0.5)*width,y:(CGFloat(node.row)+0.5)*height))
                                    path.addLine(to:CGPoint(x:(CGFloat(next.column)+0.5)*width,y:(CGFloat(next.row)+0.5)*height))
                                    let dx=CGFloat(next.column-node.column)*width, dy=CGFloat(next.row-node.row)*height
                                    let distance=(dx*dx+dy*dy).squareRoot()
                                    if distance > 0 {
                                        let ux=dx/distance, uy=dy/distance
                                        let inset=min((width/2-8)/max(abs(ux),0.001),48/max(abs(uy),0.001))+3
                                        let tip=CGPoint(x:(CGFloat(next.column)+0.5)*width-ux*inset,y:(CGFloat(next.row)+0.5)*height-uy*inset)
                                        path.move(to:CGPoint(x:tip.x-ux*7-uy*4,y:tip.y-uy*7+ux*4))
                                        path.addLine(to:tip)
                                        path.addLine(to:CGPoint(x:tip.x-ux*7+uy*4,y:tip.y-uy*7-ux*4))
                                    }
                                }
                            }
                        }
                    }.stroke(Color.secondary.opacity(0.25),style:StrokeStyle(lineWidth:2,dash:[5,4]))
                    ForEach(puzzle.nodes) { node in
                        Button {
                            guard current.exits.contains(node.id) else { message=store.t("Da qui non parte una strada diretta verso questa casella.","There is no direct road from here to that tile."); return }
                            if let reason=node.blockedReason { message=reason.value(store.language); return }
                            let missing=node.requires.filter {!run.state.tokens.contains($0)}
                            guard missing.isEmpty else {
                                message=store.t("La porta richiede: ","The door requires: ")+missing.compactMap {id in puzzle.tokens.first {$0.id == id}?.label.value(store.language)}.joined(separator:" · "); return
                            }
                            play(.travel(node.id))
                        } label: {
                            VStack(spacing:6) {
                                Image(systemName:node.id == current.id ? "figure.walk":node.id == puzzle.goal ? "flag.checkered":node.blockedReason != nil ? "exclamationmark.triangle":Set(node.requires).isSubset(of:run.state.tokens) ? "circle.dotted":"lock")
                                    .font(.system(size:19)).foregroundStyle(node.id == current.id ? Palette.accent:Color.primary)
                                Text(node.title.value(store.language)).font(.system(size:12,weight:.medium)).lineLimit(3).multilineTextAlignment(.center)
                            }.padding(9).frame(width:width-16,height:96).background(node.id == current.id ? Palette.accent.opacity(0.12):Color(nsColor:.controlBackgroundColor),in:RoundedRectangle(cornerRadius:12))
                                .overlay(RoundedRectangle(cornerRadius:12).stroke(node.id == current.id ? Palette.accent:Color.secondary.opacity(0.3),lineWidth:node.id == current.id ? 2:1))
                        }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(node.row*3+node.column+1)).disabled(solved || node.id == current.id)
                            .position(x:(CGFloat(node.column)+0.5)*width,y:(CGFloat(node.row)+0.5)*height)
                    }
                }
            }.frame(height:CGFloat((puzzle.nodes.map(\.row).max() ?? 2)+1)*112)
            Text(current.title.value(store.language)).font(.headline)
            RichMathView(text:current.detail.value(store.language),size:16)
            Text(store.t("Scegli una casella collegata. Le strade possono essere a senso unico; Annulla riporta alla mossa precedente.","Choose a connected tile. Roads may be one-way; Undo returns to the previous move.")).font(.caption).foregroundStyle(.secondary)
        }
    }
    private func curveBoard(_ puzzle:CurvePuzzle) -> some View {
        VStack(spacing:16) {
            math("y^2=x^3+"+String(puzzle.a)+"x+"+String(puzzle.b)+",\\qquad \\mathbb F_{"+String(puzzle.p)+"}")
            math("R="+run.state.point.latex+",\\qquad R_{\\mathrm{"+store.t("obiettivo","goal")+"}}="+puzzle.target.latex)
            CurveGarden(puzzle:puzzle,current:run.state.point,language:store.language).frame(height:300)
                .accessibilityLabel(store.t("Giardino dei punti della curva","Garden of curve points"))
                .accessibilityValue(store.t("Punto corrente ","Current point ")+run.state.point.latex+store.t("; meta ","; target ")+puzzle.target.latex)
            ForEach(puzzle.moves.indices,id:\.self) { i in
                Button { play(.curve(i)) } label: {
                    tile { HStack {
                        Image(systemName:["arrow.turn.up.right","arrow.triangle.branch","arrow.left.and.right"][i%3])
                        RichMathView(text:puzzle.moves[i].name.value(store.language),size:16,compact:true).allowsHitTesting(false)
                        Spacer()
                        if let point=puzzle.moves[i].point { math("P="+point.latex,size:16).frame(maxWidth:180) }
                    } }
                }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(i+1)).disabled(solved).accessibilityLabel(puzzle.moves[i].name.value(store.language))
            }
            Label(store.t("La figura indica le posizioni nel campo; i salti seguono la legge di gruppo.","The figure shows field positions; jumps follow the group law."),systemImage:"point.3.connected.trianglepath.dotted").font(.caption).foregroundStyle(.secondary)
        }
    }
    private func sealBoard(_ puzzle:SealPuzzle) -> some View {
        VStack(alignment:.leading,spacing:15) {
            math("(n,e)=("+String(puzzle.n)+","+String(puzzle.e)+")")
            Text(store.t("Vassoio dei sigilli · scegli, poi tocca un pacco","Seal tray · select, then click a parcel")).font(.headline)
            LazyVGrid(columns:[GridItem(.adaptive(minimum:110))],spacing:10) {
                ForEach(puzzle.seals) { seal in
                    Button { selectedCard=seal.id; message=nil } label: {
                        tile(selected:selectedCard == seal.id) { VStack {
                            Image(systemName:"seal").font(.title2)
                            math("s="+String(seal.value),size:17)
                            Text(run.state.assignments.values.contains(seal.id) ? store.t("Su un pacco","On a parcel"):store.t("Nel vassoio","In the tray")).font(.caption2)
                        } }
                    }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String((puzzle.seals.firstIndex(where: {$0.id == seal.id}) ?? 0)+1)).disabled(solved).accessibilityLabel(store.t("Sigillo ","Seal ")+String(seal.value))
                }
            }
            ForEach(puzzle.messages) { parcel in
                Button {
                    guard let selectedCard else { message=store.t("Scegli prima un sigillo dal vassoio.","First select a seal from the tray."); return }
                    play(.assign(parcel.id,selectedCard))
                } label: {
                    tile {
                        VStack(alignment:.leading,spacing:8) {
                            HStack { Label(parcel.label.value(store.language),systemImage:"shippingbox").font(.headline); Spacer(); Image(systemName:run.sealMatches(parcel,puzzle:puzzle) ? "checkmark.seal.fill":"seal") }
                            math("H(m)="+String(parcel.digest),size:17)
                            if let id=run.state.assignments[parcel.id], let seal=puzzle.seals.first(where:{$0.id == id}) {
                                math(String(seal.value)+"^{"+String(puzzle.e)+"}\\bmod "+String(puzzle.n)+"="+String(modularPower(seal.value,puzzle.e,puzzle.n)),size:17)
                                Text(run.sealMatches(parcel,puzzle:puzzle) ? store.t("Verifica riuscita","Verification passed"):store.t("L’impronta non coincide","Digest mismatch")).font(.caption)
                            } else { Text(store.t("In attesa di un sigillo","Waiting for a seal")).font(.caption).foregroundStyle(.secondary) }
                        }
                    }
                }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(UnicodeScalar(97+(puzzle.messages.firstIndex(where: {$0.id == parcel.id}) ?? 0))!)).disabled(solved).accessibilityLabel(parcel.label.value(store.language))
            }
        }
    }
    private func factorBoard(_ puzzle:FactorPuzzle) -> some View {
        VStack(alignment:.leading,spacing:16) {
            math(String(puzzle.number)+"="+run.state.factors.map(String.init).joined(separator:"\\cdot "))
            Text(store.t("Scegli il blocco da smontare","Choose a block to split")).font(.headline)
            HStack(spacing:10) {
                ForEach(run.state.factors.indices,id:\.self) { i in
                    Button { selectedFactor=i; message=nil } label: {
                        tile(selected:selectedFactor == i) { VStack { math(String(run.state.factors[i])); Label(isPrime(run.state.factors[i]) ? store.t("Primo","Prime"):store.t("Composto","Composite"),systemImage:isPrime(run.state.factors[i]) ? "checkmark.seal":"cube.transparent").font(.caption) } }
                    }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(UnicodeScalar(97+i)!)).disabled(solved || isPrime(run.state.factors[i])).accessibilityLabel(store.t("Blocco ","Block ")+String(run.state.factors[i]))
                }
            }
            Text(store.t("Attrezzi disponibili","Available tools")).font(.headline)
            ForEach(puzzle.tools.indices,id:\.self) { i in
                Button {
                    guard run.state.factors.indices.contains(selectedFactor) else { return }
                    let n=run.state.factors[selectedFactor], d=gcd(n,puzzle.tools[i].operand)
                    if isPrime(n) { message=store.t("Questo blocco è già primo: scegli il ramo ancora composto.","This block is already prime: choose a composite branch."); return }
                    if d == 1 || d == n { message="\\(\\gcd("+String(n)+","+String(puzzle.tools[i].operand)+")="+String(d)+"\\). "+store.t("Questo MCD non separa il blocco; l’attrezzo resta disponibile.","This gcd does not split the block; the tool remains available."); return }
                    play(.factor(selectedFactor,i)); selectedFactor=0
                } label: {
                    tile { HStack(alignment:.center) {
                        Label(puzzle.tools[i].title.value(store.language),systemImage:run.state.usedTools.contains(i) ? "checkmark":"wrench.and.screwdriver").font(.headline)
                        Spacer()
                        RichMathView(text:puzzle.tools[i].derivation.value(store.language),size:16,compact:true).allowsHitTesting(false).frame(maxWidth:220)
                    } }
                }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(i+1)).disabled(solved || run.state.usedTools.contains(i)).accessibilityLabel(puzzle.tools[i].title.value(store.language))
            }
        }
    }
    private func parityBoard(_ puzzle:ParityPuzzle) -> some View {
        VStack(alignment:.leading,spacing:16) {
            Text(store.t("Lampade di controllo · devono essere tutte spente","Check lamps · all must be off")).font(.headline)
            HStack {
                ForEach(run.syndrome(puzzle).indices,id:\.self) { row in
                    VStack { lamp(run.syndrome(puzzle)[row] == 1,label:store.t("Controllo ","Check ")+String(UnicodeScalar(65+row)!)); Text(String(UnicodeScalar(65+row)!)).font(.caption) }
                }
            }.padding(15).background(Color.secondary.opacity(0.06),in:RoundedRectangle(cornerRadius:12))
            Text(store.t("Passerella · ogni colonna mostra i collegamenti della leva","Walkway · each column shows its switch connections")).font(.caption).foregroundStyle(.secondary)
            HStack(alignment:.top,spacing:6) {
                ForEach(run.state.values.indices,id:\.self) { i in
                    Button { play(.flip(i)) } label: {
                        tile(selected:run.state.values[i] == 1) {
                            VStack(spacing:12) {
                                Image(systemName:run.state.values[i] == 1 ? "lightbulb.fill":"lightbulb").font(.system(size:20))
                                Image(systemName:puzzle.locked.contains(i) ? "lock.fill":"hand.tap").font(.caption2).foregroundStyle(.secondary)
                                ForEach(puzzle.columns[i].indices,id:\.self) { row in
                                    VStack(spacing:2) { Image(systemName:puzzle.columns[i][row] == 1 ? "circle.fill":"circle").font(.system(size:8)); Text(String(UnicodeScalar(65+row)!)).font(.system(size:9)) }.opacity(puzzle.columns[i][row] == 1 ? 1:0.25)
                                }
                            }
                        }
                    }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(i+1)).disabled(solved || puzzle.locked.contains(i)).accessibilityLabel(store.t("Bit \(i+1)","Bit \(i+1)")+(puzzle.locked.contains(i) ? store.t(", bloccato",", locked"):""))
                }
            }
            Text(store.t("Le lampadine piene indicano bit attivi. I pallini pieni sotto ogni leva indicano i controlli collegati.","Filled bulbs indicate active bits. Filled dots below each switch indicate its connected checks.")).font(.caption).foregroundStyle(.secondary)
            DisclosureGroup(store.t("Guarda la matrice e la sindrome","Inspect the matrix and syndrome")) {
                let rows=(0..<puzzle.columns[0].count).map { r in puzzle.columns.map {String($0[r])}.joined(separator:"&") }.joined(separator:"\\\\")
                math("H=\\begin{pmatrix}"+rows+"\\end{pmatrix},\\qquad s=\\begin{pmatrix}"+run.syndrome(puzzle).map(String.init).joined(separator:"\\\\")+"\\end{pmatrix}",size:15)
            }
        }
    }
    private func allocationBoard(_ puzzle:AllocationPuzzle) -> some View {
        VStack(alignment:.leading,spacing:16) {
            math("\\text{"+store.t("Ridondanza usata","Redundancy used")+"}:\\quad "+String(run.allocationCost(puzzle))+"\\le "+String(puzzle.budget))
            if run.allocationCost(puzzle) > puzzle.budget { Label(store.t("Budget superato: prova una tessera meno costosa.","Over budget: try a less expensive tile."),systemImage:"exclamationmark.triangle").font(.caption) }
            Text(store.t("Tessere disponibili · scegli e poi assegna","Available tiles · select, then assign")).font(.headline)
            LazyVGrid(columns:[GridItem(.adaptive(minimum:155))],spacing:10) {
                ForEach(puzzle.cards) { card in
                    Button { selectedCard=card.id; message=nil } label: {
                        tile(selected:selectedCard == card.id) { VStack(spacing:7) {
                            Text(card.name.value(store.language)).font(.system(size:12,weight:.semibold))
                            math("["+String(card.n)+","+String(card.k)+","+String(card.d)+"]_{"+String(card.q)+"}",size:16)
                            Text(run.state.assignments.values.contains(card.id) ? store.t("Assegnata","Assigned"):store.t("Disponibile","Available")).font(.caption2).foregroundStyle(.secondary)
                        } }
                    }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String((puzzle.cards.firstIndex(where: {$0.id == card.id}) ?? 0)+1)).disabled(solved).accessibilityLabel(card.name.value(store.language))
                }
            }
            ForEach(puzzle.stations) { station in
                Button {
                    guard let selectedCard else { message=store.t("Scegli prima una tessera dal vassoio.","First select a tile from the tray."); return }
                    play(.assign(station.id,selectedCard))
                } label: {
                    tile { VStack(alignment:.leading,spacing:8) {
                        HStack { Label(station.name.value(store.language),systemImage:"antenna.radiowaves.left.and.right").font(.headline); Spacer(); Image(systemName:run.stationFits(station,puzzle:puzzle) ? "checkmark.seal.fill":"circle.dotted") }
                        math("\\begin{aligned}q&="+String(station.q)+",& k&\\ge "+String(station.payload)+",\\\\t&="+String(station.errors)+",& n&\\le "+String(station.maxLength)+".\\end{aligned}",size:16)
                        if let id=run.state.assignments[station.id], let card=puzzle.cards.first(where:{$0.id == id}) {
                            Text(card.name.value(store.language)).font(.callout)
                            Text(run.stationFits(station,puzzle:puzzle) ? store.t("Vincoli locali rispettati","Local constraints satisfied"):store.t("Controlla alfabeto, capacità, errori e lunghezza.","Check alphabet, capacity, errors, and length.")).font(.caption).foregroundStyle(.secondary)
                        } else { Text(store.t("In attesa di una tessera","Waiting for a tile")).font(.caption).foregroundStyle(.secondary) }
                    } }
                }.buttonStyle(GameBoardButtonStyle()).manualQAKey(String(UnicodeScalar(97+(puzzle.stations.firstIndex(where: {$0.id == station.id}) ?? 0))!)).disabled(solved).accessibilityLabel(station.name.value(store.language))
            }
        }
    }
}

private struct FlowTokenList: View {
    let tokens:[RouteToken]
    let language:AppLanguage
    var body:some View {
        LazyVGrid(columns:[GridItem(.adaptive(minimum:145))],alignment:.leading,spacing:8) {
            ForEach(tokens) { token in Label(token.label.value(language),systemImage:"checkmark.circle").font(.system(size:11)).padding(8).frame(maxWidth:.infinity,alignment:.leading).background(Color.secondary.opacity(0.07),in:RoundedRectangle(cornerRadius:8)) }
        }
    }
}

private struct CurveGarden: View {
    let puzzle:CurvePuzzle
    let current:CurvePoint
    let language:AppLanguage
    var body:some View {
        VStack(spacing:12) {
            Canvas { context,size in
                let margin:CGFloat=22, step=min((size.width-2*margin)/CGFloat(puzzle.p-1),(size.height-2*margin)/CGFloat(puzzle.p-1))
                let left=(size.width-step*CGFloat(puzzle.p-1))/2
                func position(_ point:CurvePoint)->CGPoint { CGPoint(x:left+CGFloat(point.x!)*step,y:size.height-margin-CGFloat(point.y!)*step) }
                var grid=Path()
                for i in 0..<puzzle.p {
                    let x=left+CGFloat(i)*step,y=size.height-margin-CGFloat(i)*step
                    grid.move(to:CGPoint(x:x,y:margin)); grid.addLine(to:CGPoint(x:x,y:size.height-margin))
                    grid.move(to:CGPoint(x:left,y:y)); grid.addLine(to:CGPoint(x:left+CGFloat(puzzle.p-1)*step,y:y))
                }
                context.stroke(grid,with:.color(.secondary.opacity(0.15)),lineWidth:1)
                for point in puzzle.points {
                    let pos=position(point), rect=CGRect(x:pos.x-4,y:pos.y-4,width:8,height:8)
                    context.fill(Path(ellipseIn:rect),with:.color(.secondary.opacity(0.6)))
                }
                if puzzle.target.x != nil {
                    let pos=position(puzzle.target)
                    context.draw(Text("★").font(.system(size:30)).foregroundColor(.orange),at:pos)
                }
                if current.x != nil {
                    let pos=position(current)
                    context.stroke(Path(ellipseIn:CGRect(x:pos.x-13,y:pos.y-13,width:26,height:26)),with:.color(Palette.accent),lineWidth:3)
                    context.fill(Path(ellipseIn:CGRect(x:pos.x-6,y:pos.y-6,width:12,height:12)),with:.color(Palette.accent))
                }
            }
            HStack(spacing:14) {
                Image(systemName:current == .infinity ? "figure.walk":"circle")
                RichMathView(text:"\\(\\Omega\\)",size:15,compact:true).frame(width:30)
                Text(language.text(current == .infinity ? "Neutro corrente":"Neutro",current == .infinity ? "Current identity":"Identity"))
                if puzzle.target == .infinity { Image(systemName:"star.fill").foregroundStyle(.orange) }
                Spacer()
                Label(language.text("Tu","You"),systemImage:"circle.inset.filled").foregroundStyle(Palette.accent)
                Label(language.text("Meta","Goal"),systemImage:"star.fill").foregroundStyle(.orange)
            }.font(.caption).padding(.horizontal,15)
        }.padding(12).background(Color.secondary.opacity(0.045),in:RoundedRectangle(cornerRadius:14))
    }
}
