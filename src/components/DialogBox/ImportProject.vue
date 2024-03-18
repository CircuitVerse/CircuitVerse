<template>
    <v-dialog
        v-model="SimulatorState.dialogBox.import_project_dialog"
        :persistent="true"
    >
        <v-card class="importProjectDialog">
            <v-text-field>
                <p>Import file</p>
                <v-btn
                    size="x-small"
                    icon
                    class="dialogClose"
                    @click="
                        SimulatorState.dialogBox.import_project_dialog = false
                    "
                >
                    <v-icon>mdi-close</v-icon>
                </v-btn>
                <div
                    v-cloak
                    class="cloak"
                    @drop.prevent="addDropFile($event)"
                    @dragover.prevent
                >
                    <v-file-input
                        label="Click to Select or Drag and drop file here"
                        class="fileInput"
                        id="fileInput"
                        center-affix
                        :error-messages="errorMessage"
                        max-errors="1"
                        accept=".cv"
                        v-model="file"
                        prepend-icon="mdi-paperclip"
                    >
                        <template v-slot:selection="{ fileNames }">
                            <template
                                v-for="fileName in fileNames"
                                :key="fileName"
                            >
                                <v-chip size="x-large" class="me-2">
                                    {{ fileName }}
                                </v-chip>
                            </template>
                        </template>
                    </v-file-input>
                </div>
            </v-text-field>
            <v-card-actions>
                <v-btn
                    class="messageBtn"
                    @click="
                        SimulatorState.dialogBox.import_project_dialog = false
                    "
                >
                    Cancel
                </v-btn>
                <v-btn class="messageBtn" @click="importDataFromFile">
                    Import
                </v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts">
import { generateSaveData } from '#/simulator/src/data/save'
import { escapeHtml } from '#/simulator/src/utils'
import load from '#/simulator/src/data/load'
import { useState } from '#/store/SimulatorStore/state'
import { useProjectStore } from '#/store/projectStore'
import { ref } from 'vue'
import { watch } from 'vue'

export function ImportProject() {
    const SimulatorState = useState()
    SimulatorState.dialogBox.import_project_dialog = true
}
</script>

<script lang="ts" setup>
const SimulatorState = useState()
const projectStore = useProjectStore()

const scopeSchema = [
    'layout',
    'verilogMetadata',
    'allNodes',
    'id',
    'name',
    'restrictedCircuitElementsUsed',
    'nodes',
]
const JSONSchema = [
    'name',
    'timePeriod',
    'clockEnabled',
    'projectId',
    'focussedCircuit',
    'orderedTabs',
    'scopes',
]

const file = ref(Array<File>())
const errorMessage = ref('')

function addDropFile(e: DragEvent) {
    if (e.dataTransfer?.files[0]) {
        const droppedFile = e.dataTransfer?.files[0]
        const fileExtension = droppedFile.name.split('.').pop()

        if (fileExtension === 'cv') {
            file.value[0] = droppedFile
            document
                .querySelector('.fileInput')
                ?.classList.remove('error--text')
            errorMessage.value = ''
        } else {
            document.querySelector('.fileInput')?.classList.add('error--text')
            errorMessage.value =
                'Invalid file format. Only [ .cv ] files are accepted. Try again.'
        }
    }
}

function ValidateData(fileData: string) {
    try {
        const parsedFileDate = JSON.parse(fileData)
        if (
            JSON.stringify(Object.keys(parsedFileDate)) !==
            JSON.stringify(JSONSchema)
        )
            throw new Error('Invalid JSON data')
        parsedFileDate.scopes.forEach((scope: object) => {
            const keys = Object.keys(scope) // get scope keys
            scopeSchema.forEach((key) => {
                if (!keys.includes(key)) throw new Error('Invalid Scope data')
            })
        })
        load(parsedFileDate)
        return true
    } catch (error) {
        document.querySelector('.fileInput')?.classList.add('error--text')
        errorMessage.value = 'Invalid / Corrupt [ .cv ] file !'
        return false
    }
}

async function receivedText(fileContent: string) {
    // receive file content
    const backUp = JSON.parse(
        (await generateSaveData(
            escapeHtml(projectStore.getProjectName || 'untitled').trim(),
            false
        )) as any
    )
    const valid = ValidateData(fileContent) // pass fileContent
    if (valid) {
        SimulatorState.dialogBox.import_project_dialog = false
    } else {
        load(backUp)
    }
}

function readFile() {
    const importFile = file.value[0]
    const reader = new FileReader()
    reader.onload = function () {
        receivedText(reader.result as string) // Pass the file content to receivedText
    }
    reader.readAsText(importFile)
}

function importDataFromFile() {
    if (file.value.length === 0) {
        document.getElementById('fileInput')?.click()

        watch(
            () => file.value[0],
            () => {
                if (file.value.length !== 0) {
                    readFile()
                }
            }
        )
    } else {
        readFile()
    }
}
</script>

<style scoped>
.importProjectDialog {
    height: auto;
    width: 600px;
    justify-content: center;
    margin: auto;
    backdrop-filter: blur(5px);
    border-radius: 5px;
    border: 0.5px solid var(--br-primary) !important;
    background: var(--bg-primary-moz) !important;
    background-color: var(--bg-primary-chr) !important;
    color: white;
}

/* media query for .messageBoxContent */
@media screen and (max-width: 991px) {
    .importProjectDialog {
        width: 100%;
    }
}

.cloak {
    width: 100%;
    padding: 1rem 1rem 0;
}
</style>

<style>
.fileInput .v-field__field {
    height: 15rem !important;
    cursor: pointer;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: 1rem;
}

.fileInput .v-field__field .v-field__input {
    justify-content: center;
}

.fileInput .v-field__clearable {
    align-items: center;
    font-size: 1.5rem;
}

.error--text .v-messages__message {
    font-size: 1rem;
}

.error--text .v-input__details {
    margin-bottom: 0;
    padding-bottom: 0.5rem;
    background-color: #450a0a;
}
</style>

<!-- For any bugs refer to Open.js file in main repo -->
