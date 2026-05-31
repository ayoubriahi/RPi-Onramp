#import "../../common.typ": *

The Raspberry Pi exposes *40 GPIO pins* _(on models B+ and later)_, each configurable as either *input* or *output* at runtime.

#v(0.4cm)

#grid(
  columns: (1fr, 1fr),
  gutter: 1cm,
  [
    *Output mode*
    - Drive pin HIGH (3.3 V) or LOW (0 V)
    - Power LEDs, relays, transistors
    - Max current: *16 mA* per pin
  ],
  [
    *Input mode*
    - Read external logic levels
    - Optional pull-up / pull-down resistors
    - Voltage-safe range: 0 – 3.3 V
  ],
)

#v(0.5cm)
#warning[GPIO operates at 3.3 V logic — never connect 5 V signals directly.]

---

Julia accesses GPIO through the *PiGPIO.jl* package, which wraps the `pigpio` C daemon running on the Pi.

#url-block("codes/digital-io.jl")
#note[Requires `pigpiod` running: `sudo pigpiod` · Install: `]add PiGPIO`]
