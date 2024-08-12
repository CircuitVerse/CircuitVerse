import { defineStore } from 'pinia'

// use camel case variable names
export interface State {
    title: string
    activeCircuit: {
        id: number | string
        name: string
    } | undefined;
    circuit_list: {
        id: number | string
        name: string
        isVerilog?: boolean
        focussed?: boolean
    }[];
    errorMessages: string[]
    successMessages: string[]
    circuit_name_clickable: boolean;
    dialogBox: {
        // create_circuit: boolean
        // delete_circuit: boolean
        combinationalanalysis_dialog: boolean
        hex_bin_dec_converter_dialog: boolean
        saveimage_dialog: boolean
        theme_dialog: boolean
        customshortcut_dialog: boolean
        insertsubcircuit_dialog: boolean
        exportverilog_dialog: boolean
        save_project_dialog: boolean
        open_project_dialog: boolean
        export_project_dialog: boolean
        import_project_dialog: boolean
    }
    // createCircuit: Object | { circuitName: string }
    combinationalAnalysis: Object
}

export const useState = defineStore({
    id: 'simulatorStore.state',

    state: (): State => {
        return {
            title: 'Welcome to CircuitVerse Simulator',
            activeCircuit: undefined,
            circuit_list: [],
            errorMessages: [],
            successMessages: [],
            circuit_name_clickable: false,
            dialogBox: {
                // create_circuit: false,
                // delete_circuit: false,
                combinationalanalysis_dialog: false,
                hex_bin_dec_converter_dialog: false,
                saveimage_dialog: false,
                theme_dialog: false,
                customshortcut_dialog: false,
                insertsubcircuit_dialog: false,
                exportverilog_dialog: false,
                save_project_dialog: false,
                open_project_dialog: false,
                export_project_dialog: false,
                import_project_dialog: false,
            },
            // createCircuit: {
            //     circuitName: 'Untitled Circuit',
            // },
            combinationalAnalysis: {
                inputNameList: 'eg. In A, In B',
                outputNameList: 'eg. Out X, Out Y',
                booleanExpression: 'Example: (AB)',
                decimalColumnBox: false,
            },
        }
    },
})
