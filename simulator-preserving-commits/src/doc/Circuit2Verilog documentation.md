## Circuit2Verilog Module

**Primary Contributors:**

1. James H - J Yeh, Ph.D.
2. Satvik Ramaprasad

## Introduction

This is an experimental module that generates Verilog netlist (structural
Verilog) given the circuit. Currently, the module generates fully functional
Verilog code for basic circuits. For a complex circuit, additional (manual) work
may need to be done in order to make it work. We are continuously improving this
module to work with more and more complex circuits.

# Algorithm

The basic algorithm is fairly straightforward. We have the circuit graph in
memory. We just need to convert this graph into Verilog netlist. It is done by
performing a DFS on the circuit graph. The DFS involves the following steps

1. Creating Verilog wires as and when required
2. Connecting Verilog wires in element instantiations

## Some background information

The different sub-circuits form a DAG (Directed Acyclic Graph) or dependency
graph. Each sub-circuit itself (called scope internally) is actually a (cyclic)
graph on its own. Therefore the Verilog generation is done in a 2 step DFS
approach. The first DFS is performed on the dependency graph. The second DFS is
done on an individual sub-circuit (scope).

## Code/Algorithm workflow

1. `exportVerilog()` - entry point
2. `exportVerilogScope()` - DFS(1) on Sub Circuits Dependency Graph
   1. Set Verilog Labels for all elements
   2. `generateHeader()` - Generates Module Header
   3. `generateOutputList()` - Output Output List
   4. `generateInputList()` - Generates Input List
   5. `processGraph()` - DFS(2) on individual subcircuit/scope
      1. DFS starts from inputs
      2. Calls `processVerilog()` on all circuit elements (graph nodes) - resolves label names and adds neighbors to DFS stack.
      3. Calls `generateVerilog()` on all circuit elements to get the final Verilog.
   6. Generate Wire initializations

## Functions

**Verilog Module Functions:**

1. `verilog.exportVerilog()` - Entry point
1. `verilog.exportVerilogScope()` - Recursive DFS function on subcircuit graph
1. `verilog.processGraph()` - Iterative DFS function on subcircuit scope
1. `verilog.resetLabels()` - Resets labels in scope
1. `verilog.setLabels()` - Sets labels in scope
1. `verilog.generateHeader()` - Generates Verilog Module Header
1. `verilog.generateInputList()` - Generates Verilog Module Input List
1. `verilog.generateOutputList()` - Generates Verilog Module Output List
1. `sanitizeLabel()` - Sanitizes label for node/wire
1. `verilog.generateNodeName()` - Helper function to resolve node/wire name

**CircuitElement Functions:**

These functions can be overridden by derived classes.

1. `CircuitElement.prototype.processVerilog()` - Graph algorithm to resolve Verilog wire labels
1. `CircuitElement.prototype.verilogName()` - Generate Verilog name
1. `CircuitElement.prototype.generateVerilog()` - Generate final Verilog code
1. `CircuitElement.prototype.verilogType` - Verilog type name
1. `CircuitElement.moduleVerilog` - Custom module Verilog for elements
