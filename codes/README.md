# MWE EXAMPLES for Hardware I/O

The examples in this project are written as Minimum Working Examples (MWEs), small, self-contained scripts that demonstrate one concept at a time. Each example targets **Debian GNU/Linux 13** (**Trixie**) on the **Raspberry Pi 4** and avoids the `pigpio` daemon, which is no longer available in the **Trixie** apt repositories. Instead, the examples rely on `Gpiod.jl` for GPIO control, `LibSerialPort.jl` for UART communication, and direct Linux `spidev` kernel calls via **Julia**'s built-in `ccall` for SPI. 

---

## Hardware & Software

| Item | Details |
|---|---|
| Board | Raspberry Pi 4 Model B |
| OS | Debian GNU/Linux 13 (Trixie) aarch64 |
| Kernel | 6.18.33+rpt-rpi-v8 |
| Julia | 1.9+ |
| Optional | Arduino Uno (for serial/I2C/SPI master-slave examples) |

---

## Dependencies

| Package | Purpose | Install |
|---|---|---|
| `Gpiod.jl` | Digital I/O | `Pkg.add("Gpiod")` |
| `LibSerialPort.jl` | Serial TX/RX | `Pkg.add("LibSerialPort")` |
| `libgpiod-dev` | System library for Gpiod.jl | `sudo apt install libgpiod-dev gpiod` |
| `libserialport-dev` | System library for LibSerialPort.jl | `sudo apt install libserialport-dev` |

> [!TIP]
> SPI uses the Linux `spidev` kernel driver via `ccall` — no extra **Julia** package needed.

---

## 1. Digital I/O

Uses `Gpiod.jl`. Demonstrates LED output (blink) and button input (poll).

> [!TIP]
> Enable via `raspi-config → Interface Options → GPIO`.

**Wiring**

| Component | Pi Pin | GPIO |
|---|---|---|
| LED (+) via 330Ω | Pin 12 | GPIO 18 |
| Button | Pin 11 | GPIO 17 |
| GND | Pin 6 | — |

---

## 2. I2C — LCD Display

Drives a 16×2 HD44780 LCD with a PCF8574 I2C backpack. Only 4 wires needed. Run `sudo i2cdetect -y 1` to confirm the device address _(typically `0x27` or `0x3F`)_. 

> [!TIP]
> Enable via `raspi-config → Interface Options → I2C`.

**Wiring**

| LCD Backpack | Pi Pin |
|---|---|
| VCC | Pin 2 (5V) |
| GND | Pin 6 |
| SDA | Pin 3 (GPIO 2) |
| SCL | Pin 5 (GPIO 3) |

---

## 3. Serial TX/RX (UART)

Uses `LibSerialPort.jl`. Covers loopback test _(TX→RX jumper)_ and Pi↔Arduino bidirectional communication. Disable Bluetooth first to free up the full UART _(`dtoverlay=disable-bt` in `/boot/firmware/config.txt`)_.

**Port names**

| Connection | Port |
|---|---|
| GPIO pins TX/RX | `/dev/serial0` |
| Arduino via USB | `/dev/ttyACM0` |
| USB-serial adapter | `/dev/ttyUSB0` |

**Wiring (GPIO serial)**

| Pi Pin | Signal | Arduino |
|---|---|---|
| Pin 8 (GPIO 14) | TX → | RX (Pin 0) |
| Pin 10 (GPIO 15) | RX ← | TX (Pin 1) |
| Pin 6 | GND | GND |

> [!WARNING]
> Pi is 3.3V logic; Arduino Uno is 5V. Use a voltage divider or logic level shifter on the Arduino TX → Pi RX line.

---

## 4. SPI — Loopback Test

Uses the Linux `spidev` driver directly via Julia `ccall`. No `pigpio` or extra packages needed. The BCM2711 SPI controller does **not** support software loopback _(a physical MOSI→MISO jumper wire is required.)_

> [!TIP]
> Enable via `raspi-config → Interface Options → SPI`.

**Wiring (loopback)**

| Pi Pin | GPIO | Function |
|---|---|---|
| 19 | GPIO 10 | MOSI ┐ jumper |
| 21 | GPIO 9  | MISO ┘ these two |
| 23 | GPIO 11 | SCLK |
| 24 | GPIO 8  | CE0 |

---

> [!IMPORTANT]
> - Always use **BCM (GPIO) numbers**, not physical pin numbers.
> - On Pi 4 + Trixie the config file is `/boot/firmware/config.txt`, not `/boot/config.txt`.
> - Add your user to the `dialout` group for serial access: `sudo usermod -aG dialout $USER`.
> - For I2C devices run `sudo i2cdetect -y 1` before running code to confirm the address.
