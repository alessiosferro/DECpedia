# DECpedia 1.2

Enciclopedia personale nativa per Mac, interamente offline, con interfaccia, spiegazioni, esempi e dimostrazioni in italiano e inglese. Il selettore **IT / EN** mantiene aperta la stessa voce e salva la lingua scelta.

Il catalogo comprende **121 voci: 94 argomenti e 27 esercizi**. La biblioteca registra quattro allegati originali, quattro documenti di studio generati dalle lezioni e due riferimenti matematici aggiunti: **10 fonti, 339 pagine indicate**. Le spiegazioni sono sviluppate nell’app; il catalogo conserva i riferimenti bibliografici e le pagine.

La repository pubblica e l’app distribuita **non contengono i PDF**: i diritti restano ai rispettivi autori e il progetto non concede licenze di ridistribuzione. Per leggere una fonte, apri la relativa scheda e scegli dal Mac una copia che sei autorizzato a consultare. La ricerca, le voci, gli esempi e le dimostrazioni funzionano anche senza quei file.

## Aprire e modificare l’app

L’app compilata, fornita separatamente in `DECpedia-Mac.zip`, funziona su **macOS 13 o successivo**, con **Apple Silicon o Intel**. Estrai l’archivio e apri `DECpedia.app`; puoi spostarla in Applicazioni. La firma è locale, senza notarizzazione per la distribuzione pubblica.

Per il progetto editabile serve **Xcode 15 o successivo**, installato e aperto almeno una volta:

1. Apri `DECpedia.xcodeproj`.
2. Scegli lo schema **DECpedia** e la destinazione **My Mac**.
3. Premi **⌘R**. Non è necessario un team Apple Developer.

In alternativa, apri `Avvia DECpedia.command`, oppure esegui dalla cartella del progetto:

```bash
./Scripts/build-app.sh --launch
```

Lo script compila e apre `Build/DECpedia.app`. Se macOS blocca lo script scaricato, usa il progetto Xcode. `Package.swift` permette anche `swift run`; il progetto Xcode genera il bundle con icona e metadati. Non servono account, server, chiavi API o pacchetti da scaricare.

[Guida inglese integrale](Docs/RUNNING-EN.md).

## Leggere e studiare

La barra laterale organizza gli argomenti; la ricerca consulta entrambe le lingue. Ogni voce collega prerequisiti, argomenti successivi e rimandi inversi. L’**indice della voce** porta direttamente alle singole sezioni. Il lettore usa un carattere da libro, paragrafi distanziati e formule LaTeX disposte al centro, in uno spazio ampio. Solo le relazioni fondamentali hanno un riquadro leggero; le altre restano visibili senza attirare più attenzione del necessario. Le formule molto larghe scorrono orizzontalmente. Ogni blocco formula include un pulsante per copiare il codice LaTeX.

Le spiegazioni partono dall’intuizione, definiscono simboli e ipotesi e sviluppano i passaggi con esempi. Italiano e inglese conservano gli stessi contenuti matematici. Sono presenti anche un diagramma delle carte e un grafico calcolato del conteggio dei primi. Le note personali rimangono nella lingua in cui le scrivi.

Il percorso **Dimostrazioni · curve** costruisce ideali, localizzazione, variabili separanti, normalizzazione finita, anelli di valutazione, norme, differenziali, dualità locale della traccia e incollamento su due carte. Da questi strumenti ricava Riemann–Roch, grado canonico, dimensioni dei codici da valutazioni, genere iperellittico, corrispondenza ellittica con le classi e unicità della forma ridotta di Mumford.

Il percorso **Dimostrazioni · numeri primi** sviluppa le stime di Chebyshev, gli strumenti complessi di Cauchy, il prodotto di Eulero, il prolungamento della zeta, l’assenza di zeri sul bordo e la prova del lemma tauberiano di Newman, poi conclude il teorema dei numeri primi.

Le prove dichiarano le ipotesi: curve lisce, proiettive e geometricamente integre su campi perfetti; per il modello iperellittico, caratteristica dispari e polinomio senza radici multiple di grado dispari. La base di partenza comprende campi, polinomi, algebra lineare e fondamenti reali. La congettura di Artin conserva il proprio stato di congettura.

Scorciatoie: **⌘F** ricerca, **⌘D** preferito, **⌘1** tutte le voci, **⌘2** preferiti, **⌘3** fonti, **⌘[ / ⌘]** cronologia.

## Fonti e provenienza

**Fonte / Source** identifica contenuti collegati alle pagine effettive dei documenti. **Integrazione didattica / Teaching addition** identifica le spiegazioni, le dimostrazioni e gli esempi sviluppati per l’app. Le prove aggiunte non sono attribuite ai PDF del corso. I due riferimenti supplementari sono identificati come tali nella biblioteca.

Le lezioni provengono da `~/Desktop/Università/UNIPA/DEC/Generated Slides/`: sono appunti generati da registrazioni e materiali di studio, distinti dalle diapositive originali del docente. Hash SHA-256, pagine, etichette e riscontri sono stati verificati sulle copie locali usate per la preparazione; i file PDF non sono pubblicati in questa repository. Il lettore distingue la posizione fisica del foglio dall’etichetta della pagina.

Il documento Exercises contiene consegne, non soluzioni. Gli svolgimenti aggiunti sono editoriali. L’incongruenza Reed–Solomon nella pagina fisica 31 degli Appunti è segnalata, con un esempio ricalcolato e verificato separatamente.

Vedi [fonti e metodo](Docs/FONTI-E-METODO.md), [tassonomia bilingue](Docs/TASSONOMIA.md), [percorsi delle prove](Docs/PERCORSI-PROVE.md) e [verifiche](Docs/VERIFICA.md).

## Note e preferiti

Note, preferiti, ultima voce e lingua sono salvati automaticamente in:

```text
~/Library/Application Support/DECpedia/state.json
```

Il menu File esporta una copia JSON. Per ripristinarla, sostituisci il file con l’app chiusa; non c’è ancora un comando d’importazione. Uno stato illeggibile o di versione sconosciuta viene conservato, sospendendo le sovrascritture e mostrando l’errore.

## Modificare il catalogo

Il file editabile è `Sources/DECpedia/Resources/catalog.json`. Ogni voce ha ID stabile, titoli e sintesi IT/EN, categoria, sinonimi, prerequisiti, relazioni, blocchi e citazioni. Ogni modifica a `title` o `text` va riportata integralmente in `titleEN` o `textEN`, con gli stessi esempi e passaggi.

Nel testo usa `\(...\)` per la matematica in linea e `\[...\]` per le equazioni separate. Nel JSON le barre inverse devono essere raddoppiate. Scrivi anche i numeri del testo didattico dentro delimitatori LaTeX. I metadati di navigazione, le pagine e i PDF originali mantengono il proprio formato.

I blocchi formula conservano `latex` e `mathML`; lo schermo usa ora il LaTeX. Un blocco `source` deve indicare `citationIDs`; un blocco `editorial` lascia i riferimenti bibliografici nella scheda della voce, per evitare attribuzioni improprie. `page` ed `endPage` sono posizioni fisiche inclusive, da uno; `evidence` conserva il riscontro nel documento. Il catalogo valida rimandi, pagine, provenienza e assenza di cicli nei prerequisiti.

Ricompila dopo le modifiche. La ricerca riguarda le voci, non l’intero testo dei PDF. Modifica dei contenuti dentro l’app, sincronizzazione, OCR, servizi AI e simulatori crittografici non sono implementati.

## Verifiche e tecnologie

```bash
./Scripts/test.sh
```

I **16 test** verificano catalogo, copertura bilingue, prerequisiti delle prove, ricerca, salvataggio, delimitatori LaTeX, numeri nel testo didattico, citazioni e calcoli indipendenti degli esercizi. Se aggiungi copie locali dei PDF, i test controllano anche hash, pagine ed evidenze delle citazioni. Lo script accetta `--disable-sandbox` negli ambienti che impediscono il sottoprocesso sandbox di SwiftPM; sul normale Mac non serve.

Se hai Node installato, puoi verificare anche tutte le espressioni con lo stesso KaTeX incluso nell’app, senza installare pacchetti:

```bash
node Scripts/validate-latex.js
```

Per la compilazione universal:

```bash
xcodebuild -project DECpedia.xcodeproj -scheme DECpedia -configuration Release \
  -derivedDataPath Build/Universal ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO build
```

L’app usa SwiftUI, Foundation, AppKit, PDFKit e WebKit. KaTeX e i font sono inclusi localmente, con licenza MIT in `Resources/MathAssets/LICENSE`. JavaScript è limitato al lettore locale; i documenti ricevono solo contenuti testuali escapati, KaTeX non accetta contenuti fidati, le risorse sono ammesse da un gestore locale e connessioni esterne sono bloccate. Non sono implementate telemetria o richieste di rete.

I diritti dei PDF restano ai rispettivi autori; il progetto personale non assegna loro una licenza di ridistribuzione pubblica.
