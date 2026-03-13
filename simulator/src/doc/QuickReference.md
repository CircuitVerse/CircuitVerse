# CircuitVerse Quick Reference

## ⚡ Keyboard Shortcuts

### General Operations
| Shortcut | Action |
|----------|--------|
| `Ctrl + N` | New Circuit |
| `Ctrl + O` | Open Circuit |
| `Ctrl + S` | Save Circuit |
| `Ctrl + Z` | Undo |
| `Ctrl + Y` | Redo |
| `Ctrl + C` | Copy Element |
| `Ctrl + V` | Paste Element |
| `Ctrl + A` | Select All |
| `Delete` | Delete Selected |
| `Escape` | Cancel Current Operation |

### View Controls
| Shortcut | Action |
|----------|--------|
| `Space` | Play/Pause Simulation |
| `R` | Rotate Selected Element |
| `F` | Flip Selected Element |
| `G` | Toggle Grid |
| `+` | Zoom In |
| `-` | Zoom Out |
| `0` | Reset Zoom |

### Simulation
| Shortcut | Action |
|----------|--------|
| `Enter` | Step Simulation |
| `T` | Step Mode Toggle |
| `Ctrl + R` | Reset Simulation |

---

## 🎨 Element Categories

### 🔌 Input/Output Elements
| Element | Purpose | Bit Width | Description |
|---------|----------|------------|-------------|
| **Input** | Manual input | 1-32 | Toggle switch for manual control |
| **Output** | Signal display | 1-32 | Visual indicator for signal state |
| **Button** | Momentary input | 1-32 | Press button for pulse input |

### 🧮 Logic Gates
| Element | Truth Table | Inputs | Symbol |
|---------|-------------|--------|--------|
| **AND** | Output = A·B·C... | 2-8 | ![AND] |
| **OR** | Output = A+B+C... | 2-8 | ![OR] |
| **NOT** | Output = ¬A | 1 | ![NOT] |
| **NAND** | Output = ¬(A·B·C...) | 2-8 | ![NAND] |
| **NOR** | Output = ¬(A+B+C...) | 2-8 | ![NOR] |
| **XOR** | Output = A⊕B⊕C... | 2-8 | ![XOR] |
| **XNOR** | Output = ¬(A⊕B⊕C...) | 2-8 | ![XNOR] |

### 📊 Display Elements
| Element | Display Type | Input | Description |
|---------|---------------|--------|-------------|
| **7-Segment** | Decimal digits (0-9) | 4-bit BCD | 7-segment LED display |
| **Hex Display** | Hexadecimal (0-F) | 4-bit | Hex digit display |
| **RGB LED** | Color mixing | 3×1-bit | Red, Green, Blue channels |
| **Digital LED** | On/Off | 1-bit | Simple LED indicator |

### ➕ Arithmetic Elements
| Element | Operation | Bit Width | Description |
|---------|------------|------------|-------------|
| **Adder** | A + B | 1-32 | Binary addition with carry |
| **ALU** | Multiple ops | 1-32 | Arithmetic Logic Unit |
| **Multiplier** | A × B | 1-32 | Binary multiplication |
| **Divider** | A ÷ B | 1-32 | Binary division |

### 🔄 Sequential Elements
| Element | Function | Clock | Description |
|---------|-----------|--------|-------------|
| **Counter** | Counting | Required | Up/down counter |
| **Flip-Flop** | Memory | Required | 1-bit storage |
| **Register** | Storage | Required | Multi-bit storage |

### 🔀 Multiplexing Elements
| Element | Function | Select Lines | Description |
|---------|-----------|--------------|-------------|
| **Multiplexer** | Select input | log₂(n) | n-to-1 selector |
| **Demultiplexer** | Route output | log₂(n) | 1-to-n distributor |
| **Decoder** | Decode binary | log₂(n) | n-line decoder |
| **Encoder** | Encode binary | log₂(n) | n-line encoder |

### 🛠 Utility Elements
| Element | Function | Description |
|---------|-----------|-------------|
| **Splitter** | Separate bits | Split multi-bit signal |
| **Buffer** | Signal buffer | Strengthen signal |
| **Constant** | Fixed value | VCC/GND source |
| **Tunnel** | Invisible wire | Long-distance connection |
| **Bit Selector** | Extract bits | Select bit range |

---

## 🔌 Truth Tables

### Basic Gates

#### AND Gate
| A | B | A·B |
|---|---|------|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

#### OR Gate
| A | B | A+B |
|---|---|------|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

#### NOT Gate
| A | ¬A |
|---|----|
| 0 | 1 |
| 1 | 0 |

#### XOR Gate
| A | B | A⊕B |
|---|---|------|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

### Common Combinations

#### Half Adder
| A | B | Sum | Carry |
|---|---|-----|-------|
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

#### 2-to-1 MUX
| Sel | In0 | In1 | Out |
|-----|-----|-----|-----|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

---

## 🎯 Common Circuit Patterns

### 1-Bit Full Adder
```
      A ──────┐
               │
      B ──────┼───► Sum
               │
      Cin ─────┘
               │
               └───► Cout
```
**Elements needed:** 2 XOR, 2 AND, 1 OR

### SR Latch (NOR)
```
      S ──┐
           │
           ├─► Q
      R ──┘
           │
           └─► ¬Q
```
**Elements needed:** 2 NOR gates

### 4-to-1 MUX
```
In0 ──┐
In1 ──┼───┐
In2 ──┼───┼───► Out
In3 ──┘   │
           │
      S1,S0 ──┘
```
**Elements needed:** 1 4-to-1 MUX

---

## 🔧 Design Formulas

### Boolean Algebra
- **Identity:** A·1 = A, A+0 = A
- **Complement:** A·¬A = 0, A+¬A = 1
- **Idempotent:** A·A = A, A+A = A
- **Commutative:** A·B = B·A, A+B = B+A
- **Associative:** (A·B)·C = A·(B·C)
- **Distributive:** A·(B+C) = A·B + A·C
- **De Morgan:** ¬(A·B) = ¬A + ¬B, ¬(A+B) = ¬A·¬B

### Number Systems
- **Binary to Decimal:** Σ(bit × 2^position)
- **Decimal to Binary:** Repeated division by 2
- **Hex to Binary:** 4 bits per hex digit
- **BCD to 7-Segment:** Specific segment patterns

---

## 🚨 Error Messages

### Connection Errors
| Error | Cause | Solution |
|--------|--------|----------|
| "Cannot connect" | Incompatible types | Check bit widths |
| "Multiple drivers" | Two outputs to one input | Use buffer or MUX |
| "Floating input" | Unconnected input | Connect to known state |

### Simulation Errors
| Error | Cause | Solution |
|--------|--------|----------|
| "Oscillation" | Feedback loop | Add delay or register |
| "Conflict" | Signal contention | Check connections |
| "Setup violation" | Timing issue | Adjust clock timing |

---

## 📊 Bit Width Reference

### Common Widths
| Width | Range | Common Uses |
|-------|--------|--------------|
| 1-bit | 0-1 | Boolean values, flags |
| 4-bit | 0-15 | BCD digits, hex digits |
| 8-bit | 0-255 | ASCII characters, bytes |
| 16-bit | 0-65535 | Memory addresses, integers |
| 32-bit | 0-4294967295 | Modern integers |

### Conversion Examples
- **4-bit to Hex:** Group bits in fours
- **8-bit to Decimal:** 128·b7 + 64·b6 + ... + 1·b0
- **BCD to 7-Segment:** Specific segment mapping
- **Gray Code:** Binary reflected Gray code

---

## 🎨 Color Coding

### Wire Colors
| Color | Signal Type | Description |
|--------|-------------|-------------|
| Green | HIGH/1 | Logic high signal |
| Red | LOW/0 | Logic low signal |
| Blue | Clock | Timing signal |
| Yellow | Bus | Multi-bit signal |
| Purple | Unknown | Uninitialized signal |

### Element Colors
| Color | Element Type | Examples |
|--------|--------------|----------|
| Light Blue | Input elements | Input, Button |
| Light Green | Output elements | Output, LED, Display |
| Light Yellow | Logic gates | AND, OR, NOT, etc. |
| Light Orange | Arithmetic | Adder, ALU, Multiplier |
| Light Purple | Sequential | Counter, Flip-flop |
| Light Gray | Utility | Buffer, Splitter, Tunnel |

---

## ⚡ Performance Tips

### Optimization
1. **Minimize Gate Count:** Use universal gates efficiently
2. **Reduce Propagation Delay:** Balance path lengths
3. **Optimize Layout:** Group related elements
4. **Use Standard Cells**: Reuse proven patterns
5. **Consider Bit Width**: Use minimum required width

### Debugging
1. **Add Probes:** Temporary outputs for monitoring
2. **Step Simulation:** Observe behavior cycle by cycle
3. **Isolate Sections:** Test subcircuits independently
4. **Check Timing**: Verify setup/hold times
5. **Verify Truth Tables**: Test all input combinations

---

## 🔗 Quick Links

### Documentation
- **[Full Element Reference](./CircuitElements.md)** - Complete element documentation
- **[Getting Started Guide](./GettingStarted.md)** - Beginner tutorial
- **[Verilog Export](./Circuit2Verilog%20documentation.md)** - Code generation

### External Resources
- **[CircuitVerse.org](https://circuitverse.org/)** - Main application
- **[GitHub Repository](https://github.com/CircuitVerse/CircuitVerse)** - Source code
- **[Community Forum](https://github.com/CircuitVerse/CircuitVerse/discussions)** - Help and discussion

### Learning Materials
- **[Digital Logic Tutorials](https://www.electronics-tutorials.ws/digital/)** - Comprehensive tutorials
- **[Logic Gate Reference](https://en.wikipedia.org/wiki/Logic_gate)** - Theoretical background
- **[Circuit Simulation](https://www.falstad.com/circuit/)** - Additional simulator

---

## 📝 Quick Notes

This section is for your personal notes and frequently used patterns:

```
My Common Circuits:
- 4-bit adder: 2 XOR, 2 AND, 1 OR
- 2-to-4 decoder: 2 NOT, 4 AND
- D flip-flop: 4 NAND gates
- 4-bit counter: 4 T flip-flops

Useful Formulas:
- NAND implementation: ¬(A·B) = ¬A + ¬B
- XOR from NAND: (A·¬B) + (¬A·B)
- Half adder: Sum = A⊕B, Carry = A·B
```

---

**🎯 Keep this reference handy while building circuits!**

*Last updated: 2024 - CircuitVerse Documentation Team*
