import { defineStore } from "pinia";

export const HomeStore = defineStore("main", {
    state: () => ({
        title: "Welcome to CircuitVerse Home Page",
    }),
});
