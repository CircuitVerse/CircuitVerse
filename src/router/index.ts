import { createRouter, createWebHistory } from "vue-router";
import HomePage from "../pages/HomePage.vue";
import SimulatorPage from "../pages/SimulatorPage.vue";

const routes = [
    {
        path: "/",
        name: "HomePage",
        component: HomePage,
    },
    {
        path: "/simulator",
        name: "SimulatorPage",
        component: SimulatorPage,
    },
];
const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;
