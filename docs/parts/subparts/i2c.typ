#import "../../common.typ": *

#hl[What is I²C?]

I²C is a *synchronous*, *half-duplex*, *multi-master* serial bus developed by Philips in 1982. Only *2 wires* are needed regardless of how many devices are on the bus.

#v(0.6em)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 0.8em,
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 11pt)[
    #text(weight: "bold", fill: accent)[2 Wires Only] \
    #text(size: 14pt)[SDA (data) and SCL (clock) — shared by all devices on the bus.]
  ],
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 11pt)[
    #text(weight: "bold", fill: accent)[Addressed] \
    #text(size: 14pt)[Every slave has a 7-bit (or 10-bit) address. No CS pins needed.]
  ],
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 11pt)[
    #text(weight: "bold", fill: accent)[ACK/NACK] \
    #text(size: 14pt)[Slave acknowledges every byte — master knows if data arrived.]
  ],
  rect(fill: accent.lighten(80%), stroke: accent, radius: 6pt, inset: 11pt)[
    #text(weight: "bold", fill: accent)[Multi-Master] \
    #text(size: 14pt)[Multiple masters can share the bus with built-in arbitration.]
  ],
)

#v(0.7em)
Common uses: sensors (temp, IMU, humidity), EEPROMs, RTCs, LCD controllers, power management ICs.

---

#hl[Bus Topology & Pull-up Resistors]

All devices share the same SDA and SCL wires. SDA and SCL are *open-drain* lines — devices can only pull them *Low*.   Pull-up resistors connected to VCC bring the lines *High* when nobody is pulling them down.

#v(0.5em)
This allows any device to signal without short-circuiting others.

#text(fill: signal-low, weight: "bold")[#_icons.important Too high] → slow rise time, signal corruption at high speed.\
#text(fill: signal-low, weight: "bold")[#_icons.important Too low] → excessive current, devices struggle to pull Low.

#align(center)[#image("../../images/i2c-bus.svg", width: 70%)]

/*
#text(weight: "bold")[Typical pull-up values:]
- *4.7 kΩ* — standard mode (100 kHz)
- *2.2 kΩ* — fast mode (400 kHz)
- *1 kΩ* — fast-mode plus (1 MHz)
*/

---

#hl[Device Addressing]

Every slave has a *7-bit address* (most common) hardwired or configurable via address pins.

#image("../../images/i2c-address-frame.svg", width: 80%)

The master sends the address at the start of every transaction, followed by a *R/W̄ bit*:
- *0* → master wants to *write* to slave
- *1* → master wants to *read* from slave

// 7-bit addressing → up to *128 addresses*, but some are reserved → *112 usable* in practice.
// *10-bit addressing* extends this to 1024 devices (two-byte address header, rarely needed).

// #text(fill: amber, weight: "bold")[Conflict:] Two slaves with the same address on the same bus will collide — check datasheets carefully.
// Reserved addresses: 0x00 (general call), 0x01–0x07, 0x78–0x7F.

---

#hl[START and STOP Conditions]

I²C uses special *bus conditions* — not regular data bits — to delimit transactions. They are unique because SDA changes *while SCL is High* (normally forbidden during data transfer).



#grid(columns: (auto, auto), gutter: 1.5em)[
  #align(center)[
    #image("../../images/i2c-bus-conditions.svg", width: 100%)
  ]][
  #rect(fill: accent.lighten(85%), stroke: accent, radius: 6pt, inset: 11pt)[
    #text(weight: "bold", fill: accent, size: 9pt)[START (S)] \
    #text(size: 9pt)[SDA goes *High→Low* while SCL is *High*.\
      Signals the beginning of a transaction.\
      Bus is now "busy".]]
  // A *Repeated START* (Sr) re-starts without releasing the bus — used to switch between read and write in one transaction.
  #rect(fill: accent.lighten(85%), stroke: accent, radius: 6pt, inset: 11pt)[
    #text(weight: "bold", fill: accent, size: 9pt)[STOP (P)] \
    #text(size: 9pt)[SDA goes *Low→High* while SCL is *High*.\
      Signals end of transaction.\
      Bus returns to "idle".]
  ]
]

---

#hl[Data Transfer & ACK/NACK]

Data is transferred *8 bits at a time*, MSB first. After each byte, there is a mandatory *9th clock pulse* for the acknowledgement bit:

/ ACK (0): receiver pulls SDA *Low*: "got it, send more"
/ NACK (1): SDA stays *High*: "stop" or "not ready"

Who sends ACK?
/ Write transaction: slave ACKs each byte from master
/ Read transaction: master ACKs each byte from slave; master sends NACK on the *last* byte to signal it's done

// #text(fill: signal-high, weight: "bold")[Key advantage over SPI:] Master knows immediately if a slave is present or not.
/*
  #rect(fill: light, radius: 4pt, inset: 10pt)[
    ```
    SCL  ┌─┐ ┌─┐ ... ┌─┐  ┌─┐
         │ │ │ │     │ │  │ │
      ───┘ └─┘ └─    └─┘  └─┘
             8 data bits   ACK

    SDA  [7][6][5]...[0] [ACK]
                           ↑
                   slave pulls Low
                   (or stays High=NACK)
    ```
  ]
*/

---

#hl[Write Transaction]

A typical register read _(e.g. from a sensor)_ uses a *Repeated START*:


#v(0.6em)
#grid(
  columns: (auto, auto),
  gutter: 0.8em,
  [#align(center)[
    #image("../../images/i2c-dataflow.png", width: 80%)
  ]],
  [
    #grid(rows: (auto, auto, auto), gutter: 0.8em)[
      #rect(fill: accent.lighten(85%), stroke: accent, radius: 5pt, inset: 10pt)[
        #text(weight: "bold", fill: accent)[Phase 1 — Write]\
        #text(size: 10pt)[Master sends slave address + register it wants to read from.]
      ]
      #rect(fill: accent.lighten(85%), stroke: accent, radius: 5pt, inset: 10pt)[
        #text(weight: "bold", fill: accent)[Repeated START]\
        #text(size: 10pt)[Bus stays busy. Master switches direction without a STOP.]
      ]
      #rect(fill: accent.lighten(85%), stroke: accent, radius: 5pt, inset: 10pt)[
        #text(weight: "bold", fill: accent)[Phase 2 — Read]\
        #text(size: 10pt)[Master re-addresses slave in Read mode. Slave drives SDA.]
      ]]],
)

---

#hl[Clock Stretching]

A slave that needs more time to process data can *hold SCL Low* after the master releases it — effectively pausing the clock.

The master, before driving SCL High again, checks if the line is already High. If it finds SCL still Low (slave holding it), it waits until the slave releases it.

#text(fill: signal-high, weight: "bold")[Use cases:]
- Slow ADC completing a conversion
- EEPROM finishing an internal write cycle
- Slave needing time to prepare the next data byte

#v(0.4em)
#text(fill: signal-low, weight: "bold")[Risk:] A buggy slave that never releases SCL will *hang the bus*. Some masters implement a timeout and reset.
/*
#rect(fill: light, radius: 4pt, inset: 10pt)[
  #set text(font: "Fira Code", size: 10pt)
  ```
  SCL  ──┐ ┌──┐      ┌──┐ ┌──
         └─┘  └──────┘  └─┘
                  ↑
            slave holds SCL Low
            (master waits here)

  SDA  ────[data]──────[data]──
  ```
]
*/
#important[Only possible because SCL is open-drain — slave can pull Low without fighting the master.]

---

#hl[I²C Speed Modes]

// #set text(size: 17pt)
#table(
  columns: (1.4fr, .7fr, .7fr, 2fr),
  fill: (_, row) => if row == 0 { accent } else if calc.odd(row) { light } else { white },
  stroke: 0.5pt + luma(180),
  inset: 9pt,
  align: (left, center, center, left),
  text(fill: white, weight: "bold")[Mode],
  text(fill: white, weight: "bold")[Max Speed],
  text(fill: white, weight: "bold")[Pull-up],
  text(fill: white, weight: "bold")[Notes],

  [Standard Mode (Sm)], [100 kHz], [4.7 kΩ], [Original spec, most devices support],
  [Fast Mode (Fm)], [400 kHz], [2.2 kΩ], [Very widely supported],
  [Fast-Mode Plus (Fm+)], [1 MHz], [1 kΩ], [Requires stronger drivers],
  [High-Speed Mode (Hs)], [3.4 MHz], [special], [Special master code, rare],
  [Ultra-Fast Mode (UFm)], [5 MHz], [N/A], [Unidirectional, no ACK, very rare],
)

#info[Most embedded projects use *Standard* or *Fast* mode. Not all slaves support Fast-Mode Plus or above — always check the datasheet. Higher speeds require shorter bus lengths and lower pull-up values.]

---

#hl[I²C — Pros & Cons]

#grid(
  columns: (1fr, 1fr),
  gutter: 1.5em,
  rect(fill: signal-high.lighten(75%), stroke: signal-high, radius: 6pt, inset: 14pt)[
    #set text(size: 17pt)
    - *Only 2 wires* regardless of slave count
    - Built-in *ACK/NACK* — detects missing slaves
    - *Multi-master* with hardware arbitration
    - *Clock stretching* for slow slaves
    - Simple board routing, long bus possible at low speed
  ],
  rect(fill: signal-low.lighten(75%), stroke: signal-low, radius: 6pt, inset: 14pt)[
    #set text(size: 17pt)
    - *Half-duplex* — can't read and write simultaneously
    - *Slower* than SPI (max ~5 MHz vs 100 MHz)
    - *Address conflicts* possible with fixed-address slaves
    - Open-drain + pull-ups add *capacitance* — limits bus length at high speed
    - Protocol overhead (address + ACK per byte)
  ],
)

#url-block("codes/i2c.jl")
