import { defineStore } from "pinia";
import { reactive, ref } from "vue";
import { runTestBench } from "#/simulator/src/testbench";

export interface TestData {
  type: string;
  title: string;
  groups: {
    label: string;
    inputs: {
      label: string;
      bitWidth: number;
      values: string[];
    }[];
    outputs: {
      label: string;
      bitWidth: number;
      values: string[];
      results?: string[];
    }[];
    n: number;
  }[];
}

export interface TestBenchData {
  testData: TestData;
  currentGroup: number;
  currentCase: number;

  isCaseValid?(): boolean;
  setCase?(groupIndex: number, caseIndex: number): boolean;
  groupNext?(): boolean;
  groupPrev?(): boolean;
  caseNext?(): boolean;
  casePrev?(): boolean;
  goToFirstValidGroup?(): boolean;
};

export interface ValidationErrors {
  ok: boolean
  invalids?: {
    type: number
    identifier: string
    message: string
    extraInfo?: any
  }[]
}

export interface Result {
  value: string;
  color: string;
}

export const useTestBenchStore = defineStore("testBenchStore", () => {
  const showTestBenchCreator = ref(false);
  const showTestbenchUI = ref(false);
  const showTestBenchValidator = ref(false);
  const resultValues = ref<Result[]>([]);
  const passed = ref(0);
  const total = ref(0);
  const showPassed = ref(false);
  const showResults = ref(false);
  const readOnly = ref(false);

  const testData = reactive<TestData>({
    type: "",
    title: "",
    groups: [],
  });

  const testbenchData = reactive<TestBenchData>({
    testData: testData,
    currentGroup: 0,
    currentCase: 0,
  });

  const validationErrors: ValidationErrors = reactive({
    ok: true,
    invalids: []
  });

  const sendData = (dataValues: TestData) => {
    showTestbenchUI.value = true;
    testData.type = dataValues.type;
    testData.title = dataValues.title;
    testData.groups = dataValues.groups;
    runTestBench(dataValues, globalScope, 0);
    showTestBenchCreator.value = false;
  }

  return {
    showTestBenchCreator,
    sendData,
    testbenchData,
    showTestbenchUI,
    validationErrors,
    showTestBenchValidator,
    resultValues,
    passed,
    total,
    showResults,
    readOnly,
    showPassed,
  }
})
