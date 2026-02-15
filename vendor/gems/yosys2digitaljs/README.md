# Yosys2Digitaljs Ruby Gem

A pure Ruby port of the [`yosys2digitaljs`](https://github.com/tilk/yosys2digitaljs) compiler. It runs Yosys on Verilog code and converts the resulting netlist into a DigitalJS-compatible JSON format.

## Architecture Change
> [!NOTE]
> This repository was formerly a Node.js microservice. As of v1.0.0, it is a **Ruby Gem**.
> It is designed to be bundled directly into your Rails application (CircuitVerse), eliminating the need for a separate sidecar service.

## Requirements
*   **Ruby** 3.0+
*   **Yosys**: The `yosys` binary must be in your system PATH (or Docker container).
    *   Ubuntu: `sudo apt-get install yosys`

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'yosys2digitaljs', path: 'vendor/gems/yosys2digitaljs'
```

And then execute:

```bash
bundle install
```

## Usage

```ruby
require 'yosys2digitaljs'

verilog_code = <<~VERILOG
  module top(input a, output y);
    assign y = ~a;
  endmodule
VERILOG

# Compile to DigitalJS JSON
# Returns a Hash (ready for JSON.generate)
circuit_json = Yosys2Digitaljs::Runner.compile(verilog_code)

puts JSON.pretty_generate(circuit_json)
```

## Development

### Running Tests
The project includes a comprehensive test suite of 17 SystemVerilog fixtures ported from the original project.

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rspec
```

### Docker
A `Dockerfile` is provided for containerized testing.

```bash
docker build -t yosys-ruby .
docker run --rm yosys-ruby
```

## License
BSD-2-Clause
