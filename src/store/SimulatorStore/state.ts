import { defineStore } from 'pinia'

// use camel case variable names
export interface State {
    title: string
    circuit_list: []
    dialogBox: Object
    createCircuit: Object
    combinationalAnalysis: Object
}

export const useState = defineStore({
    id: 'simulatorStore.state',

    state: (): State => {
        return {
            title: 'Welcome to CircuitVerse Simulator',
            circuit_list: [],
            dialogBox: {
                create_circuit: false,
                combinationalanalysis_dialog: false,
                hex_bin_dec_converter_dialog: false,
                saveimage_dialog: false,
                theme_dialog: false,
                customshortcut_dialog: false,
                insertsubcircuit_dialog: false,
                exportverilog_dialog: false,
                save_project_dialog: false,
                open_project_dialog: false,
            },
            createCircuit: {
                circuitName: 'Untitled Circuit',
            },
            combinationalAnalysis: {
                inputNameList: 'eg. In A, In B',
                outputNameList: 'eg. Out X, Out Y',
                booleanExpression: 'Example: (AB)',
                decimalColumnBox: false,
            },
        }
    },
})
