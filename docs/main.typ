#import "@preview/touying:0.6.1": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "@preview/cetz:0.3.4"
#import "@preview/theorion:0.3.2": *

#import themes.metropolis: *
#import cosmos.clouds: *
#show: show-theorion

#show link:underline
#set par(justify: true)

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

#show: codly-init.with()
#codly(languages: codly-languages)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

= Outline <touying:hidden>
#outline(title: none, depth: 1)

#include "parts/rpi.typ"
#include "parts/jl.typ"
#include "parts/ec.typ"

#focus-slide[
  Thank you for your attention
]

// Bibliography
#set heading(numbering: none, outlined: false) 
= Bibliography

---

#bibliography("bibliography.bib", full: true, style: "apa", title: none)