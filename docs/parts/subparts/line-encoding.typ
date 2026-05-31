#import "../../common.typ": *

Line encoding is how binary data (0s and 1s) gets mapped to a *physical signal* on a wire — defined by voltage levels and when they change.

#v(0.8em)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 1em,
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 12pt)[
    #text(weight: "bold", fill: accent)[Voltage Level] \
    #text(size: 15pt)[High (+V) or Low (−V / 0V) represents a bit]
  ],
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 12pt)[
    #text(weight: "bold", fill: accent)[Transitions] \
    #text(size: 15pt)[A signal change (edge) can itself carry meaning]
  ],
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 12pt)[
    #text(weight: "bold", fill: accent)[Clock Recovery] \
    #text(size: 15pt)[Receiver needs to stay in sync with the sender]
  ],
)

#v(0.8em)
Different schemes trade off between *simplicity*, *bandwidth*, and *self-clocking*.

---

#hl[NRZ-L — Non-Return to Zero Level]

#grid(columns: (1.4fr, 1fr), gutter: 1.5em)[
  *Rule:* Level directly represents the bit value.
  - *High* (+V) → bit *0*
  - *Low*  (-V) → bit *1*
  - Signal stays at that level for the entire bit period
  - No transition needed — hence "non-return to zero"
][
  #image("../../images/nrzl.svg", width: 100%)
]

#v(0.5em)
#text(fill: accent, weight: "bold")[Advantage:] Simple, efficient use of bandwidth. #text(size: 14pt, fill: luma(100))[(Used in RS-232)]
#v(0.3em)
#text(fill: signal-low, weight: "bold")[Problem:] Long runs of the same bit produce no transitions → receiver loses clock sync.

---

#hl[NRZ-I — Non-Return to Zero Inverted]

#grid(columns: (1.4fr, 1fr), gutter: 1.5em)[
  *Rule:* A *transition* encodes the bit, not the level.
  - Bit *1* → *transition* at the start of the bit period
  - Bit *0* → *no transition* (level stays the same)

  #v(0.5em)
  This is *differential* coding: the meaning depends on change, not absolute voltage.
][
  #image("../../images/nrzi.svg", width: 100%)
]

#v(0.3em)
#text(fill: signal-high, weight: "bold")[Advantage:] Immune to polarity inversion (swapped wires don't corrupt data). #text(size: 14pt, fill: luma(100))[(Used in USB, HDLC)]
#v(0.3em)
#text(fill: signal-low, weight: "bold")[Problem:] Long runs of *0s* still produce no transitions → still loses sync.

---

#hl[Manchester Encoding]

#grid(columns: (1.4fr, 1fr), gutter: 1.5em)[
  *Rule:* Each bit period is split in half — the bit
  is encoded by the *mid-bit transition direction*.
  - Bit *0* → *High→Low* transition at mid-bit
  - Bit *1* → *Low→High* transition at mid-bit

  #v(0.3em)
  Every bit has a transition in the middle → *self-clocking*: receiver can always recover the clock.
][
  #image("../../images/manchester.svg", width: 100%)
]
#v(0.5em)
#text(fill: signal-high, weight: "bold")[Advantage:] No long runs without transitions, no DC component. #text(size: 14pt, fill: luma(100))[(Used in 10BASE-T Ethernet, IR remotes)]
#v(0.3em)
#text(fill: signal-low, weight: "bold")[Cost:] Requires *2× the bandwidth* of NRZ — each bit takes two signal intervals.

---

#hl[Differential  Manchester Encoding]

#grid(columns: (1.4fr, 1fr), gutter: 1.5em)[
  *Rule:* Mid-bit transition is *always* present _(for clocking)_. The bit value is encoded by what happens *at the start*:
  - Bit *0* → *transition* at the start of the bit period
  - Bit *1* → *no transition* at the start
  #v(0.3em)
  Combines ideas from NRZI _(differential)_ and Manchester _(guaranteed mid-bit edge)_.
][
  #image("../../images/manchester-diff.svg", width: 100%)
]

#v(0.5em)
#text(fill: signal-high, weight: "bold")[Advantages:] Always self-clocking (mid-bit edge). Immune to polarity inversion. #text(size: 14pt, fill: luma(100))[(Used in Token Ring, IEEE 802.5)]
#v(0.3em)
#text(fill: signal-low, weight: "bold")[Cost:] Same 2× bandwidth overhead as Manchester.

---

#hl[4B/5B — Block Encoding]

#grid(columns: (1.4fr, 1fr), gutter: 1.5em)[
  *Rule:* Every group of *4 data bits* is replaced by a *5-bit code word* chosen to guarantee enough transitions.

  The 5-bit codes are picked so no code has more than *one leading zero* or *two trailing zeros* — ensuring NRZI transitions happen frequently.

  #info[4B/5B is always paired with NRZI — it's a pre-coding step, not a standalone scheme.]
][
  #set text(font: "Fira Code", size: 13pt)
  #rect(fill: light, radius: 4pt, inset: 10pt)[
    ```
    4-bit   5-bit
    ─────── ───────
     0000   11110
     0001   01001
     0010   10100
     ...
     1111   11101

    Unused codes → control symbols (idle, start, end)
    ```
  ]
]

---

#text(fill: important-color, weight: "bold")[Summary Comparison]

#table(
  columns: (1.5fr, 1fr, 1fr, 1fr, 1.5fr),
  fill: (_, row) => if row == 0 { accent } else if calc.odd(row) { light } else { white },
  stroke: 0.5pt + luma(180),
  inset: 8pt,
  align: center + horizon,

  text(fill: white, weight: "bold")[Scheme],
  text(fill: white, weight: "bold")[Self-Clocking],
  text(fill: white, weight: "bold")[DC-Free],
  text(fill: white, weight: "bold")[BW Overhead],
  text(fill: white, weight: "bold")[Used In],

  [NRZ-L], [✗], [✗], [0%], [RS-232],
  [NRZ-I], [Partial], [✗], [0%], [USB, HDLC],
  [Manchester], [✓], [✓], [100%], [10BASE-T, IR],
  [Diff. Manchester], [✓], [✓], [100%], [Token Ring],
  [4B/5B + NRZI], [✓], [Partial], [25%], [Fast Ethernet],
)
