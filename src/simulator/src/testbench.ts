import { TestData } from "#/store/testBenchStore";
import { showMessage } from '#/simulator/src/utils'
import { useTestBenchStore, TestBenchData } from "#/store/testBenchStore";
import { changeClockEnable } from '#/simulator/src/sequential'
import { play } from '#/simulator/src/engine'
import { confirmOption } from '#/components/helpers/confirmComponent/ConfirmComponent.vue'
import { escapeHtml } from '#/simulator/src/utils'

const CONTEXT = {
  CONTEXT_SIMULATOR: 0,
  CONTEXT_ASSIGNMENTS: 1,
}

export const VALIDATION_ERRORS = {
  NOTPRESENT: 0, // Element is not present in the circuit
  WRONGBITWIDTH: 1, // Element is present but has incorrect bitwidth
  DUPLICATE_ID_DATA: 2, // Duplicate identifiers in test data
  DUPLICATE_ID_SCOPE: 3, // Duplicate identifiers in scope
  NO_RST: 4, // Sequential circuit but no reset(RST) in scope
}

export class TestbenchData {
  currentCase: number;
  currentGroup: number;
  testData: TestData;

  constructor(data: TestData, currentGroup = 0, currentCase = 0) {
    this.currentCase = currentCase;
    this.currentGroup = currentGroup;
    this.testData = data;
  }

  isCaseValid() {
    if (this.currentGroup >= this.testData.groups.length || this.currentGroup < 0) return false;
    const caseCount = this.testData.groups[this.currentGroup].inputs[0].values.length;
    if (this.currentCase >= caseCount || this.currentCase < 0) return false;

    return true;
  }

  setCase(groupIndex: number, caseIndex: number) {
    const newCase = new TestbenchData(this.testData, groupIndex, caseIndex);
    if (newCase.isCaseValid()) {
      this.currentGroup = groupIndex;
      this.currentCase = caseIndex;
      return true;
    }
    return false;
  }

  groupNext() {
    const newCase = new TestbenchData(this.testData, this.currentGroup, 0);
    const groupCount = newCase.testData.groups.length;
    let caseCount = 0;
    if (newCase.testData.groups[this.currentGroup].inputs[0]) {
      caseCount = newCase.testData.groups[this.currentGroup].inputs[0].values.length;
    }

    while (caseCount === 0 || this.currentGroup === newCase.currentGroup) {
      newCase.currentGroup++;
      if (newCase.currentGroup >= groupCount) return false;
      caseCount = newCase.testData.groups[newCase.currentGroup].inputs[0].values.length;
    }

    this.currentGroup = newCase.currentGroup;
    this.currentCase = newCase.currentCase;
    return true;
  }

  groupPrev() {
    const newCase = new TestbenchData(this.testData, this.currentGroup, 0);
    const groupCount = newCase.testData.groups.length;
    let caseCount = newCase.testData.groups[newCase.currentGroup].inputs[0].values.length;

    while (caseCount === 0 || this.currentGroup === newCase.currentGroup) {
      newCase.currentGroup--;
      if (newCase.currentGroup < 0) return false;
      caseCount = newCase.testData.groups[newCase.currentGroup].inputs[0].values.length;
    }

    this.currentGroup = newCase.currentGroup;
    this.currentCase = newCase.currentCase;
    return true;
  }

  caseNext() {
    const caseCount = this.testData.groups[this.currentGroup].inputs[0].values.length;
    if (this.currentCase >= caseCount - 1) return this.groupNext();
    this.currentCase++;
    return true;
  }

  casePrev() {
    if (this.currentCase <= 0) {
      if (!this.groupPrev()) return false;
      const caseCount = this.testData.groups[this.currentGroup].inputs[0].values.length;
      this.currentCase = caseCount - 1;
      return true;
    }

    this.currentCase--;
    return true;
  }

  goToFirstValidGroup() {
    const newCase = new TestbenchData(this.testData, 0, 0);
    let caseCount = 0;
    if (newCase.testData.groups[this.currentGroup].inputs[0]) {
      caseCount = newCase.testData.groups[this.currentGroup].inputs[0].values.length;
    }

    if (caseCount > 0) return true;

    const validExists = newCase.groupNext();

    if (!validExists) return false;

    this.currentGroup = newCase.currentGroup;
    this.currentCase = newCase.currentCase;
    return true;
  }
}

/**
 * Checks if all the labels in the test data are unique. Called by validate()
 */
function checkDistinctIdentifiersData(data: TestData) {
  const inputIdentifiersData = data.groups[0].inputs.map(
    (input) => input.label
  )
  const outputIdentifiersData = data.groups[0].outputs.map(
    (output) => output.label
  )
  const identifiersData = inputIdentifiersData.concat(outputIdentifiersData)

  return new Set(identifiersData).size === identifiersData.length
}

/**
 * Checks if all the input/output labels in the scope are unique. Called by validate()
 * TODO: Replace with identifiers
 */
function checkDistinctIdentifiersScope(scope) {
  const inputIdentifiersScope = scope.Input.map((input) => input.label)
  const outputIdentifiersScope = scope.Output.map((output) => output.label)
  let identifiersScope = inputIdentifiersScope.concat(outputIdentifiersScope)

  // Remove identifiers which have not been set yet (ie. empty strings)
  identifiersScope = identifiersScope.filter((identifer) => identifer != '')

  return new Set(identifiersScope).size === identifiersScope.length
}

/**
 * Validates presence and bitwidths of test inputs in the circuit.
 * Called by validate()
 */
function validateInputs(data: TestData, scope) {
  const invalids: Invalids[] = []

  data.groups[0].inputs.forEach((dataInput) => {
    const matchInput = scope.Input.find(
      (simulatorInput) => simulatorInput.label === dataInput.label
    )

    if (matchInput === undefined) {
      invalids.push({
        type: VALIDATION_ERRORS.NOTPRESENT,
        identifier: dataInput.label,
        message: 'Input is not present in the circuit',
      })
    } else if (matchInput.bitWidth !== dataInput.bitWidth) {
      invalids.push({
        type: VALIDATION_ERRORS.WRONGBITWIDTH,
        identifier: dataInput.label,
        extraInfo: {
          element: matchInput,
          expectedBitWidth: dataInput.bitWidth,
        },
        message: `Input bitwidths don't match in circuit and test (${matchInput.bitWidth} vs ${dataInput.bitWidth})`,
      })
    }
  })

  if (invalids.length > 0) return { ok: false, invalids }
  return { ok: true }
}

interface Invalids {
  type: number
  identifier: string
  message: string
  extraInfo?: any
}

/**
 * Validates presence and bitwidths of test outputs in the circuit.
 * Called by validate()
 */
function validateOutputs(data: TestData, scope) {
  const invalids: Invalids[] = []

  data.groups[0].outputs.forEach((dataOutput) => {
    const matchOutput = scope.Output.find(
      (simulatorOutput) => simulatorOutput.label === dataOutput.label
    )

    if (matchOutput === undefined) {
      invalids.push({
        type: VALIDATION_ERRORS.NOTPRESENT,
        identifier: dataOutput.label,
        message: 'Output is not present in the circuit',
      })
    } else if (matchOutput.bitWidth !== dataOutput.bitWidth) {
      invalids.push({
        type: VALIDATION_ERRORS.WRONGBITWIDTH,
        identifier: dataOutput.label,
        extraInfo: {
          element: matchOutput,
          expectedBitWidth: dataOutput.bitWidth,
        },
        message: `Output bitwidths don't match in circuit and test (${matchOutput.bitWidth} vs ${dataOutput.bitWidth})`,
      })
    }
  })

  if (invalids.length > 0) return { ok: false, invalids }
  return { ok: true }
}

/**
 * Validate if all inputs and output elements are present with correct bitwidths
 */
function validate(data: TestData, scope) {
  let invalids = []

  // Check for duplicate identifiers
  if (!checkDistinctIdentifiersData(data)) {
    invalids.push({
      type: VALIDATION_ERRORS.DUPLICATE_ID_DATA,
      identifier: '-',
      message: 'Duplicate identifiers in test data',
    })
  }

  if (!checkDistinctIdentifiersScope(scope)) {
    invalids.push({
      type: VALIDATION_ERRORS.DUPLICATE_ID_SCOPE,
      identifier: '-',
      message: 'Duplicate identifiers in circuit',
    })
  }

  // Don't do further checks if duplicates
  if (invalids.length > 0) return { ok: false, invalids }

  // Validate inputs and outputs
  const inputsValid = validateInputs(data, scope)
  const outputsValid = validateOutputs(data, scope)

  invalids = inputsValid.ok ? invalids : invalids.concat(inputsValid.invalids)
  invalids = outputsValid.ok
    ? invalids
    : invalids.concat(outputsValid.invalids)

  // Validate presence of reset if test is sequential
  if (data.type === 'seq') {
    const resetPresent = scope.Input.some(
      (simulatorReset) =>
        simulatorReset.label === 'RST' &&
        simulatorReset.bitWidth === 1 &&
        simulatorReset.objectType === 'Input'
    )

    if (!resetPresent) {
      invalids.push({
        type: VALIDATION_ERRORS.NO_RST,
        identifier: 'RST',
        message: 'Reset(RST) not present in circuit',
      })
    }
  }

  if (invalids.length > 0) return { ok: false, invalids }
  return { ok: true }
}

/**
 * Returns object of scope inputs and outputs keyed by their labels
 */
function bindIO(data: TestData, scope) {
  const inputs: { [key: string]: any } = {}
  const outputs: { [key: string]: any } = {}
  let reset

  data.groups[0].inputs.forEach((dataInput) => {
    inputs[dataInput.label] = scope.Input.find(
      (simulatorInput) => simulatorInput.label === dataInput.label
    )
  })

  data.groups[0].outputs.forEach((dataOutput) => {
    outputs[dataOutput.label] = scope.Output.find(
      (simulatorOutput) => simulatorOutput.label === dataOutput.label
    )
  })

  if (data.type === 'seq') {
    reset = scope.Input.find(
      (simulatorOutput) => simulatorOutput.label === 'RST'
    )
  }

  return { inputs, outputs, reset }
}

/**
 * Set and propogate the input values according to the testcase.
 * Called by runSingle() and runAll()
 */
function setInputValues(inputs, group, caseIndex: number, scope) {
  group.inputs.forEach((input) => {
    inputs[input.label].state = parseInt(input.values[caseIndex], 2)
  })

  // Propagate inputs
  play(scope)
}

/**
 * Ticks clock recursively one full cycle (Only used in testbench context)
 */
function tickClock(scope: any) {
  scope.clockTick()
  play(scope)
  scope.clockTick()
  play(scope)
}

// Do we have any other function to do this?
// Utility function. Converts decimal number to binary string
function dec2bin(dec: number | undefined, bitWidth = undefined) {
  if (dec === undefined) return 'X'
  const bin = (dec >>> 0).toString(2)
  if (!bitWidth) return bin

  return '0'.repeat(bitWidth - bin.length) + bin
}

/**
 * Gets Output values as a Map with keys as output name and value as output state
 */
function getOutputValues(data: TestData, outputs) {
  const values = new Map()

  data.groups[0].outputs.forEach((dataOutput) => {
    // Using node value because output state only changes on rendering
    const resultValue = outputs[dataOutput.label].nodeList[0].value
    const resultBW = outputs[dataOutput.label].nodeList[0].bitWidth
    values.set(dataOutput.label, dec2bin(resultValue, resultBW))
  })

  return values
}

/**
 * Triggers reset (Only used in testbench context)
 */
function triggerReset(reset: any, scope: any) {
  reset.state = 1
  play(scope)
  reset.state = 0
  play(scope)
}

/**
 * Interface function to run testbench. Called by testbench prompt on simulator or assignments
 */
export function runTestBench(
  data: TestData,
  scope = globalScope,
  runContext = CONTEXT.CONTEXT_SIMULATOR
) {
  const testBenchStore = useTestBenchStore()
  // const { testbenchData } = toRefs(testBenchStore)
  const isValid = validate(data, scope)
  if (!isValid.ok) {
    showMessage(
      'Testbench: Some elements missing from circuit. Click Validate to know more'
    )
  }

  if (runContext === CONTEXT.CONTEXT_SIMULATOR) {
    const tempTestbenchData = new TestbenchData(data)
    if (!tempTestbenchData.goToFirstValidGroup()) {
      showMessage('Testbench: The test is empty')
      testBenchStore.showTestbenchUI = false
      return
    }

    testBenchStore.testbenchData = tempTestbenchData

    return
  }

  if (runContext === CONTEXT.CONTEXT_ASSIGNMENTS) {
    // Not implemented
  }
}

interface Results {
  detailed: TestData
  summary: {
    passed: number
    total: number
  }
}

/**
 * Run all the tests automatically. Called by runTestBench()
 */
export function runAll(data: TestData, scope = globalScope) {
  // Stop the clocks
  // TestBench will now take over clock toggling
  changeClockEnable(false)

  const { inputs, outputs, reset } = bindIO(data, scope)
  let totalCases = 0
  let passedCases = 0

  data.groups.forEach((group) => {
    // for (const output of group.outputs) output.results = [];
    group.outputs.forEach((output) => (output.results = []))
    for (let case_i = 0; case_i < group.n; case_i++) {
      totalCases++
      // Set and propagate the inputs
      setInputValues(inputs, group, case_i, scope)
      // If sequential, trigger clock now
      if (data.type === 'seq') tickClock(scope)
      // Get output values
      const caseResult = getOutputValues(data, outputs)
      // Put the results in the data

      let casePassed = true // Tracks if current case passed or failed

      caseResult.forEach((_, outName) => {
        // TODO: find() is not the best idea because of O(n)
        const output = group.outputs.find(
          (dataOutput) => dataOutput.label === outName
        )
        output?.results?.push(caseResult.get(outName))

        if (output?.values[case_i] !== caseResult.get(outName))
          casePassed = false
      })

      // If current case passed, then increment passedCases
      if (casePassed) passedCases++
    }

    // If sequential, trigger reset at the end of group (set)
    if (data.type === 'seq') triggerReset(reset, scope) // qs. why scope is not passed?
  })

  // Tests done, restart the clocks
  changeClockEnable(true)

  // Return results
  const results: Results = {
    detailed: data,
    summary: { passed: passedCases, total: totalCases }
  };
  return results
}

/**
 * Runs single combinational test
 */
function runSingleCombinational(testbenchData: TestBenchData, scope) {
  const data = testbenchData.testData
  const groupIndex = testbenchData.currentGroup
  const caseIndex = testbenchData.currentCase

  const { inputs, outputs } = bindIO(data, scope)
  const group = data.groups[groupIndex]

  // Stop the clocks
  changeClockEnable(false)

  // Set input values according to the test
  setInputValues(inputs, group, caseIndex, scope)
  // Check output values
  const result = getOutputValues(data, outputs)
  // Restart the clocks
  changeClockEnable(true)
  return result
}

/**
 * Runs single sequential test and all tests above it in the group
 * Used in MANUAL mode
 */
function runSingleSequential(testbenchData: TestBenchData, scope) {
  const data = testbenchData.testData
  const groupIndex = testbenchData.currentGroup
  const caseIndex = testbenchData.currentCase

  const { inputs, outputs, reset } = bindIO(data, scope)
  const group = data.groups[groupIndex]

  // Stop the clocks
  changeClockEnable(false)

  // Trigger reset
  triggerReset(reset, scope)

  // Run the test and tests above in the same group
  for (let case_i = 0; case_i <= caseIndex; case_i++) {
    setInputValues(inputs, group, case_i, scope)
    tickClock(scope)
  }

  const result = getOutputValues(data, outputs)

  // Restart the clocks
  changeClockEnable(true)

  return result
}

type openCreatorType = 'create' | 'edit' | 'result'

export function openCreator(type: openCreatorType) {
  const testBenchStore = useTestBenchStore();
  if (type === 'create') {
    testBenchStore.showResults = false;
    testBenchStore.readOnly = false;
    testBenchStore.showTestBenchCreator = true;
  }

  if (type === 'edit') {
    testBenchStore.showResults = false;
    testBenchStore.readOnly = false;
    testBenchStore.showTestBenchCreator = true;
  }

  if (type === 'result') {
    testBenchStore.showResults = true;
    testBenchStore.readOnly = true;
    testBenchStore.showTestBenchCreator = true;
  }
}

/**
* UI Function
* Set the current test case result on the UI
*/

function setUIResult(testbenchData: TestBenchData, result) {
  const testBenchStore = useTestBenchStore();
  const data = testbenchData.testData;
  const groupIndex = testbenchData.currentGroup;
  const caseIndex = testbenchData.currentCase;

  const inputCount = data.groups[0].inputs.length;
  const newResultValues = [];

  for (let i = 0; i < inputCount; i++) {
    newResultValues.push({ value: ' - ', color: '#000' });
  }

  for (const output of result.keys()) {
    const resultValue = result.get(output);
    const outputData = data.groups[groupIndex].outputs.find(
      (dataOutput) => dataOutput.label === output
    );

    const expectedValue = outputData ? outputData.values[caseIndex] : undefined;
    const color = resultValue === expectedValue ? '#17FC12' : '#FF1616';
    newResultValues.push({ value: escapeHtml(resultValue), color });
  }

  testBenchStore.resultValues = newResultValues;
}

/**
 * Defines all the functions called as event listeners for buttons on the UI
 */
export const buttonListenerFunctions = {
  previousCaseButton: () => {
    const isValid = validate(
      useTestBenchStore().testbenchData.testData,
      globalScope
    )
    if (!isValid.ok) {
      showMessage(
        'Testbench: Some elements missing from circuit. Click Validate to know more'
      )
      return
    }
    const testbenchData = useTestBenchStore().testbenchData;
    if (testbenchData && testbenchData.casePrev) {
      testbenchData.casePrev();
    }
    buttonListenerFunctions.computeCase()
  },

  nextCaseButton: () => {
    const isValid = validate(
      useTestBenchStore().testbenchData.testData,
      globalScope
    )
    if (!isValid.ok) {
      showMessage(
        'Testbench: Some elements missing from circuit. Click Validate to know more'
      )
      return
    }
    const testbenchData = useTestBenchStore().testbenchData;
    if (testbenchData && testbenchData.caseNext) {
      testbenchData.caseNext();
    }
    buttonListenerFunctions.computeCase()
  },

  previousGroupButton: () => {
    const isValid = validate(
      useTestBenchStore().testbenchData.testData,
      globalScope
    )
    if (!isValid.ok) {
      showMessage(
        'Testbench: Some elements missing from circuit. Click Validate to know more'
      )
      return
    }
    const testbenchData = useTestBenchStore().testbenchData;
    if (testbenchData && testbenchData.groupPrev) {
      testbenchData.groupPrev();
    }
    buttonListenerFunctions.computeCase()
  },

  nextGroupButton: () => {
    const isValid = validate(
      useTestBenchStore().testbenchData.testData,
      globalScope
    )
    if (!isValid.ok) {
      showMessage(
        'Testbench: Some elements missing from circuit. Click Validate to know more'
      )
      return
    }
    const testbenchData = useTestBenchStore().testbenchData;
    if (testbenchData && testbenchData.groupNext) {
      testbenchData.groupNext();
    }
    buttonListenerFunctions.computeCase()
  },

  changeTestButton: () => {
    openCreator('create')
  },

  runAllButton: () => {
    const isValid = validate(
      useTestBenchStore().testbenchData.testData,
      globalScope
    )
    if (!isValid.ok) {
      showMessage(
        'Testbench: Some elements missing from circuit. Click Validate to know more'
      )
      return
    }
    const results = runAll(useTestBenchStore().testbenchData.testData, globalScope)
    const { passed } = results.summary
    const { total } = results.summary

    useTestBenchStore().passed = passed
    useTestBenchStore().total = total
    useTestBenchStore().showPassed = true

    setTimeout(() => {
      useTestBenchStore().showPassed = false
    }, 3000)
  },

  editTestButton: () => {
    const editDataString = JSON.stringify(
      useTestBenchStore().testbenchData.testData
    )
    openCreator('edit')
  },

  validateButton: () => {
    const testBenchStore = useTestBenchStore()
    const isValid = validate(
      useTestBenchStore().testbenchData.testData,
      globalScope
    )
    testBenchStore.validationErrors = isValid
    testBenchStore.showTestBenchValidator = true
  },

  removeTestButton: async () => {
    if (
      await confirmOption(
        'Are you sure you want to remove the test from the circuit?'
      )
    ) {
      useTestBenchStore().testbenchData = {
        testData: {
          type: "",
          title: "",
          groups: [
            {
              label: "Group 1",
              inputs: [],
              outputs: [],
              n: 0
            }
          ],
        },
        currentGroup: 0,
        currentCase: 0,
      }
      useTestBenchStore().showTestbenchUI = false
    }
  },

  attachTestButton: () => {
    openCreator('create')
  },

  rerunTestButton: () => {
    buttonListenerFunctions.computeCase()
  },

  computeCase: () => {
    const result = runSingleTest(useTestBenchStore().testbenchData, globalScope)
    setUIResult(useTestBenchStore().testbenchData, result)
  },
}

/**
* Runs single test
*/
function runSingleTest(testbenchData: TestBenchData, scope) {
  const data = testbenchData.testData

  let result
  if (data.type === 'comb') {
    result = runSingleCombinational(testbenchData, scope)
  } else if (data.type === 'seq') {
    result = runSingleSequential(testbenchData, scope)
  }

  return result
}
