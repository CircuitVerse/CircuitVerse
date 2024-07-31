<template>
    <div class="testbench-manual-panel draggable-panel noSelect defaultCursor" ref="testbenchPanelRef">
        <div class="panel-header">
            Testbench
            <span class="fas fa-minus-square minimize panel-button"></span>
            <span class="fas fa-external-link-square-alt maximize panel-button-icon"></span>
        </div>
        <div v-if="testBenchStore.showTestbenchUI" class="panel-body tb-test-not-null tb-panel-hidden">
            <div class="tb-manual-test-data">
                <div style="margin-bottom: 10px; overflow: auto">
                    <span id="data-title" class="tb-data"><b>Test:</b> <span>{{ testData.title || 'Untitled'
                            }}</span></span>
                    <span id="data-type" class="tb-data"><b>Type:</b> <span>{{ testData.type === 'comb' ?
                            'Combinational' : 'Sequential' }}</span></span>
                </div>
                <button id="edit-test-btn" @mousedown="buttonListenerFunctions.editTestButton()"
                    class="custom-btn--basic panel-button tb-dialog-button">
                    Edit
                </button>
                <button id="remove-test-btn" @mousedown="buttonListenerFunctions.removeTestButton()"
                    class="custom-btn--tertiary panel-button tb-dialog-button">
                    Remove
                </button>
            </div>
            <div style="overflow: auto; margin-bottom: 10px">
                <div class="tb-manual-test-buttons tb-group-buttons">
                    <span style="line-height: 24px; margin-right: 5px"><b>Group: </b></span>
                    <button id="prev-group-btn" @mousedown="buttonListenerFunctions.previousGroupButton()"
                        class="custom-btn--basic panel-button tb-case-button-left tb-case-button">
                        <i class="tb-case-arrow tb-case-arrow-left"></i>
                    </button>
                    <span class="tb-test-label group-label"> {{ testData.groups[testBenchStore.testbenchData.currentGroup].label
                        }}</span>
                    <button id="next-group-btn" @mousedown="buttonListenerFunctions.nextGroupButton()"
                        class="custom-btn--basic panel-button tb-case-button-right tb-case-button">
                        <i class="tb-case-arrow tb-case-arrow-right"></i>
                    </button>
                </div>
                <div class="tb-manual-test-buttons tb-case-buttons">
                    <span style="line-height: 24px; margin-right: 5px"><b>Case: </b></span>
                    <button id="prev-case-btn" @mousedown="buttonListenerFunctions.previousCaseButton()"
                        class="custom-btn--basic panel-button tb-case-button-left tb-case-button">
                        <i class="tb-case-arrow tb-case-arrow-left"></i>
                    </button>
                    <span class="tb-test-label case-label"> {{ currentCase + 1 }}</span>
                    <button id="next-case-btn" @mousedown="buttonListenerFunctions.nextCaseButton()"
                        class="custom-btn--basic panel-button tb-case-button-right tb-case-button">
                        <i class="tb-case-arrow tb-case-arrow-right"></i>
                    </button>
                </div>
            </div>
            <div style="text-align: center">
                <table class="tb-manual-table">
                    <tr id="tb-manual-table-labels">
                        <th>LABELS</th>
                        <th v-for="io in combinedIO" :key="io.label">{{ io.label }}</th>
                    </tr>
                    <tr id="tb-manual-table-bitwidths">
                        <td>Bitwidth</td>
                        <td v-for="io in combinedIO" :key="io.label">{{ io.bitWidth }}</td>
                    </tr>
                    <tr id="tb-manual-table-current-case">
                        <td>Current Case</td>
                        <td v-for="input in inputs" :key="input.label">{{
                            input.values[currentCase] }}</td>
                        <td v-for="output in outputs" :key="output.label">{{
                            output.values[currentCase] }}</td>
                    </tr>
                    <tr id="tb-manual-table-test-result">
                        <td>Result</td>
                        <td v-for="(result, index) in testBenchStore.resultValues" :key="index" :style="{ color: result.color }">{{ result.value }}</td>
                    </tr>
                </table>
            </div>
            <div style="display: table; margin-top: 20px; margin-left: 8px">
                <div class="testbench-manual-panel-buttons">
                    <button id="validate-btn" @mousedown="buttonListenerFunctions.validateButton()"
                        class="custom-btn--basic panel-button tb-dialog-button">
                        Validate
                    </button>
                    <button id="runall-btn" @mousedown="buttonListenerFunctions.runAllButton()"
                        class="custom-btn--primary panel-button tb-dialog-button">
                        Run All
                    </button>
                </div>
                <span v-if="testBenchStore.showPassed">
                    <span>{{ testBenchStore.passed }} out of {{ testBenchStore.total }}</span> Tests Passed
                    <span @mousedown="openCreator('result')" :style="{ color: '#18a2cd' }">View Detailed</span>
                </span>
            </div>
        </div>
        <div v-else class="panel-body tb-test-null">
            <div class="tb-manual-test-data">
                <div style="margin-bottom: 10px; overflow: auto">
                    <p><i>No Test is attached to the current circuit</i></p>
                </div>
                <button id="attach-test-btn" @mousedown="buttonListenerFunctions.attachTestButton()"
                    class="custom-btn--primary panel-button tb-dialog-button">
                    Attach Test
                </button>
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>
import { useTestBenchStore } from '#/store/testBenchStore'
import { computed } from 'vue'
import { buttonListenerFunctions } from '#/simulator/src/testbench'
import { openCreator } from '#/simulator/src/testbench';
import { useLayoutStore } from '#/store/layoutStore'
import { onMounted, ref } from 'vue'

const layoutStore = useLayoutStore()
const testBenchStore = useTestBenchStore();
const testbenchPanelRef = ref<HTMLElement | null>(null);

onMounted(() => {
    layoutStore.testbenchPanelRef = testbenchPanelRef.value
})

const testData = computed(() => testBenchStore.testbenchData?.testData);

const combinedIO = computed(() => {
    const group = testData.value.groups[0];
    return group.inputs.concat(group.outputs);
});

const currentGroup = computed(() => testBenchStore.testbenchData.currentGroup);
const currentCase = computed(() => testBenchStore.testbenchData.currentCase);

const inputs = computed(() => testData.value.groups[currentGroup.value].inputs);
const outputs = computed(() => testData.value.groups[currentGroup.value].outputs);
</script>
