import { defineStore } from "pinia";
import { useState } from "./state";

export const useActions = defineStore("simulatorStore.actions", () => {
    const state = useState();

    function showTitle(): void {
        console.log(state.title);
    }

    // Note you are free to define as many internal functions as you want.
    // You only expose the functions that are returned.
    return {
        showTitle,
    };
});
