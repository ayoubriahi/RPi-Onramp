#import "../common.typ": *
= Julia Codes
---

== Introduction

Julia is a high-level, high-performance programming language designed for numerical and scientific computing. While it is often associated with workstations and servers, Julia runs well on ARM-based hardware including the Raspberry Pi. This makes it an attractive choice for edge computing, data logging, sensor fusion, and lightweight network services running directly on embedded Linux systems.

This document covers how to install Julia on a Raspberry Pi, how to manage GPIO and serial connections, how to use Julia's networking stack, and how to write practical programs that tie these capabilities together.

== Initial Setup

=== Hardware Requirements

Julia can run on any Raspberry Pi model that supports a 64-bit ARM operating system, starting from the Raspberry Pi 3. The Raspberry Pi 4 or 5 is recommended for interactive use and package compilation due to its faster CPU and larger RAM. A microSD card of at least 16 GB is advisable, as Julia's package depot and precompiled artifacts can occupy several gigabytes.

=== Operating System

Install the 64-bit version of Raspberry Pi OS (formerly Raspbian). Julia's official ARM builds target `aarch64`, so the 64-bit OS is required to use them directly. You can download the image from the Raspberry Pi website and flash it with Raspberry Pi Imager.

After first boot, run a full system update before installing Julia:

```bash
sudo apt update && sudo apt upgrade -y
```

=== Installing Julia

The recommended way to install Julia on Raspberry Pi is through `juliaup`, the official Julia version manager.

```bash
curl -fsSL https://install.julialang.org | sh
```

Follow the prompts. After installation, open a new shell session or source your profile:

```bash
source ~/.bashrc
```

Verify the installation:

```bash
julia --version
```

`juliaup` allows you to maintain multiple Julia versions and switch between them with 
```bash
juliaup default <version>
```

==== Alternative: System Package

If you prefer a simpler path without `juliaup`, the Raspberry Pi OS repositories include a Julia package, though it may be an older version:

```bash
sudo apt install julia
```

=== First Launch and the REPL

Start Julia by typing `julia` in the terminal. You will be greeted by the interactive REPL (Read-Eval-Print Loop). From here you can enter expressions, manage packages, and run scripts.

---

Julia has four REPL modes:

/ Julia mode _(default)_: execute Julia expressions.
/ Package mode _(press `]`)_: manage packages with `add`, `rm`, `status`, `update`.
/ Help mode _(press `?`)_: display documentation for any symbol.
/ Shell mode _(press `;`)_: run shell commands without leaving Julia.

To install a package, enter package mode and type:

```
] add SerialPorts
```

To exit the REPL:

```julia
exit()
```

=== Package Depot and Precompilation

Julia compiles packages on first use. On a Raspberry Pi this can be slow — several minutes for large packages — but subsequent launches are fast. Precompilation happens automatically when you `add` a package or `using` it for the first time. // Use `PackageCompiler.jl` to create a custom system image if startup time is critical for your application.
