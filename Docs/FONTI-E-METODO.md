# Fonti, metodo e limiti

## Documenti di riferimento

I percorsi `/mnt/data/...` della conversazione originale appartenevano a un altro ambiente. Per preparare il catalogo sono stati recuperati e letti i quattro allegati della stessa conversazione; i file omonimi presenti sul Mac non sono stati usati al loro posto. I PDF non sono inclusi nella repository pubblica né nell’app distribuita: i diritti restano ai rispettivi autori. Per consultare una fonte, scegli una copia locale che sei autorizzato a usare.

| ID | File | Pagine fisiche | Etichette PDF | Identificazione nel documento |
|---|---|---:|---|---|
| A | AppuntiFilippone - English.pdf | 34 | 0–33 | Coding Theory and Cryptography, 6 March 2018; autore non indicato nel frontespizio |
| C | Cryptography-REV2 - English.pdf | 75 | 0–74 | Alessio Lombardo, lezioni di Giovanni Falcone, UniPa A.A. 2017/2018; 24 October 2019, Revision 2 |
| T | Coding Theory-REV2 - English.pdf | 24 | 0–23 | Alessio Lombardo, lezioni di Giovanni Falcone, UniPa A.A. 2017/2018; 12 November 2019, Revision 2 |
| E | Exercises - English.pdf | 2 | 1–2 | Data Encryption and Codes — Exercises; 18 consegne |

Il nome del file AppuntiFilippone non viene trattato come prova dell’autore. I titoli bibliografici restano quelli leggibili nei PDF: la denominazione del corso non viene uniformata retroattivamente.

Gli hash SHA-256 completi sono memorizzati in `catalog.json` e mostrati nella scheda della fonte. I quattro allegati totalizzano **135 pagine**. I materiali del corso e le quattro lezioni generate totalizzano otto documenti e centosettantasei pagine. Con i due riferimenti matematici aggiunti il catalogo descrive dieci documenti e trecentotrentanove pagine. / The course materials and generated lectures total eight documents and one hundred seventy-six pages; the two added mathematical references bring the catalog to ten documents and three hundred thirty-nine pages.

## Lezioni generate usate per la preparazione

Sono state lette e copiate dalla cartella effettiva `~/Desktop/Università/UNIPA/DEC/Generated Slides/`:

| ID | File | Pagine | Contributo |
|---|---|---:|---|
| L29 | Lecture 29-09-26.pdf |10| Cifrari, OTP, campi, Diffie–Hellman, maschera additiva ed ElGamal |
| L30 | Lecture 30-09-26.pdf |6| Dimensione in bit, potenze modulari, RSA |
| L06 | Lecture 06-10-26.pdf |8| Divisibilità, Euclide, Bézout, Fermat, RSA, CRT, densità dei primi |
| L14 | Lecture 14-10-26.pdf |17| Probabilità, compleanno, Buffon, rho, Floyd, logaritmi e congruenze |

Questi file sono **documenti di studio generati**, che dichiarano registrazioni e appunti come materiali di partenza. Non vengono descritti come diapositive originali del docente. Le loro sezioni “Additional explanation”, correzioni e riscontri mantengono il significato dichiarato nel documento. La presente app non ha verificato le registrazioni di origine e non attribuisce al docente le spiegazioni aggiunte nei PDF generati.

Le sette nuove voci autonome sono divisibilità, CRT, congruenze lineari, probabilità, complessità in bit, Buffon e strumenti sui polinomi. Tutte le altre voci e gli esercizi hanno ricevuto spiegazioni bilingui sviluppate.

## Indici e copertura

### Cryptography

Indice nelle pagine PDF 2–3. Il corpo copre cifrari storici e analisi delle frequenze (4–10), algebra e aritmetica modulare (11–17), RSA (18–21), Diffie–Hellman ed ElGamal (22–25), gruppi e logaritmo discreto (25–29), geometria proiettiva e curve (29–38), divisori e operazioni sui punti (38–47), ElGamal su curve (47–49), iperellittiche di genere 2 (50–55), firme (55–59), fattorizzazione e logaritmo discreto (59–73). Le pagine 73–75 contengono i riepiloghi.

DECpedia rappresenta questi nuclei con voci autonome e raggruppamenti espliciti. Le sezioni storiche non diventano consigli di sicurezza attuali. Non sono state riprodotte le stime di prestazioni dei computer o le affermazioni sui prodotti commerciali come fatti aggiornati.

### Coding Theory

Indice nelle pagine PDF 2–3. Definizioni iniziali (4–6), codici lineari e matrici (7–10), distanza e limiti (10–13), codici ciclici come ideali (14–15), Hamming (15–17), Hadamard (17), Golay (17–19), Reed–Solomon (19–20), BCH (20–22), Riemann–Roch e Goppa (22–23), riepilogo (24).

L’indice annuncia operazioni sui codici, procedura di correzione ed estensioni dei campi, ma il corpo del PDF non le sviluppa tutte come sezioni autonome. Alcune pagine riportano esplicitamente continuazioni o matrici presenti nelle slide originali ma non nel testo disponibile. L’MVP non ricostruisce quelle parti attribuendole a questo PDF: quando possibile usa gli Appunti e cita le loro pagine, altrimenti lascia il rimando all’originale.

### Appunti

Indice a PDF 2. Cifratura simmetrica e algebra (3–7), chiave pubblica e geometria (7–16), firme (16–17), fattorizzazione (18–20), teoria dei codici (20–30), nove esercizi (30–34). L’app usa questo documento per collegare le due dispense e recuperare spiegazioni operative, sindromi, costruzioni di campi ed esercizi.

### Exercises

Il documento non ha un indice tematico separato. A PDF 1 ci sono gli esercizi 1–14; a PDF 2 quelli 15–18. Il raggruppamento editoriale è:

- 1–3: ElGamal su curve ellittiche.
- 4–5 e 10–11: firme ElGamal.
- 6–9: firme RSA.
- 12: BCH; 13–14 e 16: codici ciclici.
- 15 e 18: Reed–Solomon; 17: Hamming.

Tutte le18 consegne sono rappresentate in italiano e inglese, con i dati numerici conservati. Gli svolgimenti aggiunti nell’app sono dichiarati editoriali. Il PDF non contiene soluzioni. Quattro rimandi collegano le consegne 14, 15, 17 e 18 agli esercizi corrispondenti negli Appunti. Le nove voci “Appunti N” sviluppano i procedimenti della fonte con guide bilingui, passaggi e ricalcoli esplicitamente integrativi.

## Provenienza dei contenuti

Ogni blocco del catalogo dichiara `provenance`:

- `source`: sintesi, traduzione o riscrittura matematica di contenuti effettivamente presenti. Uno o più `citationIDs` risolvono documento, pagina iniziale/finale, sezione e breve riscontro testuale.
- `editorial`: spiegazione integrativa, esempio originale o chiarimento. Non contiene citazioni che possano farlo apparire come un testo del PDF.

La sintesi iniziale di una voce è un abstract editoriale del suo contenuto. Non è una citazione letterale. La tassonomia e tutte le relazioni sono scelte di organizzazione dello studio.

Il riscontro `evidence` permette di controllare che il passo esista nell’intervallo indicato; non è una verifica automatica della correttezza matematica di ogni frase della sintesi. Per la verifica concettuale si sono confrontati i passi rilevanti e i calcoli essenziali. Le pagine degli indici e alcune formule sono state controllate anche visivamente.

## Incongruenze gestite esplicitamente

| Punto della fonte | Trattamento nell’MVP |
|---|---|
| C PDF 13: definizione introduttiva del MCD con “greater” sugli esponenti | Nota nella voce Euclide: per il MCD si prendono gli esponenti minori; si conserva l’algoritmo e l’identità di Bézout |
| T PDF 6: “cardinality” per n−rank(H) | La voce usa “dimensione”; la cardinalità sul campo finito è qᵏ |
| C PDF 26: gruppo di punti ellittici presentato genericamente come ciclico | Nota: il gruppo è abeliano, non necessariamente ciclico; si lavora nel sottogruppo generato dal punto scelto |
| C PDF 40: Pic(C) usato per il quoziente di grado zero | Notazione Pic⁰(C), con spiegazione del cambiamento |
| C PDF 57–59: sezione chiamata DSA, formule con s=k⁻¹(H(m)+ar) | Titolo esplicito “convenzione delle dispense”; equazione di verifica coerente; non viene identificata con il DSA standard |
| C PDF 68: MCD diverso da 1 come condizione di successo | Si richiede 1<d<n; d=n provoca un nuovo tentativo |
| C PDF 70: divisione per un coefficiente non nullo modulo l’ordine | Nota: serve invertibilità; altrimenti si risolve una congruenza lineare |
| T PDF 24: etichetta “Optimal” per Hamming e Golay | Si distinguono perfezione, ciclicità e ottimalità rispetto a Singleton; per [7,4,3], 3<4 |
| T PDF 17 e 24: parametri di Hadamard non uniformi | La voce segue la costruzione esplicita delle funzioni affini a PDF 17, concorde con A PDF 23–24 |
| T PDF 16: r≥1 nella famiglia Hamming con d=3 | Il caso non degenere viene presentato con r≥2 |
| T PDF 23: grado non negativo accostato all’effettività | La nota distingue grado totale ed effettività, che richiede coefficienti non negativi punto per punto |
| Varianti di polinomio reciproco e vettore di lunghezza n | La voce distingue il reciproco usuale dall’inversione del vettore riempito con zeri e dagli shift ciclici |

Le note sono integrazioni editoriali riconoscibili. Non modificano i PDF originali e non certificano che ogni affermazione delle fonti sia stata corretta. Le parti che non servivano all’MVP sono lasciate consultabili nei documenti.

## Ulteriore riscontro numerico

A **A PDF 31**, il prodotto delle prime sei radici diγ=1+j, con j²=−1 in GF(9), non dà l’espansione stampata: il coefficiente di x³ corretto è **j−1**, mentre la pagina scrive1. Il polinomio ricalcolato verifica gh=x⁸−1. L’esempio di sindrome della pagina non verifica sotto i controlli dichiarati: nelle voci18 e Appunti4 si fornisce un esempio sostitutivo esplicitamente editoriale, verificato con aritmetica del campo. Il PDF resta invariato.

## Dimostrazioni sviluppate / Developed proofs

La versione attuale include il percorso completo della prova di Riemann–Roch tramite normalizzazione finita, due carte, bilancio delle dimensioni e dualità locale della traccia. Sono sviluppati anche grado dei divisori principali, grado canonico, genere iperellittico, identificazione ellittica con le classi e forma ridotta di Mumford. Il percorso sui primi dimostra gli strumenti di Cauchy, le stime, le proprietà necessarie della zeta e il lemma di Newman prima di concludere il teorema dei numeri primi. Le ipotesi e i fondamenti di partenza sono dichiarati nelle voci. La congettura di Artin rimane una congettura.

The current version includes the complete Riemann–Roch proof route through finite normalization, two charts, dimension balance and local trace duality. It also develops principal-divisor degree, canonical degree, hyperelliptic genus, the elliptic correspondence with classes and reduced Mumford form. The prime-number route proves Cauchy’s tools, the bounds, the required zeta properties and Newman’s lemma before concluding the prime number theorem. Entries state their hypotheses and starting foundations. Artin’s conjecture remains a conjecture.

I riferimenti aggiunti sono il volume di Pavel Guerzhoy e l’articolo di Don Zagier, identificati come riferimenti matematici supplementari e inclusi separatamente dai materiali del corso. Le dimostrazioni nell’app sono esposizioni editoriali, non testi attribuiti alle dispense. Vedi [percorsi delle prove](PERCORSI-PROVE.md).

Added references are Pavel Guerzhoy’s volume and Don Zagier’s article, labelled as supplementary mathematical references and included separately from the course materials. App proofs are editorial expositions, not text attributed to the course notes. See [proof routes](PERCORSI-PROVE.md).

## Architettura e scelte di progetto

- SwiftUI per finestre, barre laterali, elenchi, ricerca, testo, note e collegamenti.
- PDFKit per consultare il documento reale e la pagina fisica indicata.
- WebKit compone il testo con LaTeX e KaTeX inclusi localmente. Il catalogo passa attraverso escaping HTML; KaTeX usa `trust: false`. Un gestore locale ammette soltanto script, stile e font inclusi, con CSP che blocca connessioni esterne. / WebKit renders text with locally bundled LaTeX and KaTeX. Catalog text is HTML-escaped; KaTeX uses `trust: false`. A local handler admits only bundled scripts, styles and fonts, with CSP blocking external connections.
- JSON incluso nel bundle per un catalogo controllabile e modificabile, senza rete o servizi AI.
- JSON personale separato, scrittura atomica e protezione dalla sovrascrittura di uno stato illeggibile.

La ricerca richiede tutte le parole della query, ignora maiuscole e accenti e favorisce i titoli e i sinonimi rispetto al corpo. Non offre stemming, OCR, ricerca nei PDF, modifica delle voci dentro l’app o sincronizzazione. Ci sono controlli di comprensione nel testo; non ci sono simulatori crittografici o quiz con correzione automatica.

Il catalogo contiene centoventuno voci con testi italiani e inglesi. Le revisioni conservano esempi, ipotesi e passaggi in entrambe le lingue, insieme a provenienza, pagine e separazione dalle note personali. / The catalog contains one hundred twenty-one entries with Italian and English text. Revisions preserve examples, hypotheses and reasoning in both languages, alongside provenance, pages and separation from personal notes.

## Riferimenti tecnici

Le API native seguono la documentazione Apple di [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview), [PDFView](https://developer.apple.com/documentation/pdfkit/pdfview) e [WKNavigationDelegate](https://developer.apple.com/documentation/webkit/wknavigationdelegate). Questi riferimenti documentano l’implementazione e non sono fonti dei contenuti DEC.
