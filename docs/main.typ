#import "@preview/touying:0.7.3": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
// #import "@preview/cetz:0.5.2"
#import "@preview/theorion:0.6.0": *

#import themes.metropolis: *
// #import cosmos.clouds: *
#show: show-theorion

#show link: underline
#set par(justify: true)

#show: codly-init.with()
#codly(languages: codly-languages)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => "RPi Onramp | A. Mhamdi",
  config-info(
    title: [Raspberry Pi Onramp],
    subtitle: [A Beginner's Guide to Tinkering with Hardware and Code],
    author: [Abdelbacet Mhamdi],
    date: datetime.today(),
    institution: [MT \@ ISET Bizerte],
  ),
)

// Define fonts
#set text(font: "Fira Sans", weight: "regular", size: 17pt)
#show raw: set text(font: "Fira Code", size: 17pt, stylistic-set: 1) // Enable ligatures for code
#show math.equation: set text(font: "Fira Math", size: 17pt)

#title-slide()

= Outline <touying:hidden>
#outline(title: none, depth: 1)

#include "parts/rpi.typ"
#include "parts/jl.typ"
#include "parts/ec.typ"
#include "parts/use-case.typ"

#focus-slide[
  Thank you for your attention
]

// Bibliography
#set heading(numbering: none, outlined: false)
= Bibliography

---

#bibliography("bibliography.bib", full: true, style: "apa", title: none)
