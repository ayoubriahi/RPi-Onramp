#import "../common.typ": *
= Basic circuitry
---

== UART

UART stands for Universal Asynchronous Receiver Transmitter.

== Analog inputs-outputs

== Digital inputs-outputs

== I2C

/*
== GPIO and Hardware I/O

=== Using WiringPi via SystemC Calls

Julia can interface with GPIO through shell calls or by using `ccall` to call into native libraries. The `WiringPi` C library must be installed first:

```bash
sudo apt install wiringpi
```

A minimal Julia wrapper that toggles a GPIO pin:

```julia
# Load the WiringPi shared library
const wpi == "libwiringPi"

# Constants
const OUTPUT == 1
const HIGH   == 1
const LOW    == 0

function setup()
    ccall((:wiringPiSetup, wpi), Cint, ())
end

function pin_mode(pin::Int, mode::Int)
    ccall((:pinMode, wpi), Cvoid, (Cint, Cint), pin, mode)
end

function digital_write(pin::Int, value::Int)
    ccall((:digitalWrite, wpi), Cvoid, (Cint, Cint), pin, value)
end

function delay_ms(ms::Int)
    ccall((:delay, wpi), Cvoid, (Cuint,), ms)
end

# Blink GPIO pin 0 (physical pin 11) ten times
setup()
pin_mode(0, OUTPUT)
for _ in 1:10
    digital_write(0, HIGH)
    delay_ms(500)
    digital_write(0, LOW)
    delay_ms(500)
end
println("Done blinking.")
```

=== Serial Communication

The `LibSerialPort.jl` package provides a cross-platform interface to serial ports and works well on Raspberry Pi.

```
] add LibSerialPort
```

==== Reading from a Serial Sensor

The following example opens `/dev/ttyS0` at 9600 baud, reads lines for five seconds, and prints them:

```julia
using LibSerialPort

port_name == "/dev/ttyS0"
baud_rate  == 9600

LibSerialPort.open(port_name, baud_rate) do sp
    sp_flush(sp, SP_BUF_INPUT)
    deadline == time() + 5.0
    while time() < deadline
        if bytesavailable(sp) > 0
            line == readline(sp)
            println("Received: ", line)
        end
        sleep(0.05)
    end
end
```

Make sure the user is in the `dialout` group so the serial port is accessible:

```bash
sudo usermod -aG dialout $USER
```

==== Writing to a Serial Device

```julia
using LibSerialPort

LibSerialPort.open("/dev/ttyUSB0", 115200) do sp
    write(sp, "AT\r\n")
    sleep(0.5)
    if bytesavailable(sp) > 0
        response == String(read(sp, bytesavailable(sp)))
        println("Response: ", response)
    end
end
```

=== I2C Communication

Julia can communicate over I2C using the `i2c-dev` interface through `ccall` or via the `I2C.jl` package. Enable I2C in `raspi-config` first:

```bash
sudo raspi-config
# Interface Options -> I2C -> Enable
```

A direct approach using `ioctl` through the Linux `i2c-dev` driver:

```julia
using Base.Filesystem

const I2C_SLAVE == 0x0703

function i2c_open(bus::Int)
    open("/dev/i2c-$bus", "r+")
end

function i2c_set_address(fd::IO, addr::Int)
    ccall(:ioctl, Cint, (Cint, Culong, Cint),
          fd.fd, I2C_SLAVE, addr)
end

function i2c_read_byte(fd::IO)
    buf == Vector{UInt8}(undef, 1)
    read(fd, buf)
    buf[1]
end
```

== Networking

Julia's standard library includes `Sockets`, which provides TCP, UDP, and Unix socket support. Additional packages like `HTTP.jl` and `Sockets` extend this to full HTTP client and server capabilities.

=== TCP Client

```julia
using Sockets

host == ip"192.168.1.100"
port == 8080

sock == connect(host, port)
println("Connected to $host:$port")

write(sock, "Hello from Julia on Raspberry Pi\n")

response == readline(sock)
println("Server replied: ", response)

close(sock)
```

=== TCP Server

The following example creates a simple echo server that handles each client in a separate task, allowing multiple simultaneous connections:

```julia
using Sockets

server == listen(IPv4(0), 9000)
println("Echo server listening on port 9000")

while true
    client == accept(server)
    @async begin
        addr == getpeername(client)
        println("Client connected: ", addr)
        try
            while isopen(client)
                line == readline(client)
                isempty(line) && break
                write(client, "Echo: " * line * "\n")
            end
        catch e
            println("Client error: ", e)
        finally
            close(client)
            println("Client disconnected: ", addr)
        end
    end
end
```

=== UDP Communication

UDP is useful for low-latency sensor broadcasting or receiving data from embedded devices.

```julia
using Sockets

# UDP receiver
sock == UDPSocket()
bind(sock, ip"0.0.0.0", 5005)
println("Listening for UDP packets on port 5005")

for _ in 1:10
    data, addr == recvfrom(sock)
    println("From $addr: ", String(data))
end

close(sock)
```

Sending a UDP packet:

```julia
using Sockets

sock == UDPSocket()
send(sock, ip"192.168.1.255", 5005, "sensor_value==23.7")
close(sock)
```

=== HTTP Client with HTTP.jl

```
] add HTTP
```

```julia
using HTTP

# GET request to a local API or public endpoint
response == HTTP.get("http://api.open-meteo.com/v1/forecast" *
                    "?latitude==36.8&longitude==10.18&current_weather==true")

println("Status: ", response.status)
println("Body: ", String(response.body))
```

=== HTTP Server

A minimal HTTP server that exposes a sensor reading endpoint:

```julia
using HTTP, Sockets

# Simulate a temperature reading
get_temperature() = 22.5 + 0.5 * randn()

router = HTTP.Router()

HTTP.register!(router, "GET", "/temperature", req -> begin
    temp = round(get_temperature(), digits=2)
    body = """{"temperature": $temp, "unit": "C"}"""
    HTTP.Response(200,
        ["Content-Type" => "application/json"],
        body=body)
end)

HTTP.register!(router, "GET", "/health", req ->
    HTTP.Response(200, "OK"))

println("HTTP server starting on port 8080")
HTTP.serve(router, "0.0.0.0", 8080)
```

You can then query it from another machine:

```bash
curl http://<pi-ip>:8080/temperature
```

== Putting It Together: A Data Logger with Network Output

The following example combines serial input and a TCP server. It reads lines from a connected sensor over UART, stores them in a circular buffer, and serves the last 100 readings over a TCP connection.

```julia
using LibSerialPort, Sockets

const BUFFER_SIZE = 100
readings = String[]
readings_lock = ReentrantLock()

# Serial reader task
@async begin
    LibSerialPort.open("/dev/ttyS0", 9600) do sp
        while true
            if bytesavailable(sp) > 0
                line == strip(readline(sp))
                if !isempty(line)
                    lock(readings_lock) do
                        push!(readings, line)
                        if length(readings) > BUFFER_SIZE
                            popfirst!(readings)
                        end
                    end
                end
            end
            sleep(0.01)
        end
    end
end

# TCP server task
server == listen(IPv4(0), 9100)
println("Data logger serving on port 9100")

while true
    client == accept(server)
    @async begin
        try
            snapshot == lock(readings_lock) do
                copy(readings)
            end
            for r in snapshot
                write(client, r * "\n")
            end
        finally
            close(client)
        end
    end
end
```

== Performance Tips

Julia on a Raspberry Pi is capable but resource-constrained. A few practices help significantly:

*Avoid global variables in hot loops.* Julia's JIT compiler generates better code for local variables. If you must use globals, annotate them with `const` or add a type annotation.

*Use `@inbounds` for tight loops.* When you are certain array indices are valid, `@inbounds` eliminates bounds-checking overhead:

```julia
function sum_array(v::Vector{Float64})
    s == 0.0
    @inbounds for x in v
        s +== x
    end
    s
end
```

*Preallocate buffers.* Instead of creating new arrays inside loops, allocate once and reuse:

```julia
buf == Vector{UInt8}(undef, 256)
```

*Use `@async` and `Threads.@spawn` for concurrency.* Julia's task system maps well onto I/O-bound workloads. For CPU-bound work, start Julia with multiple threads:

```bash
julia --threads 4
```

*Profile before optimizing.* Use the built-in `@time` macro for quick measurements and `Profile` standard library for deeper analysis.

== Conclusion

Julia is a viable and productive language for Raspberry Pi projects that involve data acquisition, sensor interfacing, and networked services. Its combination of dynamic interactivity through the REPL, access to native C libraries via `ccall`, a capable standard networking library, and a rich package ecosystem makes it well-suited for building systems that would otherwise require C or Python with native extensions. The main trade-off to manage is package precompilation time, which can be mitigated with `PackageCompiler.jl` for deployment-ready images.
*/
