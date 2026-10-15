import Foundation

/// A small, deterministic parser: prose is always escaped, only delimited math is rendered.
public enum MathMarkup {
    public enum Fragment: Equatable {
        case prose(String), inline(String), display(String)
    }
    public static func fragments(_ text: String) -> [Fragment] {
        var result: [Fragment] = []
        var rest = text[...]
        while !rest.isEmpty {
            let inline = rest.range(of: #"\("#)
            let display = rest.range(of: #"\["#)
            let candidate: (Range<String.Index>, Bool)?
            if let a = inline, let b = display { candidate = a.lowerBound < b.lowerBound ? (a,false) : (b,true) }
            else if let a = inline { candidate = (a,false) }
            else if let b = display { candidate = (b,true) }
            else { candidate = nil }
            guard let (opening, isDisplay) = candidate,
                  let close = rest[opening.upperBound...].range(of: isDisplay ? #"\]"# : #"\)"#) else {
                result.append(.prose(String(rest))); break
            }
            if opening.lowerBound > rest.startIndex { result.append(.prose(String(rest[..<opening.lowerBound]))) }
            let formula = String(rest[opening.upperBound..<close.lowerBound])
            result.append(isDisplay ? .display(formula) : .inline(formula))
            rest = rest[close.upperBound...]
        }
        return result
    }
    public static func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
    public static func html(_ text: String) -> String {
        let parts = fragments(text)
        // Only explicit paired **markers** select key concepts. Math, numbers,
        // arbitrary HTML, and unpaired markers never receive automatic emphasis.
        let markers = parts.reduce(0) { count, fragment in
            if case .prose(let value) = fragment { return count + value.components(separatedBy: "**").count - 1 }
            return count
        }
        var emphasized = false
        return parts.enumerated().map { index, fragment in
            switch fragment {
            case .prose(var value):
                // Display blocks supply their own vertical space. Do not turn
                // surrounding source newlines into a second set of blank lines.
                if index > 0, case .display = parts[index - 1] {
                    value = String(value.drop(while: \.isWhitespace))
                }
                if index + 1 < parts.count, case .display = parts[index + 1] {
                    value = String(value.reversed().drop(while: \.isWhitespace).reversed())
                }
                guard markers > 0 && markers.isMultiple(of: 2) else { return proseHTML(value) }
                return value.components(separatedBy: "**").enumerated().map { index, part in
                    let marker: String
                    if index == 0 { marker = "" }
                    else {
                        emphasized.toggle()
                        marker = emphasized ? "<strong class=\"key-concept\">" : "</strong>"
                    }
                    return marker + proseHTML(part)
                }.joined()
            case .inline(let value): return "<span class=\"math inline\">\(escape(value))</span>"
            case .display(let value): return "<div class=\"math display\">\(escape(value))</div>"
            }
        }.joined()
    }
    private static func proseHTML(_ value: String) -> String {
        escape(value).replacingOccurrences(of: "\n\n", with: "<br><br>").replacingOccurrences(of: "\n", with: "<br>")
    }
}
