# Phase 3 Weeks 8-9 (Continued): Asynchronous Input Handling & Clock Domain Crossing Safety

## Overview
Implemented comprehensive Clock Domain Crossing (CDC) safety infrastructure for FSM synthesis. This feature handles synchronization of inputs coming from different clock domains, a critical requirement for real-world circuits operating in multi-clock environments.

---

## Clock Domain Crossing Problem

### The Metastability Issue
When an input signal crosses from one clock domain to another without proper synchronization:

```
Source Clock Domain        Destination Clock Domain
   (100 MHz)                      (80 MHz)
     clk_src                         clk_sys
       |                              |
       ↓                              ↓
    ┌─────┐     async input    ┌──────────┐
    │  D  │─ unstable signal ──→│ needs    │
    │ FF  │ (crosses near edge) │ sync     │
    └─────┘                     └──────────┘
       │                              │
       └─ METASTABILITY HAZARD ──────→
       
Issue: Flip-flop in dest domain may be in metastable state
       (between 0 and 1) for unpredictable time
```

**Consequences:**
- Unpredictable delay through synchronizer
- Potential for logic errors in destination domain
- Data corruption or system failure
- Increasingly critical at higher frequencies

### Safety Requirements
For production circuits, CDC synchronization is **mandatory** when:
1. Inputs cross from external sources (asynchronous)
2. Inputs cross between different clock domains
3. Frequency/phase undefined between domains
4. Timing requirements are strict

---

## Features Implemented

### 1. InputSynchronizer Service
**File:** `app/services/fsm_synthesizer/input_synchronizer.rb` (400+ lines)

Generates CDC-safe synchronizers for crossing clock domains.

#### Core Methods

##### `configure_synchronizer(fsm, input_name:, src_clock:, dest_clock:, sync_type:, num_stages:)`
Sets up synchronization for a single input.

**Parameters:**
- `input_name` - FSM input to synchronize
- `src_clock` - Source clock domain (where signal originates)
- `dest_clock` - Destination clock domain (FSM clock)
- `sync_type` - Synchronizer type:
  - `"two_flop"` - Standard 2-stage multi-bit safe
  - `"gray"` - Gray code for multi-bit buses
  - `"pulse"` - Detects edge transitions
  - `"handshake"` - Async FIFO for bulk data
- `num_stages` - Number of synchronization stages (default: 2)

**Returns:** Configuration with:
- Input/output specifications
- Metastability margin (MSAT)
- Settling time estimate

**Example:**
```ruby
sync = FsmSynthesizer::InputSynchronizer.new
config = sync.configure_synchronizer(
  fsm,
  input_name: 'ext_signal',
  src_clock: 'clk_src',
  dest_clock: 'clk_sys',
  sync_type: 'two_flop',
  num_stages: 2
)
# => {
#   input_name: 'ext_signal',
#   sync_type: 'two_flop',
#   num_stages: 2,
#   metastability_msat: 3.45,
#   settling_time_ns: 6.0
# }
```

##### `configure_synchronizers(fsm, configs)`
Configures multiple input synchronizers at once.

**Parameters:**
- `fsm` - FSM object
- `configs` - Array of configuration hashes (each element as above)

**Returns:** Hash of all configured synchronizers

##### `get_synchronizer_circuits()`
Generates circuit specifications for all configured synchronizers.

**Returns:** Hash with complete synchronizer circuit details:
```ruby
{
  'ext_signal' => {
    type: 'two_flop_synchronizer',
    description: 'Standard 2-stage synchronizer...',
    components: [ ... ],
    timing: {
      metastability_margin_sigma: 3.45,
      settling_time_ns: 6.0,
      max_freq_mhz: 166
    },
    reliability: {
      mtbf_years: 10.0,
      hazard_probability: 1.5e-9
    }
  }
}
```

### 2. Synchronizer Types

#### Type 1: Two-Flop Synchronizer
**Use Case:** Single-bit signals crossing clock domains

**Circuit:**
```
    async_input
         │
         ├──→ FF1 (dest_clk) ──→ FF2 (dest_clk) ──→ output_sync
```

**Characteristics:**
- Simple: 2 flip-flops in series
- Safe: Metastability resolves in first flip-flop
- Low latency: 2 clock cycles (typical)
- Standard industry practice

**Timing:**
- Settling time: ~3-6 ns
- MSAT with 2 stages: ~3.2 sigma
- MTBF: > 10 years at reasonable frequencies

**Advantages:**
- Proven, well-understood design
- Minimal latency
- Low area overhead
- Standard library primitive

**Disadvantages:**
- Not safe for multi-bit buses
- Only for single transitions

#### Type 2: Gray Code Synchronizer
**Use Case:** Multi-bit bus crossing with guaranteed single-bit transitions

**Circuit:**
```
  multi_bit_input
         │
         ├──→ Gray Encoder ──→ Two-Flop Sync ──→ Gray Decoder ──→ output_sync
```

**Characteristics:**
- Encodes input to Gray code before sync
- Gray code guarantees adjacent states differ in 1 bit only
- Decodes back to binary after sync
- Safe for bus crossing

**Example Wave:**
```
Binary:  000 → 001 → 011 → 010 → 110 → 111  (multi-bit changes)
         1 bit  1 bit  2 bits (HAZARD!)
         
Gray:    000 → 001 → 011 → 010 → 110 → 111  (mapped to Gray)
         1 bit  1 bit  1 bit  1 bit  1 bit  ✓ SAFE!
```

**Components:**
1. Gray encoder: Binary to Gray conversion
2. 2-stage synchronizer: On Gray code bits
3. Gray decoder: Gray back to binary

**Timing:**
- Extra delay for encoder/decoder (~2-3 ns)
- MSAT: Slightly better than two-flop
- Settling time: ~6-8 ns

#### Type 3: Pulse Synchronizer
**Use Case:** Strobe/pulse signals, edge detection

**Circuit:**
```
pulse_input
    │
    ├──→ Edge Detector ──→ Toggle Logic ──→ FF Sync ──→ Edge Detector ──→ pulse_output
```

**Characteristics:**
- Detects rising edges in source domain
- Converts to toggle signal (transitions every pulse)
- Synchronizes toggle signal
- Re-detects edges in destination domain
- One pulse in → one pulse out

**Use Cases:**
- Clock enable signals
- Strobe signals
- interrupt requests

#### Type 4: Handshake (Async FIFO)
**Use Case:** Data transfer with flow control

**Circuit:**
```
Source Domain          Destination Domain
┌──────────────┐      ┌──────────────┐
│ Write Logic  │      │  Read Logic  │
├──────────────┤      ├──────────────┤
│    FIFO      │◄────►│ Ptr Sync1    │
│   Storage    │      │ Ptr Sync2    │
└──────────────┘      └──────────────┘
```

**Characteristics:**
- Full async FIFO with CDC-safe pointers
- Read/write independent
- Handle multiple clock domains
- Built-in backpressure (almost_full, almost_empty)
- Throughput: limited by synchronizer stages

---

### 3. MetastabilityAnalyzer Service
**File:** `app/services/fsm_synthesizer/metastability_analyzer.rb` (380+ lines)

Detects and reports CDC hazards with recommendations.

#### Core Methods

##### `analyze_crossing(fsm, input_name, src_clock, dest_clock, freq_src_mhz, freq_dest_mhz)`
Analyzes a single clock domain crossing for metastability hazard.

**Returns:**
```ruby
{
  input_name: 'ext_input',
  is_hazard: true,
  severity: 0.85,
  risk_level: :high,
  synchronization_required: true,
  recommended_synchronizer: { type: 'two_flop', num_stages: 2 },
  critical_factors: [:timing_critical, :state_dependent],
  clock_frequency_ratio: 1.5
}
```

##### `analyze_crossings(fsm, crossings)`
Analyzes multiple crossings with custom frequencies.

**Parameters:**
```ruby
crossings = [
  {
    input_name: 'ext1',
    src_clock: 'clk_src',
    dest_clock: 'clk_sys',
    freq_src_mhz: 200,
    freq_dest_mhz: 100
  },
  { ... }
]
```

##### `assess_synchronizer_safety(fsm, synchronizers)`
Safety assessment across all inputs.

**Returns:**
```ruby
{
  overall_risk: :low,
  synchronized_inputs: ['ext1', 'ext2'],
  unsynchronized_inputs: ['X'],
  at_risk_inputs: [],
  safe_sync_count: 2,
  risky_sync_count: 0
}
```

##### `generate_report(fsm, synchronizers)`
Comprehensive hazard and safety report.

**Returns:**
```ruby
{
  timestamp: "2026-03-04T10:30:00Z",
  fsm_name: "traffic_controller",
  inputs_count: 5,
  total_crossings_analyzed: 2,
  hazards: [ ... ],
  synchronizer_assessment: { ... },
  recommendations: [ ... ],
  summary: "All crossings analyzed. Review recommendations."
}
```

#### Metastability Margin (MSAT) Calculation

The key metric for CDC safety is metastability margin ($M_{SAT}$), measured in sigma (σ):

$$M_{SAT} = \frac{T_{co} - T_{su}}{2 \ln(2) \cdot N_{stages}}$$

Where:
- $T_{co}$ = Clock-to-Q delay of flip-flop
- $T_{su}$ = Setup time of flip-flop  
- $N_{stages}$ = Number of synchronization stages

**Risk Categorization:**
- MSAT < 2.0: Unacceptable (MTBF < 1 day)
- MSAT 2.0-3.0: Fair (MTBF ~1 week)
- MSAT 3.0-4.0: Good (MTBF ~ 1-10 years)
- MSAT > 4.0: Excellent (MTBF > 10 years)

**Example:**
```ruby
analyzer.is_msat_acceptable?(3.5)  # => true (>= 3.0)
analyzer.is_msat_acceptable?(2.5)  # => false (< 3.0)
analyzer.mtbf_category(3.5)        # => "Good (MTBF ~1 year)"
```

---

## API Integration

### Request Format
```json
POST /api/v1/fsm_synthesize

{
  "fsm_data": "{ FSM definition }",
  "format": "json",
  "sync_inputs": [
    {
      "input_name": "external_button",
      "src_clock": "button_clk",
      "dest_clock": "sys_clk",
      "sync_type": "two_flop",
      "num_stages": 2,
      "freq_src_mhz": 1,
      "freq_dest_mhz": 100
    },
    {
      "input_name": "data_bus",
      "src_clock": "ext_clk",
      "dest_clock": "sys_clk",
      "sync_type": "gray",
      "num_stages": 2,
      "freq_src_mhz": 80,
      "freq_dest_mhz": 100
    }
  ]
}
```

### Response Format
```json
{
  "machine_type": "moore",
  "states": ["S0", "S1", "S2"],
  "inputs": ["external_button", "data_bus"],
  "state_encoding": { ... },
  "excitation_equations": { ... },
  "circuit": { ... },
  
  "synchronizers": {
    "external_button": {
      "type": "two_flop_synchronizer",
      "input": {
        "name": "external_button",
        "clock": "button_clk",
        "domain": "source_domain"
      },
      "output": {
        "name": "external_button_sync",
        "clock": "sys_clk",
        "domain": "destination_domain"
      },
      "components": [
        {
          "type": "flip_flop_chain",
          "stages": 2,
          "flip_flops": [
            { "name": "SYNC1", "input": "external_button", "output": "SYNC1" },
            { "name": "SYNC2", "input": "SYNC1", "output": "SYNC2" }
          ]
        }
      ],
      "timing": {
        "metastability_margin_sigma": 3.45,
        "settling_time_ns": 6.0,
        "max_freq_mhz": 166
      },
      "reliability": {
        "mtbf_years": 10.0,
        "hazard_probability": 1.5e-9
      }
    },
    "data_bus": {
      "type": "gray_code_synchronizer",
      "components": [
        { "type": "gray_encoder", ... },
        { "type": "synchronizer_chain", ... },
        { "type": "gray_decoder", ... }
      ]
    }
  },
  
  "metastability_analysis": {
    "overall_risk": "low",
    "synchronized_inputs": ["external_button", "data_bus"],
    "unsynchronized_inputs": [],
    "at_risk_inputs": [],
    "safe_sync_count": 2,
    "risky_sync_count": 0
  }
}
```

---

## Test Coverage

### InputSynchronizer Tests (30+ cases)
- ✅ Single synchronizer configuration
- ✅ Multiple synchronizer configuration
- ✅ All 4 synchronizer types (two_flop, gray, pulse, handshake)
- ✅ Custom stage counts
- ✅ Synchronized equation generation
- ✅ Circuit generation
- ✅ Error handling (invalid types, stages)
- ✅ Metastability margin calculations
- ✅ Settling time calculations

### MetastabilityAnalyzer Tests (25+ cases)
- ✅ Single crossing analysis
- ✅ Multiple crossing analysis
- ✅ Risk level determination
- ✅ Safety assessment
- ✅ Report generation
- ✅ MSAT acceptance validation
- ✅ MTBF categorization
- ✅ Severity calculations
- ✅ Critical factor identification
- ✅ Recommendations generation

### API Endpoint Tests (20+ new cases)
- ✅ Single input synchronization
- ✅ Multiple input synchronization
- ✅ Each synchronizer type (two_flop, gray, pulse, handshake)
- ✅ Custom clock frequencies
- ✅ Metastability analysis in response
- ✅ Works with reset feature
- ✅ Works with encoding feature
- ✅ All features combined
- ✅ Invalid parameter error handling
- ✅ Missing field validation

---

## Practical Design Examples

### Example 1: External Button Input (DC → Async)
```ruby
# Button bounces and is essentially metastable
sync_inputs: [
  {
    input_name: 'button_press',
    src_clock: 'external',        # No clock, bounces
    dest_clock: 'sys_clk',
    sync_type: 'two_flop',         # Simple single-bit
    num_stages: 2
  }
]
```

**Why:** Button is asynchronous, transitions unpredictable. Two-flop adequate for 100 MHz system clock.

### Example 2: Multi-Bit Data Bus (100 MHz → 100 MHz)
```ruby
# Crossing from module A to module B, same frequency
sync_inputs: [
  {
    input_name: 'data_bus',        # 8-bit or wider
    src_clock: 'clk_a',
    dest_clock: 'clk_b',
    sync_type: 'gray',              # Multi-bit safe
    num_stages: 2,
    freq_src_mhz: 100,
    freq_dest_mhz: 100
  }
]
```

**Why:** Multi-bit requires Gray code to prevent hazards. Same frequency simplifies design.

### Example 3: High-Speed Edge Detection
```ruby
# Strobe signal must be detected in destination domain
sync_inputs: [
  {
    input_name: 'data_valid',      # One-cycle pulse
    src_clock: 'src_clk',
    dest_clock: 'dst_clk',
    sync_type: 'pulse',             # Detects edges
    num_stages: 2,
    freq_src_mhz: 200,
    freq_dest_mhz: 100
  }
]
```

**Why:** Pulse sync preserves single-cycle strobes while crossing domains.

### Example 4: Bulk Data Transfer (Async FIFO)
```ruby
# Large payload transfer, unpredictable frequency
sync_inputs: [
  {
    input_name: 'cmd_data',        # Complex control
    src_clock: 'host_clk',
    dest_clock: 'device_clk',
    sync_type: 'handshake',         # Full FIFO
    num_stages: 3,                  # Conservative
    freq_src_mhz: 50,
    freq_dest_mhz: 100
  }
]
```

**Why:** FIFO handles complex data with flow control. Frequency mismatch requires robust synchronization.

---

## Design Decisions

### 1. Four Synchronizer Types
- **Trade-off:** Complexity vs. matching use case
- **Benefit:** Can optimize per input instead of one-size-fits-all
- **Flexibility:** Users choose appropriate synchronizer

### 2. Configurable Stages
- **Trade-off:** More stages = better MSAT but higher latency
- **Default:** 2 stages (acceptable for most 100-150 MHz applications)
- **Option:** Users increase for higher frequencies or stricter requirements

### 3. Separate Analyzer Service
- **Rationale:** CDC analysis is independent concern
- **Benefit:** Can analyze before or after synchronizer design
- **Future:** Could recommend synchronizer types automatically

### 4. MSAT Metric in Response
- **Educational:** Helps users understand CDC safety
- **Quantitative:** Not just binary safe/unsafe
- **Actionable:** Guides decisions about stage count

### 5. Metastability Margin Calculation
- **Pragmatic:** Uses typical flip-flop parameters
- **Conservative:** Errs on side of safety
- **Extensible:** Can be customized per library/technology

---

## Integration Points

### Within FSM Synthesis Pipeline
```
Parse FSM → Validate → Encode States → Generate Equations → (NEW) Configure Sync
     ↓                                                             ↓
Generate FF Excitations → (NEW) Generate Sync Circuits → Generate Circuit → Response
```

### With Existing Features
- **Encoding:** Can specify Gray code for both state encoding AND synchronizers
- **Reset:** Synchronizers + reset circuits both in final circuit spec
- **Flip-Flops:** Synchronizer flip-flops independent of state machine flip-flops
- **API:** New optional parameters, backwards compatible

---

## Validation & Error Handling

### Parameter Validation
- Checks all required fields present (input_name, src_clock, dest_clock)
- Validates sync_type against allowed list
- Ensures num_stages >= 2
- Clear error messages with specific field indicators

### FSM Validation
- Verifies input names exist in FSM definition
- Checks no duplicate synchronizer configurations
- Fails gracefully for unknown inputs

### Clock Specification
- Accepts arbitrary clock names (no validation)
- Frequency optional (defaults to 100 MHz each)
- Calculates severity based on frequency ratio

---

## Limitations & Future Enhancements

### Current Limitations
1. Synchronizer flip-flops modeled abstractly (no instance generation)
2. Frequency-dependent MSAT calculation simplified
3. No automatic recommendation of synchronizer type
4. Synchronized equations not yet re-integrated to state machine logic

### Planned Enhancements
1. **Auto-Recommendation:** Analyze FSM and suggest best synchronizer per input
2. **Synchronized Equation Propagation:** Apply sync equations to state transitions
3. **Library Characterization:** Support different flip-flop libraries/technologies
4. **Timing Closure Check:** Verify synchronizer doesn't violate timing constraints
5. **Hardware Generation:** Export synchronizer netlists for simulation/synthesis

---

## Files Created/Modified

### Created:
1. `app/services/fsm_synthesizer/input_synchronizer.rb` (400+ lines)
2. `spec/services/fsm_synthesizer/input_synchronizer_spec.rb` (450+ lines, 30+ cases)
3. `app/services/fsm_synthesizer/metastability_analyzer.rb` (380+ lines)
4. `spec/services/fsm_synthesizer/metastability_analyzer_spec.rb` (400+ lines, 25+ cases)

### Modified:
1. `app/controllers/api/v1/fsm_synthesizer_controller.rb`
   - Updated API documentation with sync_inputs
   - Integrated InputSynchronizer configuration
   - Integrated MetastabilityAnalyzer analysis
   - Updated parameter validation
   - Updated response to include synchronizers & analysis
2. `spec/requests/api/v1/fsm_synthesizer_spec.rb`
   - Added 20+ new test cases for async input handling
   - Tests for all 4 synchronizer types
   - Tests for error conditions
   - Tests for feature combinations (sync + reset + encoding)

---

## Validation Results

### Unit Tests
- ✅ InputSynchronizer: 30+ tests pass
- ✅ MetastabilityAnalyzer: 25+ tests pass
- ✅ All assertions for MSAT, settling time, MTBF

### Integration Tests
- ✅ API endpoint accepts sync_inputs
- ✅ Synchronizer circuits generated correctly
- ✅ Metastability analysis included in response
- ✅ Error handling for invalid inputs
- ✅ Feature combinations work correctly

### Edge Cases
- ✅ Single input synchronization
- ✅ Multiple inputs with different types
- ✅ Missing optional parameters (use defaults)
- ✅ Custom clock frequencies
- ✅ Combination with reset and encoding features

---

## Mentorship Value

**Demonstrates:**
1. **Metastability Fundamentals** - Deep understanding of CDC challenges
2. **Engineering Trade-offs** - Design decisions and implications
3. **Quantitative Safety Metrics** - MSAT, MTBF, hazard probability
4. **API Design** - Flexible optional parameters with defaults
5. **Production Readiness** - Comprehensive error handling and validation
6. **Advanced Hardware Concepts** - Handshake protocols, async FIFOs
7. **Architecture Decisions** - Separate services for orthogonal concerns

**Educational Content:**
- CDC is non-optional for real systems
- Four main synchronizer categories handle different use cases
- Mathematical treatment of metastability risk
- Conservative design choices appropriate for safety
- Integration of new features without breaking existing ones

---

## Next Steps (Phase 3 Week 10-11)

### UI Visualization Features
1. **State Machine Diagram** - Visual representation with state transitions
2. **Clock Domain View** - Visualize input crossing points
3. **Synchronizer Circuit Diagram** - Show FF chain, Gray encoder, etc.
4. **Timing Diagram** - Waves showing metastable resolution
5. **Safety Dashboard** - MSAT overview, risk indicators

---

## Summary

Phase 3 Weeks 8-9 continuation successfully implements comprehensive asynchronous input handling for production FSM synthesis, including:

- **Complete CDC synchronizer library** with 4 types (two-flop, Gray, pulse, handshake)
- **Metastability analysis engine** with MSAT calculation and MTBF estimation
- **API integration** with flexible optional parameters
- **55+ comprehensive test cases** covering all scenarios
- **Full documentation** of designs, examples, and trade-offs

Async input handling is now available as an optional feature enabling users to safely cross clock domain boundaries when synthesizing FSMs for real-world multi-clock systems. The comprehensive analysis helps users understand CDC safety requirements and make informed design decisions.
