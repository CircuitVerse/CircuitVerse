<template>
    <v-dialog
        v-model="SimulatorState.dialogBox.open_project_dialog"
        :persistent="false"
    >
        <v-card class="messageBoxContent">
            <v-card-text>
                <p class="dialogHeader">Open Offline</p>
                <v-btn
                    size="x-small"
                    icon
                    class="dialogClose"
                    @click="
                        SimulatorState.dialogBox.open_project_dialog = false
                    "
                >
                    <v-icon>mdi-close</v-icon>
                </v-btn>
                <div id="openProjectDialog" title="Open Project">
                    <label
                        v-for="(projectName, projectId) in projectList"
                        :key="projectId"
                        class="option custom-radio"
                    >
                        <input
                            type="radio"
                            name="projectId"
                            :value="projectId"
                            v-model="selectedProjectId"
                        />
                        {{ projectName }}<span></span>
                        <i
                            class="fa fa-trash deleteOfflineProject"
                            @click="deleteOfflineProject(projectId.toString())"
                        ></i>
                    </label>
                    <p v-if="JSON.stringify(projectList) == '{}'">
                        Looks like no circuit has been saved yet. Create a new
                        one and save it!
                    </p>
                </div>
            </v-card-text>
            <v-card-actions>
                <v-btn
                    v-if="JSON.stringify(projectList) != '{}'"
                    class="messageBtn"
                    block
                    @click="openProjectOffline()"
                >
                    open project
                </v-btn>
                <v-btn
                    v-else
                    class="messageBtn"
                    block
                    @click.stop="OpenImportProjectDialog"
                >
                    open CV file
                </v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts" setup>
import load from '#/simulator/src/data/load'
import { useState } from '#/store/SimulatorStore/state'
import { onMounted, onUpdated, ref, reactive } from '@vue/runtime-core'
const SimulatorState = useState()
const projectList: {
    [key: string]: string
} = reactive({})
const selectedProjectId = ref<string | null>(null)

onMounted(() => {
    SimulatorState.dialogBox.open_project_dialog = false
})

onUpdated(() => {
    const data = localStorage.getItem('projectList')
    projectList.value = data ? JSON.parse(data) : {}
})

function deleteOfflineProject(id: string) {
    localStorage.removeItem(id)
    const data = localStorage.getItem('projectList')
    const temp = data ? JSON.parse(data) : {}
    delete temp[id]
    projectList.value = temp
    localStorage.setItem('projectList', JSON.stringify(temp))
}

function openProjectOffline() {
    SimulatorState.dialogBox.open_project_dialog = false
    if (!selectedProjectId.value) return
    const projectData = localStorage.getItem(selectedProjectId.value)
    if (projectData) {
        load(JSON.parse(projectData))
        window.projectId = selectedProjectId.value
    }
}

function OpenImportProjectDialog() {
    SimulatorState.dialogBox.open_project_dialog = false
    SimulatorState.dialogBox.import_project_dialog = true
}
</script>
