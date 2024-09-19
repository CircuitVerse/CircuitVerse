<template>
    <v-dialog
        v-model="SimulatorState.dialogBox.export_project_dialog"
        :persistent="true"
    >
        <v-card class="exportProjectCard">
            <v-card-text>
                <p>Export as file</p>
                <v-btn
                    size="x-small"
                    icon
                    class="dialogClose"
                    @click="
                        SimulatorState.dialogBox.export_project_dialog = false
                    "
                >
                    <v-icon>mdi-close</v-icon>
                </v-btn>
                <div class="fileNameInput">
                    <p>File name:</p>
                    <input
                        v-model="fileNameInput"
                        id="fileNameInputField"
                        class="inputField"
                        type="text"
                        placeholder="untitled"
                        required
                    />
                    <p>.cv</p>
                </div>
            </v-card-text>
            <v-card-actions>
                <v-btn class="messageBtn" @click="exportAsFile"> Save </v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts">
import { ref } from 'vue'
import { useState } from '#/store/SimulatorStore/state'
import { useProjectStore } from '#/store/projectStore'
import { generateSaveData } from '#/simulator/src/data/save'
import { downloadFile } from '#/simulator/src/utils'
import { escapeHtml } from '#/simulator/src/utils'

export function ExportProject() {
    const SimulatorState = useState()
    SimulatorState.dialogBox.export_project_dialog = true
    setTimeout(() => {
        const fileNameInputField = document.getElementById(
            'fileNameInputField'
        ) as HTMLInputElement
        fileNameInputField?.select()
    }, 100)
}
</script>

<script lang="ts" setup>
const SimulatorState = useState()
const projectStore = useProjectStore()

const fileNameInput = ref(
    projectStore.getProjectName +
        '__' +
        new Date().toLocaleString().replace(/[: \/,-]/g, '_')
)

const exportAsFile = async () => {
    let fileName = escapeHtml(fileNameInput.value) || 'untitled'
    const circuitData = await generateSaveData(
        projectStore.getProjectName,
        false
    )
    fileName = `${fileName.replace(/[^a-z0-9]/gi, '_')}.cv`
    downloadFile(fileName, circuitData)
    SimulatorState.dialogBox.export_project_dialog = false
}
</script>

<style scoped>
.exportProjectCard {
    height: auto;
    width: 30rem;
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
    .exportProjectCard {
        width: 100%;
    }
}
.fileNameInput {
    display: flex;
    align-items: baseline;
    justify-content: center;
    gap: 1rem;
}

.fileNameInput p {
    white-space: nowrap;
}

.fileNameInput input {
    text-align: center;
}
</style>

<!-- For any bugs refer to SaveAs.js file in main repo -->
