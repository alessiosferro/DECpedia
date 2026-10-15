# Tassonomia bilingue / Bilingual taxonomy

Le relazioni sono percorsi editoriali di studio. / Relations are editorial study routes.

## Fondamenti algebrici / Algebraic foundations

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| groups | Gruppi e gruppi abeliani | Groups and abelian groups |  |
| rings | Anelli e ideali | Rings and ideals | groups |
| fields | Campi finiti e campi di Galois | Finite fields and Galois fields | rings |
| integer-divisibility | Divisibilità, primi, MCD e mcm | Divisibility, primes, gcd and lcm |  |
| modular-arithmetic | Aritmetica modulare | Modular arithmetic | rings, integer-divisibility |
| euclid | Algoritmo di Euclide esteso | The extended Euclidean algorithm | integer-divisibility |
| modular-inverse | Inverso modulare | Modular inverses | modular-arithmetic, euclid |
| fermat | Piccolo teorema di Fermat | Fermat’s little theorem | fields, modular-arithmetic |
| chinese-remainder | Teorema cinese del resto | The Chinese remainder theorem | modular-inverse |
| linear-congruences | Risolvere congruenze lineari | Solving linear congruences | modular-inverse |
| square-multiply | Square-and-multiply | Square-and-multiply | modular-arithmetic |
| cyclic-groups | Gruppi ciclici, ordine e generatori | Cyclic groups, orders and generators | groups, fields |
| polynomial-facts | Polinomi, radici e interpolazione | Polynomial division, roots and interpolation | fields |
| field-extensions | Estensioni di campi e polinomi irriducibili | Field extensions and irreducible polynomials | fields, polynomial-facts |
| vector-spaces | Spazi vettoriali, basi e rango | Vector spaces, bases and rank | fields, groups |
| algorithm-complexity | Complessità in bit e notazione asintotica | Bit complexity and asymptotic notation | modular-arithmetic |

## Cifrari classici / Classical ciphers

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| cryptography | Crittografia e steganografia | Cryptography and steganography |  |
| monoalphabetic | Sostituzioni monoalfabetiche | Monoalphabetic substitution | cryptography |
| alberti-enigma | Alberti ed Enigma | Alberti’s disk and Enigma | monoalphabetic |
| vigenere | Cifrario di Vigenère | The Vigenère cipher | monoalphabetic, modular-arithmetic |
| kasiski | Metodo di Kasiski | Kasiski examination | vigenere |
| vernam | Vernam e one-time pad | Vernam and the one-time pad | cryptography, probability-basics |

## Chiave pubblica / Public-key cryptography

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| public-key | Crittografia a chiave pubblica | Public-key cryptography |  |
| rsa | RSA | RSA | modular-inverse, fermat, square-multiply, chinese-remainder |
| discrete-log | Logaritmo discreto | Discrete logarithms | cyclic-groups, modular-arithmetic |
| diffie-hellman | Scambio di chiavi Diffie–Hellman | Diffie–Hellman key agreement | discrete-log, square-multiply |
| elgamal | Cifratura ElGamal | ElGamal encryption | diffie-hellman, modular-inverse |
| artin | Congettura di Artin e radici primitive | Artin’s primitive-root conjecture | cyclic-groups |

## Geometria e curve / Geometry and curves

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| projective | Spazi proiettivi e punti all’infinito | Projective spaces and points at infinity | fields, vector-spaces |
| homogeneous | Polinomi e funzioni omogenee | Homogeneous polynomials and rational functions | projective |
| elliptic-curves | Curve ellittiche | Elliptic curves | fields, projective, homogeneous |
| divisors | Divisori, zeri e poli | Divisors, zeros and poles | groups, homogeneous |
| jacobian | Jacobiana e classi di divisori | The Jacobian and divisor classes | divisors |
| elliptic-addition | Somma e raddoppio su curve ellittiche | Elliptic-curve point addition and doubling | elliptic-curves, modular-inverse |
| double-add | Double-and-add | Double-and-add | elliptic-addition |
| elliptic-elgamal | ElGamal su curve ellittiche | ElGamal on elliptic curves | double-add, elgamal |
| hyperelliptic | Curve iperellittiche di genere 2 | Genus-2 hyperelliptic curves | jacobian, field-extensions |

## Firme digitali / Digital signatures

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| hash | Hash e collisioni | Hash functions and collisions |  |
| digital-signatures | Firme digitali: modello | Digital signatures | public-key, hash |
| rsa-signature | Firma RSA | RSA signatures | rsa, digital-signatures |
| elgamal-signature | Firma ElGamal: convenzione delle dispense | ElGamal signatures: the notes’ convention | digital-signatures, discrete-log, modular-inverse |

## Fattorizzazione e probabilità / Factorization and probability

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| factorization | Fattorizzazione e complessità | Factorization and computational cost | rsa, algorithm-complexity |
| lenstra | Metodo di Lenstra · ECM | Lenstra’s elliptic-curve factoring method | elliptic-addition, euclid, factorization |
| pollard-p1 | Algoritmo di Pollard p−1 | Pollard’s p−1 factoring algorithm | factorization, fermat, square-multiply, euclid |
| probability-basics | Probabilità, condizionamento e attesa | Probability, conditioning and expectation |  |
| birthday | Paradosso del compleanno | The birthday paradox | probability-basics |
| buffon | Ago di Buffon e metodo Monte Carlo | Buffon’s needle and Monte Carlo estimation | probability-basics |
| floyd | Orbite e algoritmo di Floyd | Orbits and Floyd’s cycle-finding method |  |
| pollard-rho | Pollard rho per la fattorizzazione | Pollard rho for factorization | factorization, euclid, floyd |
| pollard-log | Pollard rho per il logaritmo discreto | Pollard rho for discrete logarithms | discrete-log, floyd, modular-inverse, linear-congruences |

## Codici lineari / Linear codes

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| words | Alfabeti, parole e codici a blocchi | Alphabets, words and codes |  |
| weight-distance | Peso e distanza di Hamming | Hamming weight and distance | words |
| linear-codes | Codici lineari e parametri [n,k,d]q | Linear codes and their parameters | vector-spaces, words, weight-distance |
| generator-matrix | Matrice generatrice | Generator matrices | linear-codes |
| parity-check | Matrice di controllo e sindrome | Parity-check matrices | linear-codes |
| systematic | Forma sistematica delle matrici | Systematic form and equivalent codes | generator-matrix, parity-check |
| minimum-distance | Distanza minima e colonne di H | Minimum distance from a check matrix | parity-check, weight-distance |
| error-correction | Rilevazione e correzione degli errori | Detecting and correcting errors | minimum-distance |
| singleton | Limite di Singleton | The Singleton bound and MDS codes | minimum-distance |
| hamming-bound | Limite di Hamming | The Hamming sphere-packing bound | error-correction, linear-codes |
| perfect-codes | Codici perfetti | Perfect codes | hamming-bound |
| dual-code | Codice duale | Dual codes and orthogonality | parity-check, generator-matrix |
| syndrome-decoding | Decodifica tramite sindrome | Syndromes and coset decoding | parity-check, error-correction |
| cyclic-codes | Codici ciclici | Cyclic codes and polynomial words | linear-codes, rings |
| generator-polynomial | Polinomio generatore e controllo ciclico | Generator and check polynomials | cyclic-codes |

## Famiglie di codici / Code families

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| repetition | Codici di ripetizione | Repetition codes | error-correction |
| hamming | Codici di Hamming | Hamming codes | minimum-distance, perfect-codes |
| hadamard | Codici di Hadamard ed Hamming esteso | Hadamard and first-order Reed–Muller codes | dual-code, hamming |
| golay | Codici di Golay | Binary and ternary Golay codes | perfect-codes, generator-polynomial |
| reed-solomon | Codici di Reed–Solomon | Reed–Solomon codes | field-extensions, generator-matrix, singleton, polynomial-facts |
| bch | Codici BCH | BCH codes | field-extensions, generator-polynomial, minimum-distance |
| goppa | Codici di Goppa nelle dispense | Algebraic-geometric evaluation codes | riemann-roch, generator-matrix |

## Esercizi / Exercises

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| ex-01 | 01 · ECC: decifrare su GF(37) | 01 · ECC decryption over GF(37) |  |
| ex-02 | 02 · ECC: intercettazione, prima traccia | 02 · ECC interception: first ciphertext |  |
| ex-03 | 03 · ECC: intercettazione, seconda traccia | 03 · ECC interception: second ciphertext |  |
| ex-04 | 04 · Verificare una firma ElGamal | 04 · Verify an ElGamal signature |  |
| ex-05 | 05 · Ricostruire una firma ElGamal | 05 · Construct an ElGamal signature |  |
| ex-06 | 06 · Firma RSA con n=403967 | 06 · RSA signature with n=403967 |  |
| ex-07 | 07 · Firma RSA per il messaggio 102 | 07 · RSA signature for message102 |  |
| ex-08 | 08 · Firma RSA per il messaggio 103 | 08 · RSA signature for message103 |  |
| ex-09 | 09 · Firma RSA con n=875053 | 09 · RSA signature with n=875053 |  |
| ex-10 | 10 · Firma ElGamal su GF(353) | 10 · ElGamal signature over GF(353) |  |
| ex-11 | 11 · Firma ElGamal su GF(199) | 11 · ElGamal signature over GF(199) |  |
| ex-12 | 12 · Dimensione di un BCH primitivo | 12 · Dimension of a primitive BCH code |  |
| ex-13 | 13 · Codice ciclico ternario di lunghezza 25 | 13 · A ternary cyclic code of length25 |  |
| ex-14 | 14 · Codice ciclico minimo su GF(11) | 14 · Minimum cyclic length over GF(11) |  |
| ex-15 | 15 · Reed–Solomon con 49 parole | 15 · Reed–Solomon with49 words |  |
| ex-16 | 16 · Codice ciclico minimo su GF(19) | 16 · Minimum cyclic length over GF(19) |  |
| ex-17 | 17 · Generatore di Hamming [15,11,3]₂ | 17 · A generator for Hamming[15,11,3]₂ |  |
| ex-18 | 18 · Reed–Solomon con 81 parole | 18 · Reed–Solomon with81 words |  |
| appunti-ex-1 | Appunti 1 · Codice ciclico minimo su GF(11) | Notes1 · Minimum cyclic length over GF(11) |  |
| appunti-ex-2 | Appunti 2 · Codice ciclico minimo su GF(13) | Notes2 · Minimum cyclic length over GF(13) |  |
| appunti-ex-3 | Appunti 3 · Reed–Solomon: 49 parole | Notes3 · Reed–Solomon:49 words |  |
| appunti-ex-4 | Appunti 4 · Reed–Solomon: 81 parole | Notes4 · Reed–Solomon:81 words |  |
| appunti-ex-5 | Appunti 5 · Hamming [15,11,3]₂ | Notes5 · Hamming[15,11,3]₂ |  |
| appunti-ex-6 | Appunti 6 · Aritmetica di divisori iperellittici | Notes6 · Hyperelliptic divisor arithmetic |  |
| appunti-ex-7 | Appunti 7 · BCH primitivo narrow-sense | Notes7 · Primitive narrow-sense BCH |  |
| appunti-ex-8 | Appunti 8 · Verificare due firme ElGamal | Notes8 · Verify two ElGamal signatures |  |
| appunti-ex-9 | Appunti 9 · Riduzione di un divisore | Notes9 · Reduce a divisor |  |

## Dimostrazioni · curve / Proofs · curves

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| proof-guide | Come leggere una dimostrazione lunga | Reading a long proof |  |
| local-algebra-basics | Ideali, localizzazione e finitezza | Ideals, localization and finiteness | rings, polynomial-facts, vector-spaces |
| separating-variable | Campi di funzioni e variabili separanti | Function fields and separating variables | field-extensions, polynomial-facts, vector-spaces |
| modules-normalization | Moduli, integralità e normalizzazione | Modules, integrality and normalization | separating-variable, rings, vector-spaces, local-algebra-basics |
| local-valuations | Anelli locali, parametri e ordini | Local rings, parameters and orders | modules-normalization |
| finite-maps-norm | Mappe finite, norme e grado dei divisori | Finite maps, norms and divisor degree | local-valuations, separating-variable |
| differentials-trace | Differenziali e traccia | Differentials and trace | finite-maps-norm, separating-variable |
| local-trace-duality | Il lemma locale di dualità | The local duality lemma | differentials-trace, local-valuations |
| cech-balance | Due carte e il bilancio delle dimensioni | Two charts and the dimension balance | local-valuations, finite-maps-norm, vector-spaces |
| laurent-duality | Dualità esplicita mediante serie di Laurent | Explicit duality using Laurent polynomials | cech-balance, local-trace-duality |
| riemann-roch | Riemann–Roch: enunciato e dimostrazione | Riemann–Roch: statement and proof | laurent-duality, divisors |
| canonical-degree | Grado canonico e dimensioni degli spazi | Canonical degree and dimensions of spaces | riemann-roch |
| hyperelliptic-genus | Perché il grado determina il genere iperellittico | Why degree determines hyperelliptic genus | riemann-roch, local-valuations, differentials-trace |
| elliptic-picard-proof | Dai punti ellittici alle classi di divisori | From elliptic points to divisor classes | canonical-degree, hyperelliptic-genus, divisors |
| mumford-proof | Esistenza e unicità della forma ridotta | Existence and uniqueness of reduced form | hyperelliptic-genus, canonical-degree, divisors, polynomial-facts |

## Dimostrazioni · numeri primi / Proofs · prime numbers

| ID | Italiano | English | Prerequisiti / Prerequisites |
|---|---|---|---|
| analysis-foundations | Limiti, integrali e stime per i numeri primi | Limits, integrals and estimates for primes | integer-divisibility |
| complex-cauchy | Il teorema di Cauchy, dagli integrali alle serie | Cauchy’s theorem, from integrals to series | analysis-foundations |
| chebyshev-bounds | Contare i primi con i coefficienti binomiali | Counting primes with binomial coefficients | analysis-foundations, probability-basics |
| zeta-euler | La funzione zeta e il prodotto di Eulero | Zeta and Euler’s product | complex-cauchy, chebyshev-bounds, integer-divisibility |
| zeta-boundary | Perché la zeta non si annulla sul bordo | Why zeta has no boundary zeros | zeta-euler |
| newman-lemma | Il lemma tauberiano di Newman: prova completa | Newman’s Tauberian lemma: complete proof | complex-cauchy |
| prime-number | Teorema dei numeri primi: dimostrazione | Prime number theorem: proof | zeta-boundary, newman-lemma, chebyshev-bounds |

