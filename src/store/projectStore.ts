import { defineStore } from 'pinia'

interface projectStoreType {
    project: {
        // id: number //use later if needed
        name: string
        nameDefined: boolean
    }
}

export const useProjectStore = defineStore({
    id: 'projectStore',
    state: (): projectStoreType => ({
        project: {
            // id: 0, //use later if needed
            name: 'Untitled',
            nameDefined: false,
        },
    }),
    actions: {
        setProjectName(projectName: string): void {
            this.project.name = projectName
            this.project.nameDefined = true
        },
        setProjectNameDefined(defined: boolean = true): void {
            this.project.nameDefined = defined
        },
    },
    getters: {
        getProjectName(): string {
            return this.project.name
        },
        getProjectNameDefined(): boolean {
            return this.project.nameDefined
        },
    },
})
