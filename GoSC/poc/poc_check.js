const { runFromFile } = require("./fsm_poc");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function printSummary(label, result) {
  console.log(`\n=== ${label} ===`);
  if (!result.ok) {
    console.log("Validation errors:");
    result.errors.forEach((e) => console.log(`- ${e}`));
    return;
  }

  console.log(`Machine type: ${result.machineType}`);
  console.log(`State bits: ${result.stateBits}`);
  console.log("Encoding:", result.encoding);
  console.log("Next-state equations:", result.equations.nextStateEqs);
  console.log("Output equations:", result.equations.outputEqs);
  console.log(`Generated FF blocks: ${result.logicBlocks.flipFlops.length}`);
}

function run() {
  const moore = runFromFile("./examples/moore_3state.json");
  const mealy = runFromFile("./examples/mealy_4state.json");

  printSummary("Moore 3-state", moore);
  printSummary("Mealy 4-state", mealy);

  assert(moore.ok, "Moore POC should be valid");
  assert(mealy.ok, "Mealy POC should be valid");
  assert(moore.stateBits >= 2, "Moore sample should use >=2 state bits");
  assert(mealy.stateBits >= 2, "Mealy sample should use >=2 state bits");
  assert(Object.keys(moore.equations.nextStateEqs).length === moore.stateBits, "Moore D equations mismatch");
  assert(Object.keys(mealy.equations.nextStateEqs).length === mealy.stateBits, "Mealy D equations mismatch");

  console.log("\nPOC checks passed.");
}

run();
