# CircuitVerse Circuit Elements Documentation

## Overview

This document provides comprehensive documentation for all circuit elements available in CircuitVerse. Each element includes its purpose, truth table (if applicable), usage examples, and further reading resources.

---

## Logic Gates

### AND Gate

**Purpose:** Performs logical AND operation on all inputs. Output is HIGH only when all inputs are HIGH.

**Truth Table (2-input):**

| Input A | Input B | Output |
|----------|----------|--------|
| 0        | 0        | 0      |
| 0        | 1        | 0      |
| 1        | 0        | 0      |
| 1        | 1        | 1      |

**Usage:**
```javascript
// Create 2-input AND gate
const andGate = new AndGate(x, y, scope, "RIGHT", 2, 1);

// Create 4-input AND gate
const andGate4 = new AndGate(x, y, scope, "RIGHT", 4, 1);
```

**Common Uses:**
- Enable/disable circuits
- Conditional logic
- Address decoding
- Safety interlocks

**Further Reading:**
- [AND Gate Wikipedia](https://en.wikipedia.org/wiki/AND_gate)
- [Digital Logic Gates Tutorial](https://www.electronics-tutorials.ws/logic/logic-gates.html)

---

### OR Gate

**Purpose:** Performs logical OR operation on all inputs. Output is HIGH when any input is HIGH.

**Truth Table (2-input):**

| Input A | Input B | Output |
|----------|----------|--------|
| 0        | 0        | 0      |
| 0        | 1        | 1      |
| 1        | 0        | 1      |
| 1        | 1        | 1      |

**Usage:**
```javascript
// Create 2-input OR gate
const orGate = new OrGate(x, y, scope, "RIGHT", 2, 1);

// Create 3-input OR gate
const orGate3 = new OrGate(x, y, scope, "RIGHT", 3, 1);
```

**Common Uses:**
- Alarm systems
- Interrupt handling
- Data bus control
- Error detection

**Further Reading:**
- [OR Gate Wikipedia](https://en.wikipedia.org/wiki/OR_gate)
- [Logic Gate Families](https://www.allaboutcircuits.com/textbook/digital/chpt-3/)

---

### NOT Gate (Inverter)

**Purpose:** Inverts the input signal. Output is opposite of input.

**Truth Table:**

| Input | Output |
|-------|--------|
| 0     | 1      |
| 1     | 0      |

**Usage:**
```javascript
// Create NOT gate
const notGate = new NotGate(x, y, scope, "RIGHT", 1);
```

**Common Uses:**
- Signal conditioning
- Logic level conversion
- Clock signal inversion
- Enable/disable control

**Further Reading:**
- [NOT Gate Wikipedia](https://en.wikipedia.org/wiki/NOT_gate)
- [Inverter Circuits](https://www.electronics-tutorials.ws/logic/not-gate.html)

---

### NAND Gate

**Purpose:** Performs logical AND operation followed by NOT. Output is LOW only when all inputs are HIGH.

**Truth Table (2-input):**

| Input A | Input B | Output |
|----------|----------|--------|
| 0        | 0        | 1      |
| 0        | 1        | 1      |
| 1        | 0        | 1      |
| 1        | 1        | 0      |

**Usage:**
```javascript
// Create 2-input NAND gate
const nandGate = new NandGate(x, y, scope, "RIGHT", 2, 1);
```

**Common Uses:**
- Universal gate (can create any logic function)
- Memory circuits
- Flip-flops
- Simple logic implementations

**Further Reading:**
- [NAND Gate Wikipedia](https://en.wikipedia.org/wiki/NAND_gate)
- [Universal Logic Gates](https://www.allaboutcircuits.com/textbook/digital/chpt-5/)

---

### NOR Gate

**Purpose:** Performs logical OR operation followed by NOT. Output is HIGH only when all inputs are LOW.

**Truth Table (2-input):**

| Input A | Input B | Output |
|----------|----------|--------|
| 0        | 0        | 1      |
| 0        | 1        | 0      |
| 1        | 0        | 0      |
| 1        | 1        | 0      |

**Usage:**
```javascript
// Create 2-input NOR gate
const norGate = new NorGate(x, y, scope, "RIGHT", 2, 1);
```

**Common Uses:**
- Universal gate
- Memory circuits
- Signal gating
- Simple logic implementations

**Further Reading:**
- [NOR Gate Wikipedia](https://en.wikipedia.org/wiki/NOR_gate)
- [Universal Gates Tutorial](https://www.electronics-tutorials.ws/logic/universal-gates.html)

---

### XOR Gate

**Purpose:** Performs exclusive OR operation. Output is HIGH when inputs are different.

**Truth Table (2-input):**

| Input A | Input B | Output |
|----------|----------|--------|
| 0        | 0        | 0      |
| 0        | 1        | 1      |
| 1        | 0        | 1      |
| 1        | 1        | 0      |

**Usage:**
```javascript
// Create 2-input XOR gate
const xorGate = new XorGate(x, y, scope, "RIGHT", 2, 1);
```

**Common Uses:**
- Binary addition
- Error detection
- Data comparison
- Parity generation

**Further Reading:**
- [XOR Gate Wikipedia](https://en.wikipedia.org/wiki/XOR_gate)
- [Binary Arithmetic](https://www.electronics-tutorials.ws/combinational/comb_4.html)

---

### XNOR Gate

**Purpose:** Performs exclusive OR operation followed by NOT. Output is HIGH when inputs are the same.

**Truth Table (2-input):**

| Input A | Input B | Output |
|----------|----------|--------|
| 0        | 0        | 1      |
| 0        | 1        | 0      |
| 1        | 0        | 0      |
| 1        | 1        | 1      |

**Usage:**
```javascript
// Create 2-input XNOR gate
const xnorGate = new XnorGate(x, y, scope, "RIGHT", 2, 1);
```

**Common Uses:**
- Equality comparison
- Parity checking
- Control logic
- Data validation

**Further Reading:**
- [XNOR Gate Wikipedia](https://en.wikipedia.org/wiki/XNOR_gate)
- [Logic Comparison Circuits](https://www.allaboutcircuits.com/textbook/digital/chpt-8/)

---

## Input/Output Elements

### Input Element

**Purpose:** Provides manual input control for circuits. Can be toggled between HIGH and LOW states.

**Features:**
- Manual toggle control
- Configurable bit width
- Visual state indication
- Keyboard shortcuts support

**Usage:**
```javascript
// Create 1-bit input
const input = new Input(x, y, scope, "RIGHT", 1);

// Create 4-bit input
const input4 = new Input(x, y, scope, "RIGHT", 4);
```

**Common Uses:**
- Manual control signals
- Data input
- Circuit testing
- Interactive demonstrations

**Further Reading:**
- [Digital Input Devices](https://www.electronics-tutorials.ws/digital/digital-input.html)
- [Human-Machine Interface](https://en.wikipedia.org/wiki/Human–computer_interface)

---

### Output Element

**Purpose:** Displays the state of a signal visually. Shows HIGH/LOW states clearly.

**Features:**
- Visual state indication
- Configurable bit width
- Real-time updates
- Multiple display formats

**Usage:**
```javascript
// Create 1-bit output
const output = new Output(x, y, scope, "RIGHT", 1);

// Create 8-bit output
const output8 = new Output(x, y, scope, "RIGHT", 8);
```

**Common Uses:**
- Circuit monitoring
- Result display
- Debug output
- Status indication

**Further Reading:**
- [Digital Output Devices](https://www.electronics-tutorials.ws/digital/digital-output.html)
- [LED Display Systems](https://www.allaboutcircuits.com/projects/led-displays/)

---

### Button Element

**Purpose:** Provides momentary input control. Active only while pressed.

**Features:**
- Momentary action
- Configurable bit width
- Visual feedback
- Keyboard shortcuts

**Usage:**
```javascript
// Create 1-bit button
const button = new Button(x, y, scope, "RIGHT", 1);

// Create 4-bit button
const button4 = new Button(x, y, scope, "RIGHT", 4);
```

**Common Uses:**
- Clock signals
- Reset controls
- Pulse generation
- Interactive input

**Further Reading:**
- [Push Button Switches](https://www.electronics-tutorials.ws/io/input-devices.html)
- [Switch Debouncing](https://www.allaboutcircuits.com/textbook/digital/chpt-4/)

---

## Display Elements

### Seven Segment Display

**Purpose:** Displays decimal numbers (0-9) using 7 LED segments.

**Features:**
- 7-segment display
- BCD input (4-bit)
- Common anode/cathode
- Multiple display styles

**Truth Table (Segment Mapping):**

| Digit | a | b | c | d | e | f | g |
|-------|---|---|---|---|---|---|---|
| 0     | 1 | 1 | 1 | 1 | 1 | 1 | 0 |
| 1     | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| 2     | 1 | 1 | 0 | 1 | 1 | 0 | 1 |
| 3     | 1 | 1 | 1 | 1 | 0 | 0 | 1 |
| 4     | 0 | 1 | 1 | 0 | 0 | 1 | 1 |
| 5     | 1 | 0 | 1 | 1 | 0 | 1 | 1 |
| 6     | 1 | 0 | 1 | 1 | 1 | 1 | 1 |
| 7     | 1 | 1 | 1 | 0 | 0 | 0 | 0 |
| 8     | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 9     | 1 | 1 | 1 | 1 | 0 | 1 | 1 |

**Usage:**
```javascript
// Create 7-segment display
const display = new SevenSegDisplay(x, y, scope, "RIGHT", 1);
```

**Common Uses:**
- Digital clocks
- Counters
- Score displays
- Measurement devices

**Further Reading:**
- [Seven Segment Display](https://en.wikipedia.org/wiki/Seven-segment_display)
- [LED Display Tutorial](https://www.electronics-tutorials.ws/blog/7-segment-display-tutorial/)

---

### Hexadecimal Display

**Purpose:** Displays hexadecimal values (0-F) using 7-segment display.

**Features:**
- 16-character display (0-F, A-F)
- 4-bit input
- Multiple display styles
- Compact representation

**Usage:**
```javascript
// Create hex display
const hexDisplay = new HexDisplay(x, y, scope, "RIGHT", 1);
```

**Common Uses:**
- Address display
- Memory debugging
- Hexadecimal output
- Computer interface

**Further Reading:**
- [Hexadecimal System](https://en.wikipedia.org/wiki/Hexadecimal)
- [Digital Number Systems](https://www.electronics-tutorials.ws/binary/number-systems.html)

---

### RGB LED

**Purpose:** Multi-color LED with independent Red, Green, and Blue control.

**Features:**
- 3 independent color channels
- 8-bit per channel
- Color mixing
- Visual feedback

**Truth Table (Color Mixing):**

| Red | Green | Blue | Result |
|------|--------|-------|---------|
| 0    | 0      | 0     | Black   |
| 1    | 0      | 0     | Red     |
| 0    | 1      | 0     | Green   |
| 0    | 0      | 1     | Blue    |
| 1    | 1      | 0     | Yellow  |
| 1    | 0      | 1     | Magenta |
| 0    | 1      | 1     | Cyan    |
| 1    | 1      | 1     | White   |

**Usage:**
```javascript
// Create RGB LED
const rgbLed = new RGBLed(x, y, scope, "RIGHT", 1);
```

**Common Uses:**
- Status indication
- Color coding
- Visual feedback
- Decorative lighting

**Further Reading:**
- [RGB LED Tutorial](https://www.electronics-tutorials.ws/led/rgb-led.html)
- [Color Mixing](https://en.wikipedia.org/wiki/Additive_color)

---

## Arithmetic Elements

### Adder

**Purpose:** Performs binary addition of two numbers with carry output.

**Features:**
- Binary addition
- Carry output
- Configurable bit width
- Ripple carry architecture

**Truth Table (1-bit):**

| A | B | Cin | Sum | Cout |
|---|---|------|-----|------|
| 0 | 0 | 0    | 0   | 0    |
| 0 | 0 | 1    | 1   | 0    |
| 0 | 1 | 0    | 1   | 0    |
| 0 | 1 | 1    | 0   | 1    |
| 1 | 0 | 0    | 1   | 0    |
| 1 | 0 | 1    | 0   | 1    |
| 1 | 1 | 0    | 0   | 1    |
| 1 | 1 | 1    | 1   | 1    |

**Usage:**
```javascript
// Create 4-bit adder
const adder = new Adder(x, y, scope, "RIGHT", 4);
```

**Common Uses:**
- Arithmetic operations
- Address calculation
- Counter circuits
- ALU design

**Further Reading:**
- [Binary Adder Circuit](https://en.wikipedia.org/wiki/Adder_(electronics))
- [Arithmetic Logic Unit](https://www.electronics-tutorials.ws/combination/comb_6.html)

---

### ALU (Arithmetic Logic Unit)

**Purpose:** Performs arithmetic and logical operations on binary numbers.

**Features:**
- Multiple operations (ADD, SUB, AND, OR, XOR)
- Configurable bit width
- Control inputs
- Status outputs

**Operations:**
- **ADD:** Arithmetic addition
- **SUB:** Arithmetic subtraction
- **AND:** Logical AND
- **OR:** Logical OR
- **XOR:** Logical XOR

**Usage:**
```javascript
// Create 8-bit ALU
const alu = new ALU(x, y, scope, "RIGHT", 8);
```

**Common Uses:**
- CPU design
- Data processing
- Mathematical operations
- Control systems

**Further Reading:**
- [ALU Wikipedia](https://en.wikipedia.org/wiki/Arithmetic_logic_unit)
- [Computer Architecture](https://www.electronics-tutorials.ws/combination/comb_6.html)

---

## Sequential Elements

### Counter

**Purpose:** Counts clock pulses and outputs binary count.

**Features:**
- Up/down counting
- Configurable bit width
- Synchronous/asynchronous
- Reset capability

**Usage:**
```javascript
// Create 4-bit counter
const counter = new Counter(x, y, scope, "RIGHT", 4);
```

**Common Uses:**
- Frequency division
- Event counting
- Address generation
- Timer circuits

**Further Reading:**
- [Digital Counter](https://en.wikipedia.org/wiki/Counter_(digital))
- [Sequential Logic](https://www.electronics-tutorials.ws/sequential/seq_1.html)

---

## Multiplexing Elements

### Multiplexer (MUX)

**Purpose:** Selects one of multiple input signals based on select lines.

**Features:**
- Multiple inputs
- Select lines
- Single output
- Configurable width

**Truth Table (2-to-1 MUX):**

| Select | Input 0 | Input 1 | Output |
|--------|----------|----------|--------|
| 0      | X        | 0        | 0      |
| 0      | X        | 1        | 1      |
| 1      | 0        | X        | 0      |
| 1      | 1        | X        | 1      |

**Usage:**
```javascript
// Create 4-to-1 multiplexer
const mux = new Multiplexer(x, y, scope, "RIGHT", 4, 1);
```

**Common Uses:**
- Data routing
- Bus switching
- Parallel-to-serial conversion
- Input selection

**Further Reading:**
- [Multiplexer Wikipedia](https://en.wikipedia.org/wiki/Multiplexer)
- [Data Routing](https://www.allaboutcircuits.com/textbook/digital/chpt-9/)

---

### Demultiplexer (DEMUX)

**Purpose:** Routes single input to one of multiple outputs based on select lines.

**Features:**
- Single input
- Select lines
- Multiple outputs
- Configurable width

**Usage:**
```javascript
// Create 1-to-4 demultiplexer
const demux = new Demultiplexer(x, y, scope, "RIGHT", 4, 1);
```

**Common Uses:**
- Data distribution
- Serial-to-parallel conversion
- Address decoding
- Output selection

**Further Reading:**
- [Demultiplexer Wikipedia](https://en.wikipedia.org/wiki/Demultiplexer)
- [Data Distribution](https://www.electronics-tutorials.ws/combination/comb_9.html)

---

## Utility Elements

### Splitter

**Purpose:** Splits a multi-bit signal into individual bits.

**Features:**
- Bit separation
- Configurable width
- Bidirectional
- Signal preservation

**Usage:**
```javascript
// Create 8-bit splitter
const splitter = new Splitter(x, y, scope, "RIGHT", 8);
```

**Common Uses:**
- Bit manipulation
- Signal routing
- Data processing
- Interface conversion

**Further Reading:**
- [Signal Splitting](https://www.electronics-tutorials.ws/combination/comb_3.html)
- [Digital Signal Processing](https://en.wikipedia.org/wiki/Digital_signal_processing)

---

### Buffer

**Purpose:** Provides signal isolation and drive strength.

**Features:**
- Signal buffering
- Logic level preservation
- Drive capability
- Noise immunity

**Truth Table:**

| Input | Output |
|-------|--------|
| 0     | 0      |
| 1     | 1      |

**Usage:**
```javascript
// Create buffer
const buffer = new Buffer(x, y, scope, "RIGHT", 1);
```

**Common Uses:**
- Signal conditioning
- Drive strengthening
- Bus isolation
- Interface matching

**Further Reading:**
- [Digital Buffer](https://en.wikipedia.org/wiki/Buffer_(electronics))
- [Logic Gate Families](https://www.allaboutcircuits.com/textbook/digital/chpt-3/)

---

### Constant Value

**Purpose:** Provides constant HIGH or LOW signal.

**Features:**
- Fixed output value
- Configurable bit width
- Power/ground options
- Reference signals

**Usage:**
```javascript
// Create constant HIGH
const vcc = new ConstantVal(x, y, scope, "RIGHT", 1, 1);

// Create constant LOW
const gnd = new ConstantVal(x, y, scope, "RIGHT", 1, 0);
```

**Common Uses:**
- Reference signals
- Power distribution
- Logic level setting
- Test signals

**Further Reading:**
- [Logic Levels](https://en.wikipedia.org/wiki/Logic_level)
- [Power Supply](https://www.electronics-tutorials.ws/digital/digital-logic-gates.html)

---

## Advanced Features

### Bit Selector

**Purpose:** Selects specific bits from multi-bit input.

**Features:**
- Bit selection
- Configurable range
- Multi-bit output
- Bit manipulation

**Usage:**
```javascript
// Create 8-bit selector
const selector = new BitSelector(x, y, scope, "RIGHT", 8);
```

**Common Uses:**
- Bit extraction
- Data manipulation
- Field selection
- Protocol processing

**Further Reading:**
- [Bit Manipulation](https://en.wikipedia.org/wiki/Bit_manipulation)
- [Data Structures](https://www.electronics-tutorials.ws/combination/comb_3.html)

---

### Tunnel

**Purpose:** Connects distant points without visible wires.

**Features:**
- Invisible connection
- Long-distance routing
- Circuit organization
- Visual cleanup

**Usage:**
```javascript
// Create tunnel
const tunnel = new Tunnel(x, y, scope, "RIGHT", 1);
```

**Common Uses:**
- Circuit organization
- Long connections
- Visual simplification
- Signal routing

**Further Reading:**
- [Circuit Layout](https://en.wikipedia.org/wiki/Electronic_circuit_design)
- [PCB Design](https://www.allaboutcircuits.com/textbook/digital/chpt-12/)

---

## Getting Started

### Basic Circuit Creation

1. **Add Input Elements:** Start with Input elements for manual control
2. **Add Logic Gates:** Connect gates to implement desired logic
3. **Add Output Elements:** Use Output elements to see results
4. **Connect Elements:** Click and drag between connection points
5. **Test Circuit:** Use the simulation to verify functionality

### Tips for Beginners

- **Start Simple:** Begin with basic gates and gradually add complexity
- **Use Labels:** Name important signals for clarity
- **Test Incrementally:** Verify each section before adding more
- **Save Often:** Keep backups of working circuits
- **Use Documentation:** Refer to this guide for element details

### Common Patterns

- **Debouncing:** Use flip-flops for clean button inputs
- **State Machines:** Combine logic and memory elements
- **Arithmetic:** Use dedicated arithmetic elements
- **Multiplexing:** Route signals efficiently with MUX/DEMUX

---

## Troubleshooting

### Common Issues

1. **Floating Inputs:** Always connect unused inputs to known states
2. **Race Conditions:** Use proper clock distribution
3. **Signal Integrity:** Use buffers for long connections
4. **Power Distribution:** Ensure proper power/ground connections

### Debug Techniques

1. **Probe Signals:** Use Output elements to monitor intermediate values
2. **Step Simulation:** Use slow simulation to observe behavior
3. **Isolate Sections:** Test circuit sections independently
4. **Check Connections:** Verify all connections are correct

---

## Resources

### Learning Materials

- **[Digital Logic Tutorial](https://www.electronics-tutorials.ws/digital/)**
- **[CircuitVerse Tutorials](https://circuitverse.org/tutorials)**
- **[Logic Design Course](https://www.coursera.org/learn/digital-systems)**

### Reference Materials

- **[IEEE Standards](https://standards.ieee.org/)**
- **[Digital Design Books](https://en.wikipedia.org/wiki/Digital_electronics)**
- **[Circuit Analysis Tools](https://www.falstad.com/circuit/)**

### Community

- **[CircuitVerse Forum](https://github.com/CircuitVerse/CircuitVerse/discussions)**
- **[Stack Exchange](https://electronics.stackexchange.com/)**
- **[Reddit r/Electronics](https://www.reddit.com/r/electronics/)**

---

## Conclusion

This documentation provides a comprehensive reference for all CircuitVerse elements. As you explore digital logic design, refer back to this guide for element specifications, usage examples, and best practices.

Remember that digital logic design is both an art and a science - practice regularly, experiment with different approaches, and don't hesitate to consult the community when you encounter challenges.

Happy circuit building! 🚀
