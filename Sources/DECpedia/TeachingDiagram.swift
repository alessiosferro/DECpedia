import SwiftUI

/// Teaching graphics are generated locally from their mathematical definitions.
struct TeachingDiagram: View {
    @EnvironmentObject private var store: AppStore
    let kind: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if kind == "two-charts" {
                HStack(spacing: -24) {
                    chart(store.t("Dati sulla prima carta", "Data on the first chart"), color: .teal)
                    chart(store.t("Dati sulla seconda carta", "Data on the second chart"), color: .blue)
                }.frame(maxWidth: .infinity)
                Text(store.t("La zona comune permette di confrontare i dati. Una funzione globale nasce quando le due descrizioni coincidono.", "The overlap lets us compare the data. A global function exists when the two descriptions agree."))
                    .font(.system(size: 13)).foregroundStyle(.secondary)
            } else if kind == "prime-count" {
                Canvas { context, size in
                    let area = CGRect(x: 12, y: 8, width: size.width-24, height: size.height-20)
                    func point(_ x: Double, _ y: Double) -> CGPoint {
                        CGPoint(x: area.minX + CGFloat((x-2)/98)*area.width, y: area.maxY-CGFloat(y/28)*area.height)
                    }
                    var axes = Path(); axes.move(to: CGPoint(x: area.minX,y:area.minY)); axes.addLine(to:CGPoint(x:area.minX,y:area.maxY));axes.addLine(to:CGPoint(x:area.maxX,y:area.maxY))
                    context.stroke(axes,with:.color(.secondary.opacity(0.4)),lineWidth:1)
                    var exact = Path(); var estimate = Path(); var count = 0
                    for x in 2...100 {
                        let prime = !(2..<x).contains { x % $0 == 0 }
                        if x == 2 { exact.move(to:point(2,0)) }
                        exact.addLine(to:point(Double(x),Double(count)))
                        if prime { count += 1 }
                        exact.addLine(to:point(Double(x),Double(count)))
                        let value = Double(x)/log(Double(x))
                        if x == 2 { estimate.move(to:point(Double(x),value)) } else { estimate.addLine(to:point(Double(x),value)) }
                    }
                    context.stroke(estimate,with:.color(.orange),style:StrokeStyle(lineWidth:2,dash:[5,4]))
                    context.stroke(exact,with:.color(Palette.accent),lineWidth:2)
                }.frame(height:200).accessibilityLabel(store.t("Grafico del conteggio esatto dei primi e della stima asintotica.", "Graph comparing exact prime counts and the asymptotic estimate."))
                HStack(spacing:22) {
                    Label(store.t("Conteggio esatto", "Exact count"),systemImage:"line.diagonal").foregroundStyle(Palette.accent)
                    Label(store.t("Stima asintotica", "Asymptotic estimate"),systemImage:"line.diagonal").foregroundStyle(.orange)
                }.font(.caption)
                RichMathView(text: store.t("Intervallo mostrato: \\(2\\le x\\le100\\). L’asse orizzontale indica la soglia, quello verticale il conteggio. Le due curve rappresentano \\(\\pi(x)\\) e \\(x/\\log x\\).", "Displayed interval: \\(2\\le x\\le100\\). The horizontal axis is the threshold; the vertical axis is the count. The curves represent \\(\\pi(x)\\) and \\(x/\\log x\\)."), size:14)
            }
        }.padding(18).background(Palette.accent.opacity(0.045),in:RoundedRectangle(cornerRadius:12))
    }
    private func chart(_ title: String, color: Color) -> some View {
        Text(title).font(.system(size:13,weight:.medium)).multilineTextAlignment(.center)
            .padding(30).frame(width:220,height:125).background(color.opacity(0.12),in:Ellipse())
            .overlay(Ellipse().stroke(color.opacity(0.4)))
    }
}
