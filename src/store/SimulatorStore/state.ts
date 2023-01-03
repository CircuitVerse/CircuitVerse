import { defineStore } from 'pinia'

export interface State {
    title: string
    circuit_list: []
    dialogBox: Object
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
        }
    },
})
