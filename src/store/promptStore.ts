import { HTMLContent } from '@tiptap/core'
import { defineStore } from 'pinia'

interface promptStoreType {
    resolvePromise: Function
    // resolvePromise: (value?: string | undefined) => void
    prompt: {
        activate: boolean
        messageText: string
        isPersistent: boolean
        buttonList: Array<{
            text: string
            emitOption: string
        }>
        inputList: Array<{
            text: string
            val: string
            placeholder: string
            id: string
            class: string
            style: string
            type: string
        }>
    }
    confirm: {
        activate: boolean
        messageText: string
        isPersistent: boolean
        buttonList: Array<{
            text: string
            emitOption: string | boolean
        }>
    }
    DeleteCircuit: {
        activate: boolean
        messageText: string
        isPersistent: boolean
        buttonList: Array<{
            text: string
            emitOption: string
        }>
        circuitItem: object
    }
    UpdateProjectDetail: {
        activate: boolean
        projectId: number
        projectName: string
        projectTags: string
        projectType: Readonly<any> | string
        projectDescription: HTMLContent
    }
}

export const usePromptStore = defineStore({
    id: 'promptStore',
    state: (): promptStoreType => ({
        resolvePromise: (): any => {},
        prompt: {
            activate: false,
            messageText: '',
            isPersistent: false,
            buttonList: [],
            inputList: [],
        },
        confirm: {
            activate: false,
            messageText: '',
            isPersistent: false,
            buttonList: [],
        },
        DeleteCircuit: {
            activate: false,
            messageText: '',
            isPersistent: false,
            buttonList: [],
            circuitItem: {},
        },
        UpdateProjectDetail: {
            activate: false,
            projectId: 0,
            projectName: '',
            projectTags: '',
            projectType: 'Public',
            projectDescription: '',
        },
    }),
    actions: {
        // resolvePromise(): any {},
        setProjectName(projectName: string): void {
            this.UpdateProjectDetail.projectName = projectName
        },
        setProjectId(projectId: number): void {
            this.UpdateProjectDetail.projectId = projectId
        },
    },
    getters: {
        getProjectName(): string {
            return this.UpdateProjectDetail.projectName
        },
        getProjectId(): number {
            return this.UpdateProjectDetail.projectId
        },
        getProjectTags(): string {
            return this.UpdateProjectDetail.projectTags
        },
        getProjectType(): Readonly<any> | string {
            return this.UpdateProjectDetail.projectType
        },
        getProjectDescription(): HTMLContent {
            return this.UpdateProjectDetail.projectDescription
        },
    },
})
