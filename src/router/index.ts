import { createRouter, createWebHistory } from "vue-router";
import Home from "../components/Home.vue";
import Simulator from "../components/Simulator.vue";

const routes = [
    {
        path: "/",
        name: "Home",
        component: Home,
    },
    {
        path: "/simulator",
        name: "Simulator",
        component: Simulator,
    },
];
const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;
