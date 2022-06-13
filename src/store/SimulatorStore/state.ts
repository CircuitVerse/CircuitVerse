import { defineStore } from "pinia";

export interface State {
    title: string;
}

export const useState = defineStore({
    id: "simulatorStore.state",

    state: (): State => {
        return {
            title: "Welcome to CircuitVerse Simulator",
        };
    },
});
