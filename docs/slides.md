---
title: Binning und Hashing von großen Vektoren mit FAISS
author: Jonathan Schlue
separator: <!-- s -->
verticalSeparator: <!-- v -->
theme: black
revealOptions:
  transition: 'fade'
---

# Binning und Hashing von großen Vektoren mit FAISS

NOTE: kNN-Suche syntaktische Duplikate im NewsCrawl

<!-- v -->

## Datenset

* http://wortschatz.uni-leipzig.de/de/download

  * Newscrawl

<!-- s -->

## Bereinigung des Korpus'

```{r}
corpus <- VCorpus(VectorSource(sentences))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(
  corpus,
  content_transformer(
    function(x) tolower(x)
  )
)
corpus <- tm_map(corpus, stripWhitespace)
```

NOTE: Satzzeichen, überflüssige Leerzeichen werden entfernt. Zahlen werden wegen Vergleichsfehlern von Datum-Strings entfernt. Stopwörter bleiben, da sonst kurze, aber sehr unterschiedliche Sätze gleich aussehen.

<!-- v -->

## Word-Embedding

```{r}
term.ids <- lapply(as.list(corpus), function(doc) {
  content <- doc$content
  terms <- unlist(stri_split(content, regex = " "))
  terms <- intersect(terms, dtm$dimnames$Terms)
  term.ids <- lapply(terms, get.term.id)
  term.ids[(length(term.ids)+1):d] = -num.terms
  return(term.ids)
})
```

NOTE: Korpus nach DTM (Tf-Gewichtung); Maximale Satzlänge (in Wörtern) ist untere Schranke für Dimensionalität.; naives Embedding: ersetze Terme durch ihrer Term-ID; entsehenden Vektoren hinten mit dem Wert `-num.terms` auffüllen -> maximaler Abstand zu längeren Sätzen.; Alphabetische Ordnung -> ähnliche Terme haben geringen Abstand; Dimensionalität hängt nicht von Korpusgröße ab, ist konstant

<!-- v -->

## FAISS-Indizes

* Speicherverbrauch bei exakter Suche `< 120 MiB`:
  * `IndexFlatL2` (Euklidische Distanz)
  * `IndexFlatIP` (Skalarprodukt)

NOTE: Dimensionsreduktion nicht nötig, da wie erläutert gering und konstant; Sonst mannigfaltige Quantisierungen mögliche Vergleich zum Localized Minimum Hashing interessant

<!-- s -->

## Betrachtung LSH

* _Binning_ und _Hashing_
* `IndexLSH` in FAISS
  * speicherintensiv
  * Hashing unabhängig von Eingabedaten

NOTE: Bessere, in FAISS integrierte Verfahren bieten Quantisierung in Abhängigkeit von Eingabedaten an.
; Produktquantizer, Skalarquantizer, K-Means als vorgeschalteter Index; Ähnlichkeitssuche über Zentroiden

<!-- s -->

## Ergebnisse (M = 30K)

* `{13145, 13151, 13150, 13146}`

```
...

{
  'Email an Autor schreibenErschienen am 04.04.2011 auf Seite 16 Sollten die Mund-Pissoirs in einem neuen Potsdamer Club abgerissen werden?"',
  'Email an Autor schreibenErschienen am 19.10.2010 auf Seite 23 Sollten die Mund-Pissoirs in einem neuen Potsdamer Club abgerissen werden?"',
  'Email an Autor schreibenErschienen am 16.02.2017 auf Seite 14 Sollten die Mund-Pissoirs in einem neuen Potsdamer Club abgerissen werden?"',
  'Email an Autor schreibenErschienen am 05.05.2010 auf Seite 22 Sollten die Mund-Pissoirs in einem neuen Potsdamer Club abgerissen werden?"',
}

...
```

NOTE: offenbar technische Duplikate

<!-- s -->

## Ausblick

* Semantische Äquivalenz?
  * Word-Embedding liefert dann höhere Dimensionalität
    * Kookkurenzen, Satz-Kookurenzen, POS-Tagging
  * Quantizierung vs. LSH dann sehr interessant
* Vollständige Implementierung in Python

NOTE: Python -> Zwischenablage in Datei nicht mehr nötig

  <!-- s -->

## Referenzen

1. https://github.com/facebookresearch/faiss/wiki/
2. https://github.com/facebookresearch/faiss/wiki/Guidelines-to-choose-an-index
