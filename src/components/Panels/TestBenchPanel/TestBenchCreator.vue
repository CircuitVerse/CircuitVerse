<template>
    <v-dialog v-model="showCreator" :persistent="false">
        <v-card class="messageBoxContent" id="creatorBox">
            <v-card-text class="creatorHeader">
                <p class="dialogHeader">{{ dialogTitle }}</p>
                <v-btn size="x-small" icon class="dialogClose"
                    @mousedown="testBenchStore.showTestBenchCreator = false">
                    <v-icon>mdi-close</v-icon>
                </v-btn>
                <div class="testInput">
                    <label for="fileNameInputField">Title:</label>
                    <input v-model="testTitle" class="inputField" type="text" />
                </div>
            </v-card-text>

            <v-card-actions class="testType">
                <v-btn class="messageBtn" block @mousedown="testType = 'seq'">
                    Sequential Test
                </v-btn>
                <v-btn class="messageBtn" block @mousedown="testType = 'comb'">
                    Combinational Test
                </v-btn>
            </v-card-actions>

            <v-card-text style="testCard">
                <div class="testCol">
                    <div class="testRow firstCol">

                    </div>
                    <div class="testRow fullTestRow space">
                        <span>Inputs</span> <span @mousedown="increInputs" class="plusBtn">+</span>
                    </div>
                    <div class="testRow fullTestRow space">
                        <span>Outputs</span> <span @mousedown="increOutputs" class="plusBtn">+</span>
                    </div>
                </div>
                <div class="testCol">
                    <div class="testRow firstCol">
                        Label
                    </div>
                    <div class="testContainer">
                        <div v-for="(_, i) in inputsName" class="testRow"
                            :style="{ width: 100 / inputsBandWidth.length + '%' }">
                            <input class="inputField dataGroupTitle smInputName" type="text" v-model="inputsName[i]" />
                        </div>
                    </div>
                    <div class="testContainer">
                        <div v-for="(_, i) in outputsName" class="testRow"
                            :style="{ width: 100 / outputsBandWidth.length + '%' }">
                            <input class="inputField dataGroupTitle smInputName" type="text" v-model="outputsName[i]" />
                        </div>
                    </div>
                </div>
                <div class="testCol">
                    <div class="testRow firstCol">
                        Bandwidth
                    </div>
                    <div class="testContainer">
                        <div v-for="(_, i) in inputsBandWidth" class="testRow"
                            :style="{ width: 100 / inputsBandWidth.length + '%' }">
                            <input class="inputField dataGroupTitle smInput" type="text" v-model="inputsBandWidth[i]"
                                maxlength="1" />
                        </div>
                    </div>
                    <div class="testContainer">
                        <div v-for="(_, i) in outputsBandWidth" class="testRow"
                            :style="{ width: 100 / outputsBandWidth.length + '%' }">
                            <input class="inputField dataGroupTitle smInput" type="text" v-model="outputsBandWidth[i]"
                                maxlength="1" />
                        </div>
                    </div>
                </div>

                <div v-for="(group, groupIndex) in groups" class="groupParent" :key="groupIndex">
                    <input v-model="group.title" class="inputField dataGroupTitle" type="text" />
                    <p>Click + to add tests to the {{ testType === 'comb' ? 'group' : 'set' }}</p>

                    <div v-for="(_, index) in group.inputs[0]" class="groupRow" :key="index">
                        <div class="testRow firstCol spaceArea"></div>
                        <div class="testContainer">
                            <div v-for="(_, i) in group.inputs" class="testRow colWise"
                                :style="{ width: 100 / inputsBandWidth.length + '%' }">
                                <input class="inputField dataGroupTitle smInput" type="text"
                                    :disabled="testBenchStore.readOnly" v-model="group.inputs[i][index]"
                                    maxlength="1" />
                            </div>
                        </div>
                        <div class="testContainer">
                            <div v-for="(_, i) in group.outputs" class="testRow colWise"
                                :style="{ width: 100 / outputsBandWidth.length + '%' }">
                                <input class="inputField dataGroupTitle smInput" type="text"
                                    :disabled="testBenchStore.readOnly" v-model="group.outputs[i][index]"
                                    maxlength="1" />
                            </div>
                        </div>
                        <div v-if="testBenchStore.showResults" class="resultContainer">
                            <div v-for="(_, i) in results" class="testRow colWise"
                                :style="{ width: 100 / outputsBandWidth.length + '%', color: results[groupIndex][i][index] ? '#17FC12' : '#FF1616' }">
                                 {{ results[groupIndex][i][index] ? '✔' : '✘' }}
                            </div>
                        </div>
                    </div>

                    <v-btn v-if="groupIndex !== groups.length - 1" class="messageBtn addBtn" block
                        @mousedown="addTestToGroup(groupIndex)">
                        +
                    </v-btn>
                </div>
            </v-card-text>

            <v-card-actions class="testActionBtns">
                <div class="btnDiv">
                    <v-btn class="messageBtn" block @mousedown="addTestToGroup(groups.length - 1)">
                        +
                    </v-btn>
                    <v-btn class="messageBtn" block @mousedown="addNewGroup">
                        New Group
                    </v-btn>
                </div>
                <div class="btnDiv">
                    <v-btn class="messageBtn" block @mousedown="importFromCSV">
                        Import From CSV
                    </v-btn>
                    <v-btn class="messageBtn" block @mousedown="exportAsCSV">
                        Export As CSV
                    </v-btn>
                    <v-btn class="messageBtn" block @mousedown="sendData">
                        Attach
                    </v-btn>
                </div>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts" setup>
import { computed, ref, reactive, watch } from 'vue';
import { useTestBenchStore } from '#/store/testBenchStore';

const testBenchStore = useTestBenchStore();

const showCreator = computed(() => testBenchStore.showTestBenchCreator);

const results: boolean[][][] = reactive([]);
const testTitle = ref('Untitled');
const dialogTitle = ref('Create Test');
const testType = ref<string>('comb');

const inputsBandWidth = ref([1]);
const outputsBandWidth = ref([1]);
const inputsName = ref<string[]>(["inp1"]);
const outputsName = ref<string[]>(["out1"]);

interface Group {
    title: string;
    inputs: string[][];
    outputs: string[][];
}

const groups = reactive<Group[]>([
    {
        title: 'Group 1',
        inputs: [],
        outputs: [],
    }
]);

watch(() => testBenchStore.testbenchData.testData.groups, () => {
    const { groups: newGroups } = testBenchStore.testbenchData.testData;

    const values = newGroups.map(group => ({
        title: group.label,
        inputs: group.inputs.map(input => input.values),
        outputs: group.outputs.map(output => output.values),
    }));

    groups.splice(0, groups.length, ...values);

    if (newGroups[0]) {
        const { inputs, outputs } = newGroups[0];

        inputsBandWidth.value.splice(0, inputsBandWidth.value.length, ...inputs.map(input => input.bitWidth));
        outputsBandWidth.value.splice(0, outputsBandWidth.value.length, ...outputs.map(output => output.bitWidth));
        inputsName.value.splice(0, inputsName.value.length, ...inputs.map(input => input.label));
        outputsName.value.splice(0, outputsName.value.length, ...outputs.map(output => output.label));
    } else {
        inputsBandWidth.value.splice(0, inputsBandWidth.value.length, 1);
        outputsBandWidth.value.splice(0, outputsBandWidth.value.length, 1);
        inputsName.value.splice(0, inputsName.value.length, "inp1");
        outputsName.value.splice(0, outputsName.value.length, "out1");
    }
});

watch(() => testBenchStore.testbenchData.testData.groups, () => {
    results.splice(0, results.length);
    testBenchStore.testbenchData.testData.groups.map(group => {
        results.push([]);
        group.outputs.map((output) => {
            results[results.length - 1].push([]);
            for(let i = 0; i < output.values.length; i++) {
                if(output.results && output.values[i] === output.results[i]) {
                    results[results.length - 1][results[results.length - 1].length - 1].push(true);
                } else {
                    results[results.length - 1][results[results.length - 1].length - 1].push(false);
                }
            }
        });
    });
},
    { deep: true }
);

watch(testType, () => {
    if (testType.value === 'comb') {
        groups.forEach(group => {
            group.title = `Group ${groups.indexOf(group) + 1}`;
        });
    }
    else {
        groups.forEach(group => {
            group.title = `Set ${groups.indexOf(group) + 1}`;
        });
    }
});

const sendData = () => {
    const groupsData = groups.map(group => {
        const inputsData = group.inputs.map((input, index) => {
            return {
                label: inputsName.value[index],
                bitWidth: inputsBandWidth.value[index],
                values: input
            };
        });

        const outputsData = group.outputs.map((output, index) => {
            return {
                label: outputsName.value[index],
                bitWidth: outputsBandWidth.value[index],
                values: output
            };
        });

        return {
            label: group.title,
            inputs: inputsData,
            outputs: outputsData,
            n: inputsData[0] ? inputsData[0].values.length : 0,
        };
    });

    const testData = {
        type: testType.value,
        title: testTitle.value,
        groups: groupsData,
    };

    testBenchStore.sendData(testData);
}

const addTestToGroup = (index: number) => {
    const group = groups[index];
    for (let i = 0; i < inputsBandWidth.value.length; i++) {
        if (group.inputs.length === i)
            group.inputs.push([]);
        group.inputs[i].push("0");
    }

    for (let i = 0; i < outputsBandWidth.value.length; i++) {
        if (group.outputs.length === i)
            group.outputs.push([]);
        group.outputs[i].push("0");
    }
};

const addNewGroup = () => {
    groups.push({
        title: `Group ${groups.length + 1}`,
        inputs: [],
        outputs: [],
    });
};

const increInputs = () => {
    groups.forEach((group) => {
        if (group.inputs.length === 0) return;

        group.inputs.push([]);

        for (let i = 0; i < group.inputs[0].length; i++) {
            group.inputs[group.inputs.length - 1].push("0");
        }
    });

    inputsBandWidth.value.push(1);
    inputsName.value.push(`inp${inputsName.value.length + 1}`);
};

const increOutputs = () => {
    groups.forEach((group) => {
        if (group.outputs.length === 0) return;

        group.outputs.push([]);

        for (let i = 0; i < group.outputs[0].length; i++) {
            group.outputs[group.outputs.length - 1].push("0");
        }
    });

    outputsBandWidth.value.push(1);
    outputsName.value.push(`out${outputsName.value.length + 1}`);
};

const exportAsCSV = () => {
    let csv = `${testType.value},${testTitle.value}\n`;

    csv += `Inputs BandWidth: ${inputsBandWidth.value.join(',')}\n`;
    csv += `Outputs BandWidth: ${outputsBandWidth.value.join(',')}\n`;
    csv += `Inputs Name: ${inputsName.value.join(',')}\n`;
    csv += `Outputs Name: ${outputsName.value.join(',')}\n`;

    csv += groups.map(group => {
        let groupStr = `G-${group.title}:\n`;
        groupStr += group.inputs.map((input, index) => `I-${inputsName.value[index]}:${input.join(',')}`).join('\n');
        groupStr += '\n';
        groupStr += group.outputs.map((output, index) => `O-${outputsName.value[index]}:${output.join(',')}`).join('\n');
        return groupStr;
    }).join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = `${testTitle.value}.csv`;
    a.click();
    URL.revokeObjectURL(url);
};

const importFromCSV = () => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.csv';
    input.onchange = () => {
        const file = input.files?.[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = () => {
            const csv = reader.result as string;
            const lines = csv.split('\n');

            const firstLine = lines.shift();
            if (firstLine) {
                [testType.value, testTitle.value] = firstLine.split(',');
            }

            let line = lines.shift();
            if (line) {
                inputsBandWidth.value = line.split(': ')[1].split(',').map(Number);
            }
            line = lines.shift();
            if (line) {
                outputsBandWidth.value = line.split(': ')[1].split(',').map(Number);
            }
            line = lines.shift();
            if (line) {
                inputsName.value = line.split(': ')[1].split(',');
            }
            line = lines.shift();
            if (line) {
                outputsName.value = line.split(': ')[1].split(',');
            }

            const newGroups: Group[] = [];
            let group: Group = {
                title: '',
                inputs: [],
                outputs: [],
            }
            lines.forEach(line => {
                if (line.startsWith('G-')) {
                    if (group.title) {
                        newGroups.push(group);
                    }
                    group = { title: line.slice(2), inputs: [], outputs: [] };
                } else {
                    const [name, values] = line.split(':');
                    const isInput = name.startsWith('I-') && inputsName.value.includes(name.slice(2));
                    const isOutput = name.startsWith('O-') && outputsName.value.includes(name.slice(2));
                    if (isInput) {
                        group.inputs.push(values.split(','));
                    } else if (isOutput) {
                        group.outputs.push(values.split(','));
                    }
                }
            });
            if (group.title) {
                newGroups.push(group);
            }

            groups.splice(0, groups.length, ...newGroups);
        };

        reader.readAsText(file);
    };

    input.click();
};
</script>

<style scoped>
#creatorBox {
    width: 1100px;
}

.creatorHeader {
    position: relative;
}

.testInput {
    display: flex;
    align-items: center;
    gap: 1rem;
}

.testType {
    width: 97%;
}

.testActionBtns {
    width: 97%;
    display: flex;
    justify-content: space-between;
    padding-bottom: 1rem;
}

.btnDiv {
    display: flex;
    gap: 0.1rem;
    align-items: center;
}

.testRow {
    border: 1px solid #c5c5c5;
    padding: 0.75rem;
    padding-left: 1.5rem;
    padding-right: 1.5rem;
    display: flex;
    justify-content: center;
    align-items: center;
}

.colWise {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}

.testCol {
    display: flex;
    gap: 0.5rem;
    justify-content: center;
    margin-bottom: 0.5rem;
}

.firstCol {
    width: 30%;
}

.dataGroupTitle {
    border: none;
    padding: 0;
    margin: 0;
}

.spaceArea {
    visibility: hidden;
}

.testContainer {
    display: flex;
    width: 35%;
    gap: 0.5rem;
    overflow-x: scroll;
}

.resultContainer {
    display: flex;
    width: 15%;
    gap: 0.5rem;
    overflow-x: scroll;
}

.fullTestRow {
    width: 35%;
}

.groupRow {
    display: flex;
    gap: 0.5rem;
    justify-content: center;
}

.plusBtn {
    cursor: pointer;
    padding: 2px;
    padding-top: 0.5px;
    padding-bottom: 0.5px;
    border: 1px solid #c5c5c5;
}

.space {
    gap: 0.25rem;
}

.groupParent {
    margin-bottom: 2rem;
    margin-top: 2rem;
}

.addBtn {
    background-color: transparent;
    color: white;
}

.testCard {
    padding-left: 2.2rem;
}

.smInput {
    width: 12px;
    border: none;
}

.smInputName {
    width: 34px;
    border: none;
}

.smInputName:focus,
.smInput:focus {
    outline: none;
    border: none;
}

.smInput:focus {
    outline: none;
    border: none;
}
</style>
