# DECpedia 1.4.2

A personal, fully offline encyclopedia for Mac, with an interface, explanations, examples, and proofs in Italian and English. The **IT / EN** selector keeps the current entry open and remembers your language choice.

The catalog contains **121 entries: 94 topics and 27 exercises**. The library records four original attachments, four study documents generated from lectures, and two supplementary mathematical references: **10 sources, with 339 cited pages**. Explanations are developed in the app; the catalog retains bibliographic references and page numbers.

The public repository and distributed app **do not include the PDFs**: copyright remains with their respective authors, and this project grants no redistribution license. To read a source, open its entry in the library and select a local copy you are authorized to consult. Search, entries, examples, and proofs also work without those files.

## Open and edit the app

The compiled app, distributed separately as `DECpedia-Mac.zip`, runs on **macOS 13 or later**, on **Apple Silicon or Intel**. Extract the archive and open `DECpedia.app`; you can move it to Applications. The app is locally signed and is not notarized for public distribution.

To edit the project, you need **Xcode 15 or later**, installed and opened at least once:

1. Open `DECpedia.xcodeproj`.
2. Choose the **DECpedia** scheme and the **My Mac** destination.
3. Press **⌘R**. An Apple Developer team is not required.

Alternatively, open `Avvia DECpedia.command`, or run this from the project folder:

```bash
./Scripts/build-app.sh --launch
```

The script builds and opens `Build/DECpedia.app`. If macOS blocks the downloaded script, use the Xcode project. `Package.swift` also supports `swift run`; the Xcode project creates the app bundle with its icon and metadata. No accounts, servers, API keys, or package downloads are required.

[Full English guide](Docs/RUNNING-EN.md).

## Appearance and reading

Choose **Automatic**, **Light**, or **Dark** from the appearance button in the toolbar or the **Appearance** menu. Automatic follows the macOS appearance, including system changes while the app is open. Your selection is saved with your notes and bookmarks; existing saved data remains compatible.

Selected entries, bookmarks, category icons, and source documents use the native macOS selection foreground instead of green, keeping them readable on the selection background in every appearance.

## Read and study

The sidebar organizes topics, and search covers both languages. Each entry links to prerequisites, follow-up topics, and backlinks. The **table of contents** takes you directly to individual sections. The reader uses a book-style typeface, generous paragraph spacing, and centered LaTeX formulas with room to breathe. Display equations sit in neutral, centered frames without an extra colored highlight. Inline mathematics and numbers stay unhighlighted; only explicitly selected key concepts or formulas receive emphasis. Very wide formulas scroll horizontally. Each formula block has a button to copy its LaTeX source.

Explanations begin with the intuition, define symbols and assumptions, and work through the steps with examples. The Italian and English versions cover the same mathematical content. The app also includes a diagram of the charts and a graph computed from prime-counting data. Long calculations use aligned steps and compact tables, with prose explaining the transitions. Every topic and exercise has been revised in both languages. Personal notes stay in the language in which you write them.

The **Proofs · curves** path builds up ideals, localization, separating variables, finite normalization, valuation rings, norms, differentials, local trace duality, and gluing across two charts. It uses these tools to derive Riemann–Roch, the canonical degree, dimensions of evaluation codes, the hyperelliptic genus, the elliptic correspondence with divisor classes, and uniqueness of the reduced Mumford form.

The **Proofs · prime numbers** path develops Chebyshev estimates, Cauchy's complex-analysis tools, Euler's product, the continuation of the zeta function, the absence of zeros on the boundary, and a proof of Newman's Tauberian lemma, before concluding with the prime number theorem.

The Riemann–Roch entry includes twenty prerequisite chapters, and the prime number theorem entry includes eight. Their definitions, examples, and lemma proofs are included in the entry itself for continuous offline reading, alongside the links to their standalone pages.

The proofs state their assumptions: curves are smooth, projective, and geometrically integral over perfect fields; the hyperelliptic model has odd characteristic and a square-free polynomial of odd degree. The starting point covers fields, polynomials, linear algebra, and real-analysis fundamentals. Artin's conjecture is still presented as a conjecture.

Shortcuts: **⌘F** search, **⌘D** favorite, **⌘1** all entries, **⌘2** favorites, **⌘3** sources, **⌘[ / ⌘]** history.

## Interactive logic games

Open **Logic games** in the sidebar, press **⌘4**, or choose **Play with these concepts** inside a topic section. Every one of the eleven topic sections has its own game, with **three levels each: 33 interactive boards**.

- **Algebra — The remainder lock:** coordinate coupled modular gears.
- **Classical ciphers — The key lanterns:** use shared clues to reconstruct messages encrypted with a reused pad.
- **Public keys — The key courier:** route a parcel through public locks, private-key rooms, relays, and signature checks.
- **Curves — The chord garden:** plan additions, doublings, and reflections on a finite elliptic curve.
- **Signatures — The seal workshop:** match detached signatures with parcels and isolate the forged seal.
- **Factorization — The factor factory:** split composite blocks using a finite supply of gcd tools.
- **Linear codes — The bit bridge:** coordinate switches connected to several parity lamps.
- **Code families — The code village:** allocate code tiles to channels with competing protection, capacity, alphabet, length, and budget constraints.
- **Exercises — The clue room:** escape through a modular lock, a damaged bit bridge, and an elliptic exit.
- **Proofs · curves — The hypothesis laboratory:** collect compatible lemmas to open proof bridges.
- **Proofs · prime numbers — The prime trail:** carry convergence bounds and analytic hypotheses across a proof map.

These are stateful boards with legal moves and a goal, rather than question-and-answer forms. Moves change the board immediately. **Undo**, **Restart**, and gradual **Hints** stay visible. After unlocking a level, read the explanation and follow links back to the encyclopedia; returning to the game preserves the board. Other unfinished games also stay available while the app remains open. Language and theme changes preserve the current game.

Completed runs, best move counts, and the latest hint count are stored with your notes, entirely offline. Unfinished boards are kept in memory until you quit the app. There are no timers, accounts, ads, or online rankings. Puzzle numbers, boards, hints, and explanations are original teaching additions, not exercises attributed to the PDFs. Small RSA parameters illustrate only the verification relation; the games are not secure cryptographic implementations. A zero syndrome means a codeword, without necessarily identifying the original transmission. The code-allocation budget is a game budget in symbols, not a universal physical or bit cost.

## Sources and provenance

**Source** identifies content tied to the documents' actual pages. **Teaching addition** identifies explanations, proofs, and examples developed for the app. Added proofs are not attributed to the course PDFs. The two supplementary references are identified as such in the library.

The lecture materials come from `~/Desktop/Università/UNIPA/DEC/Generated Slides/`. They are notes generated from recordings and study materials, distinct from the instructor's original slides. SHA-256 hashes, pages, labels, and supporting evidence were checked against the local copies used in preparing the app; the PDF files are not published in this repository. The reader distinguishes a sheet's physical position from its printed page label.

The Exercises document contains problem statements, not solutions. Solutions added to the app are editorial additions. The Reed–Solomon inconsistency on physical page 31 of the lecture notes is flagged, with an example recalculated and independently checked.

See [sources and methodology](Docs/FONTI-E-METODO.md), [bilingual taxonomy](Docs/TASSONOMIA.md), [proof paths](Docs/PERCORSI-PROVE.md), and [verification](Docs/VERIFICA.md). These documents are currently available in Italian.

## Notes and favorites

Notes, favorites, the last-opened entry, language, and appearance are saved automatically to:

```text
~/Library/Application Support/DECpedia/state.json
```

The File menu exports a JSON copy. To restore it, replace the file while the app is closed; there is no import command yet. If the saved state is unreadable or has an unknown version, the app preserves it, suspends further overwrites, and displays an error.

## Edit the catalog

The editable file is `Sources/DECpedia/Resources/catalog.json`. Each entry has a stable ID, Italian and English titles and summaries, a category, synonyms, prerequisites, relationships, content blocks, and citations. Paired `**markers**` in prose explicitly mark a key concept; arbitrary HTML is always escaped. Use `\begin{aligned} ... \\ ... \end{aligned}` inside display delimiters for multi-step calculations. Display equations and standalone formula blocks already have a neutral frame; do not add `\boxed` merely for emphasis.

Every change to `title` or `text` must be translated in full into `titleEN` or `textEN`, preserving the same examples and steps.

Use `\(...\)` for inline mathematics and `\[...\]` for display equations. In JSON, backslashes must be doubled. Put numbers in the instructional prose inside LaTeX delimiters as well. Navigation metadata, page numbers, and original PDFs keep their own formats.

Formula blocks retain both `latex` and `mathML`; the display currently uses LaTeX. A `source` block must specify `citationIDs`; an `editorial` block keeps bibliographic references in the entry to avoid misattribution. `page` and `endPage` are inclusive physical page positions, counted from one; `evidence` records the supporting passage in the document. The catalog validator checks links, pages, provenance, and that the prerequisite graph has no cycles.

Rebuild after making changes. Search covers entries, not the full text of the PDFs. In-app content editing, synchronization, OCR, AI services, and cryptographic simulators are not implemented.

## Checks and technology

```bash
./Scripts/test.sh
```

The **24 tests** check the catalog, bilingual coverage, proof prerequisites, search, saving, LaTeX delimiters, numbers in instructional prose, citations, independently calculated exercise results, every game’s reachability within its move budget, transactional undo, locked controls, mathematical examples, and backward-compatible game records. If you add local copies of the PDFs, the tests also check citation hashes, pages, and evidence. The script accepts `--disable-sandbox` in environments that block SwiftPM's sandboxed subprocess; this is not needed on a standard Mac.

If Node is installed, you can also validate every expression with the same KaTeX version bundled in the app, without installing packages:

```bash
node Scripts/validate-latex.js
```

To build a universal binary:

```bash
xcodebuild -project DECpedia.xcodeproj -scheme DECpedia -configuration Release \
  -derivedDataPath Build/Universal ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO build
```

The app uses SwiftUI, Foundation, AppKit, PDFKit, and WebKit. KaTeX and its fonts are bundled locally; the MIT license is in `Resources/MathAssets/LICENSE`. JavaScript is restricted to the local reader. Documents receive only escaped text, KaTeX does not accept trusted content, resources are served by a local handler, and external connections are blocked. Telemetry and network requests are not implemented.

Copyright in the PDFs remains with their respective authors; this personal project does not grant a public redistribution license for them.
