import { createRouter, createWebHistory } from 'vue-router'
// import simulator from '../pages/simulator.vue'
import simulatorHandler from '../pages/simulatorHandler.vue'

const routes = [
    {
        path: '/',
        redirect: '/simulatorvue', // @TODO: update later back to /simulator
    },
    {
        path: '/simulatorvue', // @TODO: update later back to /simulator
        name: 'simulator',
        // component: simulator,
        component: simulatorHandler,
        children: [
            {
                path: 'edit/:projectId',
                name: 'simulator-edit',
                // component: simulator,
                component: simulatorHandler,
                props: true,
            },
        ],
    },
]
const router = createRouter({
    history: createWebHistory(),
    routes,
})

export default router
