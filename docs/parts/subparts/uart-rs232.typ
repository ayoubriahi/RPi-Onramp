#import "../../common.typ": *

#hl[What is UART?]

*UART* — Universal Asynchronous Receiver/Transmitter — is a hardware protocol for serial communication between two devices.

#v(0.6em)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 1em,
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 12pt)[
    #text(weight: "bold", fill: accent)[Asynchronous] \
    #text(size: 15pt)[No shared clock line. Both sides agree on speed in advance.]
  ],
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 12pt)[
    #text(weight: "bold", fill: accent)[Serial] \
    #text(size: 15pt)[Bits sent one at a time over a single wire per direction.]
  ],
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 12pt)[
    #text(weight: "bold", fill: accent)[Full-Duplex] \
    #text(size: 15pt)[TX and RX are separate wires — both sides can talk at once.]
  ],
)

#v(0.8em)
UART is a *logic-level protocol*. RS-232 is one electrical standard built on top of it — defining voltages, connectors, and cable lengths.

---

#hl[UART Frame Structure]

#grid(columns: (1.25fr, 1.1fr), gutter: 1.5em)[
  A UART frame wraps each byte with control bits:

  / Idle: line sits *High* when nothing is sent
  / Start bit: always *0* (Low), signals frame start
  / Data bits: 5 to 9 bits, LSB first (typically 8)
  / Parity bit: optional error check (even/odd/none)
  / Stop bit(s): always *1* (High), 1 or 2 bits

][
  #image("../../images/uart.svg", width: 100%)
]

The receiver detects the *High→Low* edge of the start bit, then samples each bit at the center of its period.

---

#hl[Baud Rate]

#grid(columns: (1.4fr, 1fr), gutter: 1.5em)[
  *Baud rate* = number of *symbols per second* on the line. For UART (one bit per symbol): baud rate = bit rate.

  Both sides must be configured to the *same baud rate* — there is no negotiation. A mismatch causes garbage data.

][
  Common standard rates:

  #set text(size: 16pt)
  #table(
    columns: (1fr, 1fr),
    fill: (_, row) => if row == 0 { accent } else if calc.odd(row) { light } else { white },
    stroke: 0.5pt + luma(180),
    inset: 7pt,
    align: center,
    text(fill: white, weight: "bold")[Baud Rate], text(fill: white, weight: "bold")[Bit Period],
    [9 600], [104.2 µs],
    [19 200], [52.1 µs],
    [115 200], [8.68 µs],
    [921 600], [1.08 µs],
  )
]

#rect(fill: light, radius: 6pt, inset: 14pt)[
  UART #text(weight: "bold", fill: accent)[tolerates] a clock mismatch of up to *±2–3%* before bit sampling drifts enough to cause errors. Over a 10-bit frame, even a 2% error shifts the sample point by *~0.2 bit periods* by the last bit.
]

---

#hl[Parity — Simple Error Detection]

#grid(columns: (1.4fr, 1fr), gutter: 1.5em)[
  The optional *parity bit* is set so the total number of 1-bits in the frame (data + parity) satisfies a rule:

  / Even parity: total count of 1s is even
  / Odd parity: total count of 1s is odd
  / None: no parity bit, faster transmission

  #text(fill: signal-high, weight: "bold")[Detects:] any *single-bit* error.

  #text(fill: signal-low, weight: "bold")[Misses:] any *even number* of flipped bits.
][
  #rect(fill: light, radius: 4pt, inset: 12pt)[
    #set text(font: "Fira Code", size: 10pt)
    ```
    Data: 0b10110010
    1-bits: 4  (even)

    Even parity bit → 0
    (total 1s stays 4)

    Odd parity bit  → 1
    (total 1s = 5)
    ```
  ]
]

Parity does *not* correct errors — only flags them. For correction, higher-level protocols are needed.

---

#hl[RS-232 — Voltage Levels]

RS-232 uses *inverted* and *wide-swing* voltages compared to logic levels:

#v(0.5em)
#align(center)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    rect(fill: signal-low.lighten(70%), stroke: signal-low, radius: 6pt, inset: 14pt)[
      #text(weight: "bold", fill: signal-low)[Logic 1 (Mark / Idle)] \
      #v(0.3em)
      #text(size: 17pt)[
        Voltage between *−3 V and −15 V* \
        Typically *−12 V* in practice
      ]
    ],
    rect(fill: signal-high.lighten(70%), stroke: signal-high, radius: 6pt, inset: 14pt)[
      #text(weight: "bold", fill: signal-high)[Logic 0 (Space / Start)] \
      #v(0.3em)
      #text(size: 17pt)[
        Voltage between *+3 V and +15 V* \
        Typically *+12 V* in practice
      ]
    ],
  )]

#v(0.6em)
The *±3 V dead zone* (−3 V to +3 V) is undefined — signals in this range
are ignored, giving noise immunity.

#v(0.3em)
#text(fill: accent, weight: "bold")[Key point:] Logic 1 = negative voltage. This is *opposite* to TTL/CMOS logic (where 1 = High). A *level shifter* #text(style: "italic")[(e.g. MAX232)] is required to interface RS-232 with a microcontroller.

---

#hl[RS-232 — DB9 Connector & Signals]

#grid(columns: (1fr, 1.2fr), gutter: 1.5em)[
  The classic RS-232 connector is the *DE-9* (often called DB9).

  #v(0.4em)
  #set text(size: 15pt)
  #table(
    columns: (0.4fr, 0.6fr, 1.4fr),
    fill: (_, row) => if row == 0 { accent } else if calc.odd(row) { light } else { white },
    stroke: 0.5pt + luma(180),
    inset: 6pt,
    align: (center, center, left),
    text(fill: white, weight: "bold")[Pin],
    text(fill: white, weight: "bold")[Name],
    text(fill: white, weight: "bold")[Function],

    [1], [DCD], [Data Carrier Detect],
    [2], [RXD], [Receive Data],
    [3], [TXD], [Transmit Data],
    [4], [DTR], [Data Terminal Ready],
    [5], [GND], [Signal Ground],
    [6], [DSR], [Data Set Ready],
    [7], [RTS], [Request To Send],
    [8], [CTS], [Clear To Send],
    [9], [RI], [Ring Indicator],
  )
][
  #v(0.5em)
  For a #text(fill: accent)[minimal connection] #text(style: "italic")[(no flow control)], only *3 wires* are needed:

  #v(0.5em)
  #rect(fill: light, radius: 6pt, inset: 14pt)[
    *Device A*#h(4cm)        *Device B*

    TXD ──────────── RXD\
    RXD ──────────── TXD\
    GND ──────────── GND
  ]

  *RTS/CTS* add hardware flow control — the sender checks CTS before transmitting to avoid overflowing the receiver.
]

---

#hl[UART vs RS-232 — What's the Difference?]

#v(0.3em)
#set text(size: 17pt)
#table(
  columns: (1.2fr, 1fr, 1fr),
  fill: (_, row) => if row == 0 { accent } else if calc.odd(row) { light } else { white },
  stroke: 0.5pt + luma(180),
  inset: 9pt,
  align: (left, center, center),
  text(fill: white, weight: "bold")[Aspect],
  text(fill: white, weight: "bold")[UART],
  text(fill: white, weight: "bold")[RS-232],

  [What it is], [Logic protocol], [Electrical standard],
  [Voltage (logic 1)], [+3.3 V or +5 V], [−3 V to −15 V],
  [Voltage (logic 0)], [0 V], [+3 V to +15 V],
  [Max cable length], [Short (PCB traces)], [~15 m at 9600 baud],
  [Noise immunity], [Low], [High (wide swing)],
  [Connector], [None defined], [DE-9 / DE-25],
  [Interface chip], [None needed], [MAX232 or similar],
)

#v(0.5em)
#text(size: 15pt, fill: luma(120))[
  #_icons.important UART logic levels are for chip-to-chip communication on a PCB. \
  #_icons.important RS-232 was designed for long cables in industrial environments.
]

---

#url-block("codes/tx-rx.jl")
