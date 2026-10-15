import SwiftUI
import WebKit
#if canImport(DECpediaCore)
import DECpediaCore
#endif

struct RichMathView: View {
    let text: String
    var size: Double = 17
    @State private var height: CGFloat = 40
    var body: some View {
        BookWebView(text: text, size: size, height: $height)
            .frame(height: height)
    }
}

private struct BookWebView: NSViewRepresentable {
    let text: String
    let size: Double
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
        let key = text + String(size) + String(dark)
        guard key != context.coordinator.lastKey else { return }
        context.coordinator.lastKey = key
        let foreground = dark ? "#ede9e0" : "#263b34"
        let highlight = dark ? "#213e37" : "#eaf2ed"
        let html = """
        <!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src decpedia-math: 'unsafe-inline'; style-src decpedia-math: 'unsafe-inline'; font-src decpedia-math:; connect-src 'none'; img-src 'none'">
        <link rel="stylesheet" href="decpedia-math://assets/katex.min.css">
        <style>html,body{margin:0;padding:0;background:transparent;color:\(foreground);font: \(size)px/1.72 Georgia,'Times New Roman',serif;overflow:hidden}#book{padding:2px 1px 5px;overflow-wrap:break-word}.inline{background:\(highlight);border-radius:4px;padding:1px 3px}.display{background:\(highlight);border-left:3px solid #789c85;border-radius:7px;margin:18px 0;padding:14px 16px;overflow-x:auto;overflow-y:hidden}.katex{font-size:1.07em}.katex-display{margin:0;white-space:nowrap}.error{color:#b34032;white-space:pre-wrap}</style>
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
