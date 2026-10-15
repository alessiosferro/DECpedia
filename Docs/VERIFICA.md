# Verifica / Verification — DECpedia 1.2

Verificata su macOS con Apple Silicon e Xcode. / Verified on macOS with Apple Silicon and Xcode.

## Contenuti / Contents

- Centoventuno voci, novantaquattro argomenti e ventisette esercizi, con testo italiano e inglese. / One hundred twenty-one entries, ninety-four topics and twenty-seven exercises, with Italian and English text.
- Il catalogo descrive dieci documenti e trecentotrentanove pagine, inclusi due riferimenti matematici supplementari. Hash, pagine, etichette e riscontri delle citazioni sono stati verificati sulle copie locali di preparazione; i PDF sono esclusi dalla repository e dal download pubblico. / The catalog describes ten documents and three hundred thirty-nine pages, including two supplementary mathematical references. Hashes, pages, labels and citation evidence were checked against the local preparation copies; PDFs are excluded from the public repository and download.
- Percorsi interni per Riemann–Roch e il teorema dei numeri primi, con prerequisiti espliciti e prove dei lemmi usati. / Internal Riemann–Roch and prime number theorem routes, with explicit prerequisites and proofs of the lemmas used.
- Numeri del testo didattico e formule in delimitatori LaTeX; composizione verificata con il KaTeX incluso nell’app. / Study-text numerals and formulas use LaTeX delimiters, with rendering syntax checked by the bundled KaTeX.
- Fonti fornite, appunti generati e riferimenti aggiunti distinti; contenuti editoriali identificati come tali. / Supplied sources, generated notes and added references distinguished; editorial content labelled accordingly.

## Controlli automatici / Automated checks

Sedici test superati: catalogo, ricerca bilingue, filtri, persistenza delle note, provenienza, citazioni, rappresentazioni matematiche e catene dei prerequisiti. Quando sono presenti copie locali, il test verifica anche PDF, hash, pagine e riscontri. I controlli dei calcoli includono firme RSA ed ElGamal, decifrature ellittiche, enumerazione dei pesi Golay e aritmetica Reed–Solomon sul campo esteso. Lo script LaTeX aggiuntivo verifica tutte le espressioni senza scaricare dipendenze.

Sixteen tests passed: catalog, bilingual search, filters, note persistence, provenance, citations, mathematical markup and prerequisite chains. When local copies are present, the PDF test also checks hashes, pages and citation evidence. Independent calculation checks cover RSA and ElGamal signatures, elliptic decryption, Golay weight enumeration and Reed–Solomon extension-field arithmetic. The additional LaTeX script validates every expression without downloading dependencies.

Questi controlli non sono una certificazione formale delle dimostrazioni matematiche o della traduzione di ogni frase. / These checks do not constitute formal certification of mathematical proofs or every translated sentence.

## Verifica dell’app / App verification

Compilazione Release per Apple Silicon e Intel riuscita; firma locale verificata. La parte Intel è stata compilata, senza prova su un Mac Intel fisico. Il minimo dichiarato è macOS tredici; l’interazione è stata verificata sul Mac disponibile.

Release builds for Apple Silicon and Intel succeeded; the local signature was verified. Intel was compiled but not run on physical Intel hardware. The declared minimum is macOS thirteen; interaction was checked on the available Mac.

Verificati nella finestra nativa: ricerca, cambio IT/EN, formule LaTeX evidenziate, indice interno con salto agli esempi, rimandi fra voci e apertura del riferimento Riemann–Roch alla pagina citata. I controlli precedenti hanno coperto anche preferiti, taccuino ed apertura delle lezioni generate. Nell’app distribuita, il lettore chiede di scegliere una copia locale dei PDF. Le immagini di anteprima sono catture dell’app.

Checked in the native window: search, IT/EN switching, highlighted LaTeX, the internal contents menu jumping to examples, concept links and opening the Riemann–Roch reference at its cited page. Earlier checks also covered bookmarks, the notebook and generated lecture PDFs. Preview images are app screenshots.

## Riprodurre / Reproduce

```bash
./Scripts/test.sh
node Scripts/validate-latex.js
```

Il secondo comando è facoltativo e richiede Node. L’app e la sua compilazione non lo richiedono. / The second command is optional and requires Node. The app and its build do not require it.

## Limiti effettivi / Actual limits

Le prove dichiarano il modello e i fondamenti su cui lavorano. Non sono formalizzate in un assistente di prova. I PDF originali non vengono riscritti e i numeri nei metadati di navigazione mantengono il formato nativo. Le note sono locali ed esportabili; importazione dall’interfaccia, sincronizzazione, OCR, ricerca integrale nei PDF e modifica delle voci dentro l’app non sono implementati. L’app è firmata localmente e non notarizzata.

Proofs state their model and starting foundations. They are not formalized in a proof assistant. Original PDFs are not rewritten; navigation metadata retains native number formatting. Notes are local and exportable; interface import, synchronization, OCR, full-PDF search and in-app entry editing are not implemented. The app has a local signature and is not notarized.
