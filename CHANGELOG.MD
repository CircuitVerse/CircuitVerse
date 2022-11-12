## [Unreleased]

## [release-004] - 2022-11-11

### [Added]

- [Task 007] : (helperVHDL.js) Add generateLogicDecoder function
- [Task 007] : (Decoder.js) Add ModuleVHDL, generateVHDL and generatePortMapVHDL functions
- [Task 007] : (circuitElement.js) Create generateVHDL to Decoder circuit.
- [Task 007] : (vhdl.js) Add conditional call to function generateVHDL of decoder.
- [Task 006] : (CircuitElement.js) Refactoring generateVHDL and generatePortMap functions.
- [Task 006] : (Demultiplexer.js) Refactoring generateVHDL function.
- [Task 006] : (Multiplexer.js) Refactoring generateVHDL function.
- [Task 006] : (helperVHDL.js) Add functions to generate vhdl code.
- [Task 005] : (BitSelector.js) Add generateVHDL function.
- [Task 005] : (circuitElement.js) Add PROCESS conditional after portmap.
- [Task 005] : (vhdl.js) Add error bitwidth and PROCESS conditional.
- [Task 004] : (BitSelector.js) Add generateVHDL function.

### [Changed]

- [Task 004] : (vhdl.js) Add conditional to import ieee Math library.
- [Task 007] : (Demultiplexer.js) Change generatecomponent in to in0

## [release-003] - 2022-10-18

### [Added]

- [Task 003] : (Demultiplexer.js) Add ModuleVHDL, generateVHDL and generatePortMapVHDL functions
- [Task 003] : (circuitElement.js) Create generateVHDL to Demultiplexer circuit.
- [Task 003] : (vhdl.js) Add conditional call to function generateVHDL of mux and demux.

## [release-002] - 2022-10-11

### [Added]

- [Task 002] : (Multiplexer.js) Add ModuleVHDL and generateVHDL functions
- [Task 002] : (circuitElement.js) Create generateVHDL to Multiplexer circuit.
- [Task 002] : (vhdl.js) Change moduleVerilog to moduleVHDL, add VHDLSet.
- [Task 002] : (util.js) Indent outputs vhdl.

## [release-001] - 2022-09-22

### [Added]
- [Task 001] : (vhdl.js) Create vhdl.js file.

### [Changed]

- [Task 001] : (AndGate.js, NandGate.js, NorGate.js, NotGate.js, OrGate.js, Output.js, XnorGate.js, XorGate.js) Add generateVHDL function.
- [Task 001] : (data.js) Import generateVHDL function
- [Task 001] : (utils.js) Add gateGenerateVerilog function
- [Task 001] : (ux.js) Add setupVHDLExportCodeWindow function
