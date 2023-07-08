<template>
    <v-dialog
        v-model="promptStore.UpdateProjectDetail.activate"
        :persistent="true"
    >
        <v-card class="CreateProject" :class="{ fullscreen: isFullscreen }">
            <section class="head-section">
                <h1 class="heading">Edit Project Details</h1>
            </section>
            <v-card-text style="margin: 0 1rem">
                <v-form>
                    <div class="name-input one-line-input">
                        <p class="name-input-title one-line-input-title">
                            Project Name:
                        </p>
                        <v-text-field
                            v-model="
                                promptStore.UpdateProjectDetail.projectName
                            "
                            label="Project Name"
                            required
                        ></v-text-field>
                    </div>
                    <template v-if="promptStore.getProjectTags">
                        <v-chip
                            v-for="tag in promptStore.getProjectTags.split(',')"
                            :key="tag"
                            class="ma-1"
                            size="small"
                            text-color="white"
                        >
                            {{ tag }}
                        </v-chip>
                    </template>
                    <div class="tag-input one-line-input">
                        <p class="tag-input-title one-line-input-title">
                            Project Tags:
                        </p>
                        <v-text-field
                            v-model="
                                promptStore.UpdateProjectDetail.projectTags
                            "
                            label="Tag List (Enter your Project Tags divided by
                            comma[,])"
                        ></v-text-field>
                    </div>
                    <div class="project-type one-line-input">
                        <p class="project-type-title one-line-input-title">
                            Project Type:
                        </p>
                        <v-select
                            v-model="
                                (promptStore.UpdateProjectDetail.projectType as Readonly<any>)
                            "
                            :items="projectTypes"
                            label="Project Type"
                            required
                        ></v-select>
                    </div>
                    <p>Description:</p>
                    <TextEditor
                        v-model="
                            promptStore.UpdateProjectDetail.projectDescription
                        "
                        @toggleFullscreen="toggleFullscreen"
                    />
                </v-form>
            </v-card-text>
            <v-card-actions>
                <v-btn
                    v-for="buttonItem in buttonList"
                    :key="buttonItem.text"
                    class="cardBtn"
                    block
                    @click="updateProjectButton(buttonItem.emitOption)"
                >
                    {{ buttonItem.text }}
                </v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts">
import { usePromptStore } from '#/store/promptStore'
import { useProjectStore } from '#/store/projectStore'
import { ref } from 'vue'
import TextEditor from './TextEditor.vue'
import { useAuthStore } from '#/store/authStore'
import {
    confirmMultiOption,
    confirmSingleOption,
} from '../confirmComponent/ConfirmComponent.vue'
import { getToken } from '#/pages/simulatorHandler.vue'

interface dataType {
    project: {
        id: number
        name: string
    }
}

export const UpdateProjectDetail = (data: dataType) => {
    const promptStore = usePromptStore()
    const projectStore = useProjectStore()
    promptStore.UpdateProjectDetail.activate = true
    projectStore.setProjectName(data.project.name)
    promptStore.setProjectName(data.project.name)
    promptStore.setProjectId(data.project.id)
}
</script>

<script lang="ts" setup>
const promptStore = usePromptStore()
const isFullscreen = ref(false)
const projectTypes = ref(['Public', 'Private', 'Limited access'])
const buttonList = ref([
    {
        text: 'Cancel',
        emitOption: 'cancel',
    },
    {
        text: 'Open Edit Page',
        emitOption: 'openEditPage',
    },
    {
        text: 'Update',
        emitOption: 'update',
    },
])

function toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value
}

function updateProjectButton(selectedOption: string) {
    promptStore.UpdateProjectDetail.activate = false
    if (selectedOption == 'cancel') {
        window.location.href = `/simulatorvue/edit/${promptStore.getProjectId}`
    }
    if (selectedOption == 'openEditPage') {
        window.location.href = `/users/${useAuthStore().getUserId}/projects/${
            promptStore.getProjectId
        }/edit`
    }
    if (selectedOption == 'update') {
        const projectData = {
            project: {
                name: promptStore.getProjectName, // returns string (project name)
                tag_list: promptStore.getProjectTags, // getProjectTags must return a comma separated string (in case of multiple tags)
                project_access_type: promptStore.getProjectType, // returns string (Public, Private, Limited access)
                description: promptStore.getProjectDescription, // returns html text
            },
        }

        const projectJson = JSON.stringify(projectData)

        fetch(`/api/v1/projects/${promptStore.getProjectId}?include=author`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                Accept: 'application/json',
                Authorization: `Token ${getToken('cvt')}`,
            },
            body: projectJson,
        })
            .then((response) => {
                if (response.ok) {
                    successPrompt()
                } else {
                    failurePrompt()
                }
            })
            .catch((error) => {
                console.error('Error:', error)
            })
    }
}

async function successPrompt() {
    const choice = await confirmMultiOption(
        'project has been updated successfully',
        ['go to project', 'keep editing circuit']
    )

    if (choice == 'go to project') {
        window.location.href = `/users/${useAuthStore().getUserId}/projects/${
            promptStore.getProjectId
        }`
    } else {
        window.location.href = `/simulatorvue/edit/${promptStore.getProjectId}`
    }
}

async function failurePrompt() {
    const response = await confirmSingleOption(
        'Project details could not be updated. You will be redirected to Project Edit page.'
    )
    if (response === true) {
        window.location.href = `/users/${useAuthStore().getUserId}/projects/${
            promptStore.getProjectId
        }/edit`
    }
}
</script>

<style scoped>
.CreateProject {
    height: auto;
    width: 95vw;
    justify-content: center;
    margin: auto;
    backdrop-filter: blur(10px);
    border-radius: 5px;
    border: 0.5px solid var(--br-primary) !important;
    background: var(--bg-primary-moz) !important;
    background-color: var(--bg-primary-chr) !important;
    color: white;
}
.CreateProject.fullscreen {
    height: 86vh;
}

.heading {
    font-size: 1.5rem;
    font-weight: 500;
    margin: 1rem auto auto auto;
    padding: 0.5rem;
    text-align: center;
}

.one-line-input {
    display: flex;
    justify-content: center;
    gap: 1rem;
}
.one-line-input-title {
    margin: 1.3rem 0 0 0;
}

.tag-input-title,
.project-type-title {
    margin-right: 0.4rem;
}

.cardBtn {
    width: fit-content;
    min-width: 50px;
    border: 1px solid #c5c5c5;
    padding: 5px 5px;
}

.cardBtn:hover {
    background: #c5c5c5;
    color: black;
}

/* media query for .messageBoxContent */
@media screen and (max-width: 991px) {
    .CreateProject {
        width: 100vw;
    }
}
</style>
