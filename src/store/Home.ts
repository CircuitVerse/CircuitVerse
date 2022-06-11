import { defineStore } from "pinia";

export const HomeStore = defineStore("main", {
    state: () => ({
        text: "Route to '/simulaor' to see the Simulator",
    }),
});
