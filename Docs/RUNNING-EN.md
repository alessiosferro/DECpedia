# DECpedia 1.2

A native personal Mac encyclopedia, entirely offline, with its interface, explanations, examples and proofs in Italian and English. The **IT / EN** selector preserves the open entry and saves your language choice.

The catalog contains **121 entries: 94 topics and 27 exercises**. Its library records four original attachments, four generated lecture study documents and two added mathematical references: **10 sources, 339 cited pages**. Explanations are developed inside the app; the catalog retains bibliographic references and page numbers.

The public repository and distributed app **do not contain the PDFs**. Their rights remain with their authors, and this project grants no redistribution license. To read a source, open its entry and choose a local copy you are authorized to use. Search, encyclopedia entries, examples and proofs work without those files.

## Open and edit the app

The compiled app, supplied separately in `DECpedia-Mac.zip`, supports **macOS 13 or later**, **Apple Silicon and Intel**. Extract the archive and open `DECpedia.app`; you can move it to Applications. It has a local signature and is not notarized for public distribution.

The editable project requires **Xcode 15 or later**, installed and opened at least once:

1. Open `DECpedia.xcodeproj`.
2. Choose the **DECpedia** scheme and **My Mac** destination.
3. Press **⌘R**. No Apple Developer team is required.

Alternatively, open `Avvia DECpedia.command`, or run from the project directory:

```bash
./Scripts/build-app.sh --launch
```

The script builds and opens `Build/DECpedia.app`. If macOS blocks the downloaded script, use Xcode. `Package.swift` also supports `swift run`; the Xcode project produces the bundle with its icon and metadata. No account, server, API key or package download is required.

[Full Italian guide](../README.md).

## Read and study

The sidebar organizes topics; search covers both languages. Each entry links prerequisites, subsequent topics and backlinks. **Entry contents** jumps directly to individual sections. The reader uses a book typeface, spaced paragraphs and centered LaTeX formulas set in a generous area. Only the most important relations receive a subtle frame; other equations remain clear without competing for attention. Very wide equations scroll horizontally. Each formula block has a button to copy its LaTeX source.

Explanations begin with intuition, define symbols and hypotheses, and develop reasoning through examples. Italian and English preserve the same mathematical content. A chart-gluing diagram and a computed prime-count graph are also included. Personal notes stay in the language in which you write them.

The **Proofs · curves** route develops ideals, localization, separating variables, finite normalization, valuation rings, norms, differentials, local trace duality and two-chart gluing. These establish Riemann–Roch, canonical degree, evaluation-code dimensions, hyperelliptic genus, the elliptic correspondence with divisor classes, and uniqueness of reduced Mumford form.

The **Proofs · prime numbers** route develops Chebyshev bounds, Cauchy’s complex-analysis tools, Euler’s product, zeta continuation, absence of boundary zeros and the proof of Newman’s Tauberian lemma, then concludes the prime number theorem.

Proofs state their hypotheses: smooth projective geometrically integral curves over perfect fields; odd characteristic and a squarefree odd-degree polynomial for the hyperelliptic model. Starting foundations comprise fields, polynomials, linear algebra and basic real analysis. Artin’s conjecture retains its status as a conjecture.

Shortcuts: **⌘F** search, **⌘D** bookmark, **⌘1** all entries, **⌘2** bookmarks, **⌘3** sources, **⌘[ / ⌘]** history.

## Sources and provenance

**Fonte / Source** identifies content linked to actual document pages. **Integrazione didattica / Teaching addition** identifies explanations, proofs and examples developed for the app. Added proofs are not attributed to the course PDFs. The two supplementary references are labelled accordingly in the library.

Lecture files come from `~/Desktop/Università/UNIPA/DEC/Generated Slides/`: these are generated study notes based on recordings and study materials, distinguished from original instructor slides. SHA-256 hashes, pages, labels and citation evidence were checked against the local copies used to prepare the catalog; PDF files are not published in this repository. The reader distinguishes physical file positions from page labels.

Exercises contains questions, not solutions. Added solutions are editorial. The Reed–Solomon inconsistency on physical page 31 of Appunti is flagged and accompanied by a separately recalculated and checked example.

See [sources and method](FONTI-E-METODO.md), [bilingual taxonomy](TASSONOMIA.md), [proof routes](PERCORSI-PROVE.md) and [verification](VERIFICA.md).

## Notes and bookmarks

Notes, bookmarks, last entry and language are saved automatically in:

```text
~/Library/Application Support/DECpedia/state.json
```

The File menu exports a JSON copy. To restore it, replace this file while the app is closed; no import command is implemented yet. An unreadable or unsupported state is preserved, with overwrites suspended and an error displayed.

## Edit the catalog

Edit `Sources/DECpedia/Resources/catalog.json`. Each entry has a stable ID, IT/EN titles and summaries, category, aliases, prerequisites, relations, blocks and citations. Every change to `title` or `text` must be fully reflected in `titleEN` or `textEN`, including the same examples and reasoning.

Use `\(...\)` for inline mathematics and `\[...\]` for separate equations. Double backslashes in JSON. Put study-text numerals inside LaTeX delimiters too. Navigation metadata, page numbers and original PDFs retain their own formats.

Formula blocks keep `latex` and `mathML`; the screen now uses LaTeX. A `source` block requires `citationIDs`; an `editorial` block leaves bibliographic references at entry level to avoid false attribution. `page` and `endPage` are inclusive physical positions starting at one; `evidence` records textual support in the document. Validation checks links, pages, provenance and prerequisite cycles.

Rebuild after editing. Search covers entries, not full PDF text. In-app content editing, synchronization, OCR, AI services and cryptographic simulators are not implemented.

## Checks and technology

```bash
./Scripts/test.sh
```

The **16 tests** cover catalog integrity, bilingual coverage, proof dependencies, search, persistence, LaTeX delimiters, study-text numerals, citations and independent exercise calculations. If you add local PDF copies, tests also check their hashes, pages and citation evidence. The script accepts `--disable-sandbox` where the SwiftPM sandbox subprocess is restricted; it is unnecessary on a normal Mac.

If Node is installed, validate every expression with the app’s bundled KaTeX, without installing packages:

```bash
node Scripts/validate-latex.js
```

For a universal build:

```bash
xcodebuild -project DECpedia.xcodeproj -scheme DECpedia -configuration Release \
  -derivedDataPath Build/Universal ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO build
```

The app uses SwiftUI, Foundation, AppKit, PDFKit and WebKit. KaTeX and fonts are bundled locally, with the MIT license in `Resources/MathAssets/LICENSE`. JavaScript is confined to the local reader; documents receive escaped text, KaTeX disables trusted content, a local handler admits only bundled resources, and external connections are blocked. No telemetry or network requests are implemented.

PDF rights remain with their authors; this personal project grants no public redistribution license for them.
