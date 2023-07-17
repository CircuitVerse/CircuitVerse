<template>
    <DeleteCircuit />
    <PromptComponent />
    <ConfirmComponent />
    <template v-if="promptStore.UpdateProjectDetail.activate">
        <UpdateProjectDetail />
    </template>
    <template v-if="SimulatorState.dialogBox.export_project_dialog">
        <ExportProject />
    </template>
    <template v-if="SimulatorState.dialogBox.import_project_dialog">
        <ImportProject />
    </template>
</template>

<script lang="ts" setup>
import DeleteCircuit from './deleteCircuit/DeleteCircuit.vue'
import PromptComponent from './promptComponent/PromptComponent.vue'
import ConfirmComponent from './confirmComponent/ConfirmComponent.vue'
import UpdateProjectDetail from './createNewProject/UpdateProjectDetail.vue'
import ExportProject from '../DialogBox/ExportProject.vue'
import ImportProject from '../DialogBox/ImportProject.vue'

import { useState } from '#/store/SimulatorStore/state'
import { usePromptStore } from '#/store/promptStore'
const SimulatorState = useState()
const promptStore = usePromptStore()
</script>
