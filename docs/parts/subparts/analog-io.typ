#import "../../common.typ": *

Unlike Arduino, the Raspberry Pi has *no built-in ADC* — all GPIO pins are
strictly digital. Analog I/O requires external hardware.

#v(0.4cm)

#grid(
  columns: (1fr, 1fr),
  gutter: 1cm,
  [
    *Analog Input (ADC)*
    - Common chip: *MCP3008* (10-bit, 8-ch)
    - Communicates over *SPI*
    - Resolution: 1024 steps over 0 – 3.3 V
    - ~3.2 mV per step
  ],
  [
    *Analog Output (DAC)*
    - Common chip: *MCP4725* (12-bit)
    - Communicates over *I²C*
    - Resolution: 4096 steps over 0 – 3.3 V
    - ~0.8 mV per step
  ],
)

---

`PiGPIO.jl` provides hardware-timed PWM on any GPIO pin via the `pigpiod` daemon, giving clean pulses without CPU spin.

#info[PWM can approximate analog output without a DAC — useful for motor speed and LED dimming.]

#url-block("codes/analog-io.jl")
