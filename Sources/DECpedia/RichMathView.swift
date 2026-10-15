import SwiftUI
import WebKit
#if canImport(DECpediaCore)
import DECpediaCore
#endif

struct RichMathView: View {
    let text: String
    var size: Double = 17
    var inFormulaBox = false
    @State private var height: CGFloat = 40
    var body: some View {
        BookWebView(text: text, size: size, inFormulaBox: inFormulaBox, height: $height)
            .frame(height: height)
    }
}

private struct BookWebView: NSViewRepresentable {
    let text: String
    let size: Double
    let inFormulaBox: Bool
    @Binding var height: CGFloat
    @Environment(\.colorScheme) private var scheme
    func makeCoordinator() -> Coordinator { Coordinator(height: $height) }
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.setURLSchemeHandler(MathAssets(), forURLScheme: "decpedia-math")
        config.userContentController.add(context.coordinator, name: "size")
        let view = BookWKView(frame: .zero, configuration: config)
        view.navigationDelegate = context.coordinator
        view.setValue(false, forKey: "drawsBackground")
        view.underPageBackgroundColor = .clear
        return view
    }
    func updateNSView(_ view: WKWebView, context: Context) {
        context.coordinator.height = $height
        let dark = scheme == .dark
        let key = text + String(size) + String(dark) + String(inFormulaBox)
        guard key != context.coordinator.lastKey else { return }
        context.coordinator.lastKey = key
        let foreground = dark ? "#ece9e2" : "#252b29"
        let border = dark ? "rgba(236,233,226,0.16)" : "rgba(37,43,41,0.15)"
        let keyLine = dark ? "rgba(128,207,184,0.40)" : "rgba(34,111,92,0.24)"
        let displayStyle = inFormulaBox ? "border:0;padding:8px 0;margin:8px 0 14px" : "border:1px solid \(border);border-radius:8px;padding:20px 16px;margin:24px 0"
        let html = """
        <!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src decpedia-math: 'unsafe-inline'; style-src decpedia-math: 'unsafe-inline'; font-src decpedia-math:; connect-src 'none'; img-src 'none'">
        <link rel="stylesheet" href="decpedia-math://assets/katex.min.css">
        <style>
        html,body{margin:0;padding:0;background:transparent;color:\(foreground);color-scheme:\(dark ? "dark" : "light");font:\(size)px/1.85 Georgia,'Times New Roman',serif;overflow:hidden;-webkit-font-smoothing:antialiased}
        #book{padding:3px 2px 8px;overflow-wrap:break-word}
        .inline{background:none;padding:0 0.035em}
        .display{\(displayStyle);background:none;box-sizing:border-box;overflow-x:auto;overflow-y:hidden;text-align:center;scrollbar-width:thin}
        .katex{font-size:1.08em}
        .katex-display{margin:0.35em 0;white-space:nowrap;text-align:center}
        .key-concept{font-weight:700;box-shadow:inset 0 -0.15em 0 \(keyLine);padding-bottom:0.02em}
        .key-concept .katex{font-weight:inherit}
        .error{color:\(dark ? "#ffb4a5" : "#a62d22");white-space:pre-wrap;font:14px/1.6 ui-monospace,monospace}
        </style>
        <script src="decpedia-math://assets/katex.min.js"></script></head><body><div id="book">\(MathMarkup.html(text))</div>
        <script>
        for(const node of document.querySelectorAll('.math')){const source=node.textContent;try{katex.render(source,node,{displayMode:node.classList.contains('display'),throwOnError:true,trust:false,maxExpand:1000,strict:'ignore',output:'htmlAndMathml'});}catch(error){node.classList.add('error');node.textContent=source+' — '+error.message;}}
        function report(){window.webkit.messageHandlers.size.postMessage(Math.ceil(document.getElementById('book').getBoundingClientRect().height));}
        new ResizeObserver(report).observe(document.getElementById('book'));document.fonts.ready.then(report);report();
        </script></body></html>
        """
        view.loadHTMLString(html, baseURL: nil)
    }
    static func dismantleNSView(_ view: WKWebView, coordinator: Coordinator) {
        view.configuration.userContentController.removeScriptMessageHandler(forName: "size")
        view.stopLoading()
    }
    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var lastKey = ""
        var height: Binding<CGFloat>
        init(height: Binding<CGFloat>) { self.height = height }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let value = message.body as? Double, value.isFinite else { return }
            let updated = CGFloat(max(20, min(value, 100000)))
            DispatchQueue.main.async { if abs(self.height.wrappedValue - updated) > 1 { self.height.wrappedValue = updated } }
        }
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(action.request.url?.absoluteString == "about:blank" ? .allow : .cancel)
        }
    }
}

private final class BookWKView: WKWebView {
    override func scrollWheel(with event: NSEvent) {
        // Horizontal scrolling stays in wide equations; vertical reading belongs to SwiftUI.
        if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) { super.scrollWheel(with: event) }
        else { nextResponder?.scrollWheel(with: event) }
    }
}

private final class MathAssets: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url, url.host == "assets" else { fail(task); return }
        let path = url.path.removingPercentEncoding ?? ""
        let allowed = path == "/katex.min.js" || path == "/katex.min.css" || (path.hasPrefix("/fonts/KaTeX_") && ["woff2","woff","ttf"].contains(url.pathExtension))
        guard allowed, !path.contains(".."), !path.contains("\\") else { fail(task); return }
        #if SWIFT_PACKAGE
        let root = Bundle.module.resourceURL
        #else
        let root = Bundle.main.resourceURL
        #endif
        guard let root, let bytes = try? Data(contentsOf: root.appendingPathComponent("Resources/MathAssets" + path)) else { fail(task); return }
        let mime = ["js":"application/javascript","css":"text/css","woff2":"font/woff2","woff":"font/woff","ttf":"font/ttf"][url.pathExtension] ?? "application/octet-stream"
        task.didReceive(URLResponse(url: url, mimeType: mime, expectedContentLength: bytes.count, textEncodingName: ["js","css"].contains(url.pathExtension) ? "utf-8" : nil))
        task.didReceive(bytes); task.didFinish()
    }
    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}
    private func fail(_ task: WKURLSchemeTask) { task.didFailWithError(URLError(.resourceUnavailable)) }
}
