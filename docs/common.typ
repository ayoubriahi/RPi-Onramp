#import "@preview/touying:0.7.3": *

// colour tokens
#let accent = rgb("#028090")
#let amber = rgb("#F4A261")
#let dark = rgb("#1a1a2e")
#let light = rgb("#f4f4f4")
#let bg-light = rgb("#EAF4F6")
#let muted    = rgb("#5C6E7A")
#let signal-high = rgb("#02C39A")
#let signal-low = rgb("#F96167")
#let light-blue = rgb("#4A4A75")
#let light-green = rgb("#44AA44")
#let light-red = rgb("#EF4444")
#let red = rgb("#990F0F")
#let black = rgb("#111111")
#let dark-gray = rgb("#2C2C2C")
#let mid-gray = rgb("#555555")
#let light-gray = rgb("#EBEBEB")
#let off-white = rgb("#F5F5F5")
#let white = rgb("#FFFFFF")
#let info-color = rgb("#3b82f6")
#let warning-color = rgb("#f59e0b")
#let note-color = rgb("#8b5cf6")
#let important-color = rgb("#ef4444")

#let hl(body) = block(
  fill: rgb("#d7d733"),
  inset: 8pt,
  radius: 4pt,
  stroke: 1pt + rgb("#000"),
)[
  #body
]

#let title-slide(title, subtitle) = {
  set page(fill: dark)
  set text(fill: white)
  align(horizon + center)[
    #v(0.4em)
    #text(size: 40pt, weight: "bold")[#title]
    #v(0.6em)
    #line(length: 40%, stroke: 1.5pt + accent)
    #v(0.6em)
    #text(size: 16pt, fill: luma(200))[#subtitle]
  ]
}

// icon map
#let _icons = (
  info: "ℹ",
  warning: "⚠",
  note: "✎",
  important: "✦",
)

#let fancy-block(kind, accent, body) = block(
  width: 100%,
  radius: 6pt,
  clip: true,
  stroke: accent + 1pt,
  fill: accent.lighten(90%),
)[
  #grid(
    columns: (auto, 1fr),
    // left colored sidebar
    block(
      fill: accent,
      inset: (x: 10pt, y: 12pt),
    )[
      #set text(fill: white, size: 12pt)
      #_icons.at(kind)
    ],
    // right content
    block(
      inset: (x: 16pt, y: 12pt),
    )[
      #set text(fill: accent.darken(30%), weight: "bold")
      #upper(kind)
      #v(4pt)
      #set text(fill: luma(40), weight: "regular")
      #body
    ],
  )
]

// public callouts
#let info(body) = fancy-block("info", info-color, body)
#let warning(body) = fancy-block("warning", warning-color, body)
#let note(body) = fancy-block("note", note-color, body)
#let important(body) = fancy-block("important", important-color, body)

#let bit-label(bits) = {
  set text(size: 13pt, fill: dark.lighten(30%))
  bits
}

#let url-block(url) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  stroke: (left: 3pt + rgb("#24292f")),
  fill: rgb("#f6f8fa"),
)[
  #grid(
    columns: (auto, 1fr),
    gutter: 10pt,
    align: horizon,
    [
      #box(
        inset: 6pt,
        radius: 50%,
        fill: rgb("#24292f"),
        text(fill: white, weight: "bold")[</>],
      )
    ],
    [
      Source code is available at #h(5pt) #text(fill: rgb("#0969da"))[
        #link("https://github.com/a-mhamdi/RPi-Onramp/blob/main/" + url)[#url]
      ]
    ],
  )
]
