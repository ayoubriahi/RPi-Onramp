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

// Define font variables
#let font-heading = "Molengo"
#let font-body = "Molengo"
#let font-code = "Fira Code"

#set text(
  font: font-body,
  size: 22pt,  // Larger size optimal for slides
  fill: rgb("#1a1a1a"),  // Soft black for better readability
)

// Configure heading styles
#show heading: set text(font: font-heading, weight: "bold", fill: rgb("#0f4c81"))

// Configure Programming/Code block styles
#show raw: set text(
  font: font-code,
  stylistic-set: 1,  // Enables specific font ligatures if supported
)


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