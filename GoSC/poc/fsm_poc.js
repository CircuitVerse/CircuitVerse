const fs = require("fs");
const path = require("path");

function log2ceil(n) {
  return Math.ceil(Math.log2(Math.max(1, n)));
}

function toBits(value, width) {
  return value.toString(2).padStart(width, "0").split("").map(Number);
}

function validateFSM(fsm) {
  const errors = [];
  const supported = new Set(["moore", "mealy"]);

  if (!supported.has(fsm.machineType)) {
    errors.push("machineType must be 'moore' or 'mealy'");
  }

  if (!Array.isArray(fsm.states) || fsm.states.length < 2) {
    errors.push("At least 2 states are required");
  }

  if (!Array.isArray(fsm.inputs) || fsm.inputs.length < 1) {
    errors.push("At least 1 input symbol is required");
  }

  if (!Array.isArray(fsm.outputs) || fsm.outputs.length < 1) {
    errors.push("At least 1 output symbol is required");
  }

  const stateIds = new Set((fsm.states || []).map((s) => s.id));
  const initialCount = (fsm.states || []).filter((s) => s.isInitial).length;
  if (initialCount !== 1) {
    errors.push("Exactly one initial state is required");
  }

  const seenTransitions = new Set();
  for (const t of fsm.transitions || []) {
    if (!stateIds.has(t.fromState) || !stateIds.has(t.toState)) {
      errors.push(`Transition references unknown state: ${JSON.stringify(t)}`);
      continue;
    }
    if (!fsm.inputs.includes(t.input)) {
      errors.push(`Transition has unknown input symbol: ${JSON.stringify(t)}`);
      continue;
    }

    const key = `${t.fromState}|${t.input}`;
    if (seenTransitions.has(key)) {
      errors.push(`Non-deterministic transition for (${t.fromState}, ${t.input})`);
    } else {
      seenTransitions.add(key);
    }

    if (fsm.machineType === "mealy") {
      if (!t.output || typeof t.output !== "object") {
        errors.push(`Mealy transition missing output: ${JSON.stringify(t)}`);
      } else {
        for (const outKey of fsm.outputs) {
          if (!(outKey in t.output)) {
            errors.push(`Mealy transition missing output key '${outKey}': ${JSON.stringify(t)}`);
          }
        }
      }
    }
  }

  for (const s of fsm.states || []) {
    for (const input of fsm.inputs || []) {
      const key = `${s.id}|${input}`;
      if (!seenTransitions.has(key)) {
        errors.push(`Missing transition for (${s.id}, ${input})`);
      }
    }
  }

  if (fsm.machineType === "moore") {
    if (!fsm.stateOutputs || typeof fsm.stateOutputs !== "object") {
      errors.push("Moore machine requires stateOutputs map");
    } else {
      for (const s of fsm.states || []) {
        if (!(s.id in fsm.stateOutputs)) {
          errors.push(`Moore stateOutputs missing state '${s.id}'`);
          continue;
        }
        for (const outKey of fsm.outputs) {
          if (!(outKey in fsm.stateOutputs[s.id])) {
            errors.push(`Moore state '${s.id}' missing output key '${outKey}'`);
          }
        }
      }
    }
  }

  return { valid: errors.length === 0, errors };
}

function encodeStates(fsm) {
  const width = log2ceil(fsm.states.length);
  const encoding = {};

  fsm.states.forEach((state, index) => {
    encoding[state.id] = toBits(index, width);
  });

  return { width, encoding };
}

function stateInputRows(fsm, encoding, width) {
  const rows = [];
  for (const t of fsm.transitions) {
    const current = encoding[t.fromState];
    const next = encoding[t.toState];
    const inputBit = Number(t.input);

    const outputMap = {};
    for (const outKey of fsm.outputs) {
      if (fsm.machineType === "moore") {
        outputMap[outKey] = Number(fsm.stateOutputs[t.fromState][outKey]);
      } else {
        outputMap[outKey] = Number(t.output[outKey]);
      }
    }

    rows.push({
      state: t.fromState,
      input: inputBit,
      currentBits: current,
      nextBits: next,
      outputMap,
      vars: [...current, inputBit],
      width,
    });
  }
  return rows;
}

function varNames(width) {
  const stateVars = Array.from({ length: width }, (_, i) => `Q${i}`);
  return [...stateVars, "X"];
}

function mintermToProduct(varBits, names) {
  const terms = [];
  for (let i = 0; i < varBits.length; i += 1) {
    terms.push(varBits[i] === 1 ? names[i] : `~${names[i]}`);
  }
  return terms.join(" & ");
}

function toCanonicalSOP(rows, selector, names) {
  const minterms = rows.filter(selector).map((r) => mintermToProduct(r.vars, names));
  if (minterms.length === 0) {
    return "0";
  }
  if (minterms.length === rows.length) {
    return "1";
  }
  return minterms.join(" | ");
}

function deriveEquations(fsm, rows, width) {
  const names = varNames(width);

  const nextStateEqs = {};
  for (let i = 0; i < width; i += 1) {
    nextStateEqs[`D${i}`] = toCanonicalSOP(rows, (r) => r.nextBits[i] === 1, names);
  }

  const outputEqs = {};
  for (const outKey of fsm.outputs) {
    outputEqs[outKey] = toCanonicalSOP(rows, (r) => r.outputMap[outKey] === 1, names);
  }

  return { nextStateEqs, outputEqs, varOrder: names };
}

function synthesizeLogicBlocks(width, equations) {
  const flipFlops = Array.from({ length: width }, (_, i) => ({
    id: `FF_${i}`,
    type: "DFF",
    input: `D${i}`,
    output: `Q${i}`,
  }));

  const combinational = [
    ...Object.entries(equations.nextStateEqs).map(([lhs, rhs]) => ({ type: "expr", lhs, rhs })),
    ...Object.entries(equations.outputEqs).map(([lhs, rhs]) => ({ type: "expr", lhs, rhs })),
  ];

  return {
    flipFlops,
    combinational,
    notes: "POC representation; map these expressions to concrete CircuitVerse gates in integration phase.",
  };
}

function buildPOC(fsm) {
  const validation = validateFSM(fsm);
  if (!validation.valid) {
    return { ok: false, errors: validation.errors };
  }

  const { width, encoding } = encodeStates(fsm);
  const rows = stateInputRows(fsm, encoding, width);
  const equations = deriveEquations(fsm, rows, width);
  const logicBlocks = synthesizeLogicBlocks(width, equations);

  return {
    ok: true,
    machineType: fsm.machineType,
    stateBits: width,
    encoding,
    equations,
    logicBlocks,
  };
}

function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf-8"));
}

function runFromFile(relativePath) {
  const resolved = path.resolve(__dirname, relativePath);
  const model = loadJson(resolved);
  return buildPOC(model);
}

module.exports = {
  validateFSM,
  encodeStates,
  deriveEquations,
  synthesizeLogicBlocks,
  buildPOC,
  runFromFile,
};
