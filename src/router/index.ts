import { createRouter, createWebHistory } from "vue-router";
import index from "../pages/index.vue";
import simulator from "../pages/simulator.vue";

const routes = [
    {
        path: "/",
        name: "index",
        component: index,
    },
    {
        path: "/simulator",
        name: "simulator",
        component: simulator,
    },
];
const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;
