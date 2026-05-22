
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


#let hl(body) = block(
  fill: rgb("#d7d733"),
  inset: 8pt,
  radius: 4pt,
  stroke: 1pt + rgb("#000"),
)[
  #body
]

// colour tokens
#let info-color = rgb("#3b82f6")
#let warning-color = rgb("#f59e0b")
#let note-color = rgb("#8b5cf6")
#let important-color = rgb("#ef4444")

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
