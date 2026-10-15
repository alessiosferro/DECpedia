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
        fragments(text).map { fragment in
            switch fragment {
            case .prose(let value): return escape(value).replacingOccurrences(of: "\n\n", with: "<br><br>").replacingOccurrences(of: "\n", with: "<br>")
            case .inline(let value): return "<span class=\"math inline\">\(escape(value))</span>"
            case .display(let value): return "<div class=\"math display\">\(escape(value))</div>"
            }
        }.joined()
    }
}
